module PG

  class Connection

    def open(user : String, password : String, dbname : String, application : String ) : Bool
      arg = "user\u0000#{user}\u0000database\u0000#{dbname}\u0000application_name\u0000#{application}\u0000client_encoding\u0000UTF8\u0000"
#    p arg
      write_i32 arg.size + 8 + 1
      write_i32 0x30000
      soc << arg
      write_null
      soc.flush

      established = false
      loop do
          response = read_byte
          #p response.chr
          #p established
          break if response.nil?
          # p response.chr
          case response
          when 'K' ### BackendKeyData
            backend_key_data
          when 'R' ### Authentication
            authentication(password)
          when 'S' ### ParameterStatus
            parameter_status
          when 'Z' ### ReadyForQuery
            ready_for_query
            established = true
            break
          else
            raise AuthenticationError.new("Authentication error for user #{user} and database #{dbname}")
          end
      end
      return established 
    end


    private def authentication(password)
      len = read_i32
      ret = read_i32
      send_password(password)
    end

    private def parameter_status
      len = read_i32
      read_string
      read_string
    end
    
    private def backend_key_data
      len = read_i32
      id  = read_i32
      #p id
      secret = read_i32
    end

    private def ready_for_query
      len = read_i32
      status = read_byte
      #p status.chr
    end

  end
end

