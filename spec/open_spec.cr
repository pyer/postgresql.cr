
require "minispec"
require "../src/connection.cr"
require "../src/close.cr"
require "../src/open.cr"
require "../src/error.cr"

test "Default user" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  status = conn.open(user: "spec", password: "spec", dbname: "specdb", application: "spec")
  assert status
  conn.close
end

test "User" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  status = conn.open(user: "spec", password: "spec", dbname: "specdb", application: "spec")
  assert status
  conn.close
end

test "Database" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  status = conn.open(user: "spec", password: "spec", dbname: "specdb", application: "spec")
  assert status
  conn.close
end

test "Unknown user" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  assert_raise PG::AuthenticationError do
    status = conn.open(user: "unknown_user", password: "xyz", dbname: "specdb", application: "spec")
  end
  refute status
end

test "Wrong password" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  assert_raise PG::AuthenticationError do
    status = conn.open(user: "spec", password: "xyz", dbname: "specdb", application: "spec")
  end
  refute status
end

test "Unknown database" do
  conn = PG::Connection.new(host: nil, port: nil)
  refute conn.nil?
  status = false
  assert_raise PG::AuthenticationError do
    status = conn.open(user: "spec", password: "spec", dbname: "unknown_database", application: "spec")
  end
  refute status
end

