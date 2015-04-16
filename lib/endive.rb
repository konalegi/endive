require 'reel'
require 'mustermann'
require 'jbuilder'
require 'minitest/autorun'

require 'endive/version'
require 'endive/core_ext'
require 'endive/dispatch'
require 'endive/routing'
require 'endive/support'
require 'endive/testing'


module Endive

  GET =     'GET'
  POST =    'POST'
  PUT =     'PUT'
  DELETE =  'DELETE'
  OPTIONS = 'OPTIONS'
  TEMPLATE_DEFAULT_EXT = '.json.jbuilder'
  VIEWS_DIR = 'app/views'

  class HttpServer < Reel::Server::HTTP
    include Celluloid::Logger


    def initialize(options = {})
      options = options.merge({
                                  ip: '127.0.0.1',
                                  port: 3000,
                                  pool_size: 10
                              })

      @connectionPool = ConnectionHandler.pool(size: options[:pool_size])

      info "listening on #{options[:ip]}:#{options[:port]}"
      super(options[:ip], options[:port], &method(:on_connection))
    end

    def on_connection(connection)
      connection.detach
      @connectionPool.async.handle_connection(connection)
    end

  end
end

