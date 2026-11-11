
module PG

  struct Field
    name     : String
    table    : Int32
    column   : Int16
    type     : Int32
    typelen  : Int16
    modifier : Int32
    format   : Int16
    value    : String?

    def initialize(name : String, table : Int32, column : Int16, type : Int32, typelen : Int16, modifier : Int32, format : Int16)
    end
  end

  class Connection

    def query(command : String)
      # p "QUERY"
      #result : ResultSet
      record = Array(Field).new
      send_query_message(command)
      while true
        response = read_byte
        break if response.nil?
        p "RESULT #{response.chr}"
        case response
          when '1' ### ParseComplete
          when '2' ### BindComplete

          when 'A' ### NotificationResponse
          when 'E' ### ErrorResponse
          when 'N' ### NoticeResponse
          when 'n' ### NoData
          when 'I' ### EmptyQueryResponse
          when 'C' ### CommandComplete
            command_complete
          when 'D' ### DataRow
            data = data_row
            p data
          when 'T' ### RowDescription
            fields = row_description
            #p fields
          when 'Z' ### ReadyForQuery
            ready_for_query
            break
          when 'S' ### ParameterStatus
          when 'K' ### BackendKeyData
          when 'R' ### Authentication
          when 'c' ### CopyDone
          when 'G' ### CopyInResponse
          when 'H' ### CopyOutResponse
          else
            raise QueryError.new("Unexpected message '#{response.chr} from PostgreSQL server")
            break
          end
        end
        #result
      #fields = nil
      #ResultSet.new(self, fields)
    end

    def command_complete
      len = read_i32
      tag = read_string
    end

    def data_row
      columns = Array(String?).new
      len = read_i32
      num = read_i16
      while num > 0
        l = read_i32
        if l < 0
          columns << nil
        else
          columns << String.new(read_bytes(l), "UTF8")
        end
        num -= 1
      end
      columns
    end

    def row_description
      fields = Array(Field).new
      len = read_i32
      num = read_i16
      while num > 0
        fields << get_field
        num -= 1
      end
      fields
    end

    def get_field
      name     = read_string
      table    = read_i32
      column   = read_i16
      type     = read_i32
      typelen  = read_i16
      modifier = read_i32
      format   = read_i16
      p name
      p type
      Field.new(name, table, column, type, typelen, modifier, format)
    end

  end
end

