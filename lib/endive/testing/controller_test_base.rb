module Endive
  module Testing
    class ControllerTestBase < Minitest::Test
      attr_reader :data, :headers, :status, :request

      def initialize(params)
        super
        @request = Request.new
      end

      [:get, :post, :put, :delete].each do |meth|
        define_method meth do |path, params = {}|
          found_route = Endive.application.config.router.find_route(meth, path)
          found_route[:options].merge!(params)
          request.method = meth
          responder = Dispatch::Responder.new(found_route[:controller], found_route[:action], request)
          @status, @data, @headers = responder.dispatch(found_route)
        end
      end

      def assert_response(status)
        assert_equal status, @status
      end

    end


    class Request
      attr_accessor :headers, :method

      def initialize
        @headers = {}
        @method = nil
      end

      def websocket?
        method == 'websocket'
      end

    end
  end
end
