 
require "./connection"
require "./open"
require "./query"
require "./close"
require "./error"

module PG

  # Open a connexion to a database and return this connection
  def self.open(user : String? = nil, password : String? = nil, dbname : String? = nil, application : String? = nil, host : String? = nil, port : Int? = nil)
    conn = Connection.new(host, port)
    us = user   || "postgres"
    pw = password || "***"
    db = dbname || "postgres" 
    ap = application || "crystal" 
    conn.open(us, pw, db, ap)
    return conn
  end

end

