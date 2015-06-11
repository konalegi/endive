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
      rescue Exception => ex
        Endive.logger.error "some unhandled exception in handle_connection: #{ex}"
        connection.close
      end

      def handle_request(request, connection)
        return if request.websocket?
        handle_http_request(request)
      end

      def handle_http_request(request)
        Support::Profiler.execution_time "#{request.method} #{request.path} Processed In: %s ms" do
          request.respond *@app.serve(request)
        end
      rescue RuntimeError => e
        Endive.logger.error e
        request.respond 500, '', {}
      end

      def handle_websocker_request
      end

    end
  end
end