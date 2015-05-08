module Endive
  module Testing
    class ControllerTestBase < Minitest::Test
      attr_reader :data, :headers, :status

      [:get, :post, :put, :delete].each do |meth|
        define_method meth do |path, params = {}|
          found_route = Endive.application.config.router.find_route(meth, path)
          found_route[:options].merge!(params)
          responder = Dispatch::Responder.new(found_route[:controller], found_route[:action])
          @status, @data, @headers = responder.dispatch(found_route)
        end
      end

      def assert_response(status)
        assert_equal status, @status
      end

    end
  end
end
