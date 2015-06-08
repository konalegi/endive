require 'endive/support/callbacks'
module Endive
  module Dispatch
    class BaseController
      include Endive::Support::Callbacks

      define_callback :before_action
      define_callback :after_action

      attr_reader :headers, :params, :data, :status, :request_headers

      def initialize(params, request_headers)
        @params = Support::SymHash.new(params)
        @request_headers = Support::SymHash.new(request_headers)
        @data = nil
      end

      def render(options, extra_options = {})
        if options.kind_of? String
          @data ||= Jbuilder.new { |json| eval(File.read(full_path_to_view(options))) }.target!
        elsif options.kind_of? Hash and options[:json].present?
          @data ||= options[:json].to_json
        else
          raise ArgumentError
        end

        @status = extra_options[:status] || :ok
      end

      def headers
        @headers ||= {}
      end

      private

      def full_path_to_view(view_path)
        File.join(Endive.root, Endive.application.config.view_path, [view_path, '.json.jbuilder'].join)
      end

    end
  end
end
