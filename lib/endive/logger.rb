module Endive
  class Logger
    include Celluloid::Logger
    include Singleton

    def level=(value)
      levels = { debug: 0, info: 1, warn: 2, error: 3 }
      Celluloid.logger.level = levels[value]
    end

    def log_file=(value)
      Celluloid.logger = value
    end

    def debug(msg)
      super
    end

    def info(msg)
      super
    end

    def warn(msg)
      super
    end

    def error(msg)
      super
    end

  end
end