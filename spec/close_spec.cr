
require "minispec"
require "../src/connection.cr"
require "../src/close.cr"
require "../src/error.cr"

test "Close established connection" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  assert conn.connected
  conn.close
  refute conn.connected
end

