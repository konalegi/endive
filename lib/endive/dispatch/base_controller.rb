require 'endive/support/callbacks'
module Endive
  module Dispatch
    class BaseController
      include Endive::Support::Callbacks

      define_callback :before_action
      define_callback :after_action

      attr_reader :params, :request, :response

      def initialize(params, request)
        @params = Support::SymHash.new(params)
        @request = request
        @response = Endive::Dispatch::Response.new
        @data = nil
        @headers = {}
      end

      def render(options, extra_options = {})
        if options.kind_of? String
          response.body ||= Jbuilder.new { |json| eval(File.read(full_path_to_view(options))) }.target!
          response.status = extra_options[:status] || :ok
        elsif options.kind_of? Hash and options[:json].present?
          response.body ||= options[:json].to_json
          response.status = options[:status] || :ok
        else
          raise ArgumentError
        end

      end

      private

      def full_path_to_view(view_path)
        File.join(Endive.root, Endive.application.config.view_path, [view_path, '.json.jbuilder'].join)
      end

    end
  end
end
