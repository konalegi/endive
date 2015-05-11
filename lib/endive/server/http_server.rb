module Endive
  module Server
    class HttpServer < Reel::Server::HTTP
      include Celluloid::Logger

      def initialize(app, options = {})

        options = { ip: '127.0.0.1', port: 3000 }.merge(options)

        @connectionPool = ConnectionHandler.pool(args: [app])

        info "listening on #{options[:ip]}:#{options[:port]}"
        super(options[:ip], options[:port], &method(:on_connection))
      end

      def on_connection(connection)
        connection.detach
        @connectionPool.async.handle_connection(connection)
      end
    end
  end
end