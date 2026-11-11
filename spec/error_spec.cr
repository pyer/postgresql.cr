
require "minispec"
require "../src/error.cr"

test "AuthenticationError" do
  assert_raise PG::AuthenticationError do
    raise PG::AuthenticationError.new
  end
end

test "ConnectionError" do
  assert_raise PG::ConnectionError do
    raise PG::ConnectionError.new
  end
end

test "ConnectionLost" do
  assert_raise PG::ConnectionLost do
    raise PG::ConnectionLost.new
  end
end

test "QueryError" do
  assert_raise PG::QueryError do
    raise PG::QueryError.new
  end
end

test "FrameError" do
  assert_raise PG::FrameError do
    raise PG::FrameError.new
  end
end

test "RuntimeError" do
  assert_raise PG::RuntimeError do
    raise PG::RuntimeError.new
  end
end

test "CommitError" do
  assert_raise PG::CommitError do
    raise PG::CommitError.new
  end
end

test "RollbackError" do
  assert_raise PG::RollbackError do
    raise PG::RollbackError.new
  end
end

