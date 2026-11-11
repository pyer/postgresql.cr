module PG

  class AuthenticationError < Exception
  end

  class ConnectionError < Exception
  end

  # Raised when an established connection is lost
  # probably due to socket/network issues.
  class ConnectionLost < Exception
  end

  class QueryError < Exception
  end

  class FrameError < Exception
  end

  class RuntimeError < Exception
  end

  class CommitError < Exception
  end

  class RollbackError < Exception
  end

end
