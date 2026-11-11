require "socket"
require "socket/tcp_socket"
require "socket/unix_socket"

module PG

  class Connection
    getter soc : UNIXSocket | TCPSocket
    @mutex = Mutex.new
    @connected = false
    @established = false

    def initialize(host : String?, port : Int?)
      begin
        if host.nil?
          soc = UNIXSocket.new("/run/postgresql/.s.PGSQL.5432")
        else
          soc = TCPSocket.new(host, port)
        end
        soc.sync = false
      rescue e
        raise ConnectionError.new("Cannot establish connection", cause: e)
      end
#      soc.read_timeout=Time::Span.new(seconds: 2)
      @connected = true
      @soc = soc
    end

    def connected
      @connected
    end


    private def write_i32(i : Int32)
      soc.write_bytes i, IO::ByteFormat::NetworkEndian
    end

    private def write_i32(i)
      write_i32 i.to_i32
    end

    private def write_i16(i : Int16)
      soc.write_bytes i, IO::ByteFormat::NetworkEndian
    end

    private def write_i16(i)
      write_i16 i.to_i16
    end

    private def write_null
      soc.write_byte 0_u8
    end

    private def write_byte(byte)
      soc.write_byte byte
    end

    private def write_chr(chr : Char)
      soc.write_byte chr.ord.to_u8
    end

    def read_i32
      soc.read_bytes(Int32, IO::ByteFormat::NetworkEndian)
    end

    def read_i16
      soc.read_bytes(Int16, IO::ByteFormat::NetworkEndian)
    end

    def read_byte
      c = soc.read_byte
      c = 0 if c.nil?
      c
    end

    def read_bytes(count)
      data = Slice(UInt8).new(count)
      soc.read_fully(data)
      data
    end

    def read_string
      s = ""
      while (c = soc.read_byte) != 0
        s += c.chr if !c.nil?
      end
      s
    end

    def read_direct(slice)
      soc.read(slice)
    end

    def skip_bytes(count)
      soc.skip(count)
    end

    def read_data_row(&)
      size = read_i32
      ncols = read_i16
      row = Array(Slice(UInt8)?).new(ncols.to_i32) do
        col_size = read_i32
        if col_size == -1
          nil
        else
          read_bytes(col_size)
        end
      end

      yield row
    end

    def send_query_message(query)
      write_chr 'Q'
      write_i32 query.bytesize + 4 + 1
      soc << query
      write_null
      soc.flush
    end

    def send_parse_message(query)
      write_chr 'P'
      write_i32 query.bytesize + 4 + 1 + 2 + 1
      write_null # prepared statment name
      soc << query
      write_i16 0 # don't give any param types
      write_null
    end

    # result_format can be 0 or 1. We pick 1 by default to get binary results
    # as most data types are much smaller over the wire and require less
    # processing on either end. Nowhere inside the this shard itself uses 0,
    # however it is a parameter so that people who want to use the protocol
    # directly can choose text results. The addition of this param though is
    # experimental, and may go away in future releases.
    def send_bind_message(params, result_format = 1_i16)
      nparams = params.size
      total_size = params.reduce(0) do |acc, p|
        acc + 4 + (p.size == -1 ? 0 : p.size)
      end

      write_chr 'B'
      write_i32 4 + 1 + 1 + 2 + (2*nparams) + 2 + total_size + 2 + 2
      write_null        # unnamed destination portal
      write_null        # unnamed prepared statment
      write_i16 nparams # number of params format codes to follow
      params.each { |p| write_i16 p.format }
      write_i16 nparams # number of params to follow
      params.each do |p|
        write_i32 p.size
        soc.write(p.slice)
      end
      write_i16 1 # number of following return types (1 means apply next for all)
      write_i16 result_format
    end

    def send_describe_portal_message
      write_chr 'D'
      write_i32 4 + 1 + 1
      write_chr 'P'
      write_null
    end

    def send_execute_message
      write_chr 'E'
      write_i32 4 + 1 + 4
      write_null  # unnamed portal
      write_i32 0 # unlimited maximum rows
    end

    def send_sync_message
      write_chr 'S'
      write_i32 4
      soc.flush
    end

    def send_terminate_message
      write_chr 'X'
      write_i32 4
    end

    def send_copy_data_message(slice)
      write_chr 'd'
      write_i32 4 + slice.size
      soc.write slice
    end

    def send_copy_done_message
      write_chr 'c'
      write_i32 4
      soc.flush
    end
  end
end
