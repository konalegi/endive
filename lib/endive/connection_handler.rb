module Endive
  class ConnectionHandler
    include Celluloid
    include Celluloid::Logger

    def initialize
    end

    def handle_connection(connection)
      connection.each_request { |req| handle_request(req, connection) }
    rescue Reel::SocketError
      connection.close
    end

    def handle_request(request, connection)
      # RubyProf.start
      meth = request.websocket? ? :websocket : request.method.downcase.to_sym

      start_time = Time.now
      route! meth, connection, request
      end_time = Time.now

      info "Elapsed time #{end_time - start_time} \n"

      # result = RubyProf.stop
      #
      # Print a flat profile to text
      # printer = RubyProf::FlatPrinter.new(result)
      # printer.print(STDOUT)
    end

    def route! meth, connection, request
      info "Start #{meth.upcase} #{request.path}"

      route = Router.find_route meth, request.path
      controller_action = route[:to]
      route_params = route[:params]


      if controller_action.present?
        path = Mustermann.new request.path
        options = { to: controller_action }

        responder = Responder.new path, options
        params = ParamsParser.new(request).get_params
        params.merge!(route_params)

        data, headers = responder.dispatch(params)
        request.respond :ok, headers, data
      else
        connection.respond :not_found, {}, 'not found'
      end
    end

  end
end