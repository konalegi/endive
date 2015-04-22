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

    # status, response_data, headers
    def serve(meth, params, request)
      [:ok, 'sdasd', {}]
    end

  end
end