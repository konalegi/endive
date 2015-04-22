module Endive
  module Server
    class ConnectionHandler
      include Celluloid
      include Celluloid::Logger

      def initialize(app)
        @app = app
      end

      def handle_connection(connection)
        connection.each_request { |req| handle_request(Server::ReelRequest.new(req), connection) }
      rescue Reel::SocketError
        connection.close
      end

      def handle_request(request, connection)
        return if request.websocket?
        handle_http_request(request)
      end

      def handle_http_request(request)
        status, response_data, headers = @app.serve(request.method, request.params, request)
        request.respond status, headers, response_data
      end

      def handle_websocker_request
      end

    end
  end
end