
require "minispec"
require "../src/connection.cr"
require "../src/close.cr"
require "../src/error.cr"

test "Close established connection" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  refute conn.socket.closed?
  conn.close
  assert conn.socket.closed?
end

