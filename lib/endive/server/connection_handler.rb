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
        tm_start = Time.now.to_f
        request.respond *@app.serve(request.method, request.params, request)
        request_time = (Time.now.to_f - tm_start)*1000
        info "#{request.method} #{request.path} processed in #{request_time.round(2)} ms"
      rescue RuntimeError => e
        # here frow Internal Server Error
        request.respond 500, '', {}
      end

      def handle_websocker_request
      end

    end
  end
end