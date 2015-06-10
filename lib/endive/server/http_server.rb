module Endive
  module Server
    class HttpServer < Reel::Server::HTTP

      def initialize(app, options = {})

        options = { ip: '127.0.0.1', port: 3000, pool_size: 20 }.merge(options)

        @connectionPool = ConnectionHandler.pool(args: [app], size: options[:pool_size])
        Endive.logger.level = :debug if ENV['ENDIVE_DEBUG']

        Endive.logger.info "listening on #{options[:ip]}:#{options[:port]}"
        super(options[:ip], options[:port], &method(:on_connection))
      end

      def on_connection(connection)
        connection.detach
        @connectionPool.async.handle_connection(connection)
      end
    end
  end
end