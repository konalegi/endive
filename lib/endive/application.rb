require 'endive/application/configuration'

module Endive
  class Application
    include Singleton

    attr_reader :config

    def initialize
      @initialized = false
      @config = Configuration.new
    end

    def initialize!
      @config.load_database_configs
      @config.run_initializers
      @config.load_routes

      @initialized = true
    end

    # status, response_data, headers
    def serve(meth, params, request)
      found_route = @config.router.find_route(meth, request.path)
      found_route[:options].merge!(request.params)

      [:ok, found_route.to_s, {}]
    end

  end
end