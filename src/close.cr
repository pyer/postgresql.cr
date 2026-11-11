module PG

  class Connection
    def close
      @connected = false
      @mutex.synchronize do
        return if @soc.closed?
        send_terminate_message
        @soc.close
      end
    end
  end

end
