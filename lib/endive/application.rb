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
      @config.default_logger_config
      @config.load_database_configs
      @config.load_routes
      @config.run_initializers
      @initialized = true
    end

    # should return value in such format:
    # HTTP_STATUS - symbol or integer code of HTTP
    # RESPONSE_DATA - string data
    # HEADERS - http headers of response
    # if any exception is raised, will be catched with upper rescue block and return 500 (Internal Server Error) code
    def serve(request)
      found_route = @config.router.find_route(request.method, request.path)
      found_route.merge!(request.params)
      responder = Dispatch::Responder.new(found_route[:controller], found_route[:action], request)
      status, data, headers = responder.dispatch(found_route)
      [status, headers, data]
    rescue Routing::Journey::RouteNotFound => e
      return [:not_found, '', {}]
    end

  end
end