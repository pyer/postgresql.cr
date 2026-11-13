
require "minispec"
require "../src/pg.cr"

test "User spec" do
  conn = PG.open(user: "spec", password: "spec", dbname: "specdb")
  conn.close
  refute conn.nil?
end

test "Default user" do
  conn = PG.open()
  conn.close
  refute conn.nil?
end

test "Unknown user" do
  assert_raise PG::AuthenticationError do
    conn = PG.open(user: "unknown_user")
  end
end

test "Unknown database" do
  assert_raise PG::AuthenticationError do
    conn = PG.open(dbname: "unknown_database")
  end
end

test "Wrong host" do
  assert_raise PG::ConnectionError do
    conn = PG.open(host: "notlocalhost")
  end
end

test "Wrong port" do
  assert_raise PG::ConnectionError do
    conn = PG.open(host: "localhost", port: 99999)
  end
end

