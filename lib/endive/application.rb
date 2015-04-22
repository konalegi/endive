module Endive
  class Application
    include Singleton

    def initialize
      @initialized = false
    end

    def initialize!
      # run initializers
      # load routes
      # load database configs

      @initialized = true
    end


    def route!(meth, connection, request)

    end



  end
end