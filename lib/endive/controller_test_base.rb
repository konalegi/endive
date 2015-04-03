module Endive
  class ControllerTestBase < Minitest::Test

    RESPONSE_STATUSES = {
        success: 200, created: 201,
        not_found: 404, unprocessable_entity: 422,
        forbidden: 403, unauthorized: 401
    }

    class NotFoundRoute < RuntimeError; end


    attr_reader :data, :headers



    [:get, :post, :put, :delete].each do |meth|

      define_method meth do |path, params = {}|
        # path = path + ".json" if params[:format] == :json

        mustermann = Mustermann.new path
        controller_action = Endive::Router.routes[meth.to_s][mustermann]

        if controller_action.present?
          options = { to: controller_action }
          responder = Endive::Responder.new mustermann, options
          @data, @headers = responder.dispatch(params)
        else
          raise NotFoundRoute
        end

      end
    end


    def assert_response status
      assert_equal RESPONSE_STATUSES[status], headers[:code]
    end


  end
end
