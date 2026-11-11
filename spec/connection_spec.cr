
require "minispec"
require "../src/connection.cr"
require "../src/close.cr"
require "../src/error.cr"

test "Default connection" do
    conn = PG::Connection.new(host: nil, port: nil)
    conn.close
    refute conn.nil?
end

test "Basic connection" do
    conn = PG::Connection.new(host: "localhost", port: 5432)
    conn.close
    refute conn.nil?
end

test "Wrong host" do
    assert_raise PG::ConnectionError do
      conn = PG::Connection.new(host: "notlocalhost", port: 5432)
    end
end

test "Wrong port" do
    assert_raise PG::ConnectionError do
      conn = PG::Connection.new(host: "localhost", port: 9999)
    end
end

