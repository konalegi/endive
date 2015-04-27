module Endive
  module Dispatch
    class BaseController
      include Celluloid::Logger
      attr_reader :headers, :params, :data, :status

      def initialize(params)
        @params = Support::SymHash.new(params)
        @headers = {}
        @data = {}
      end

      def render(view_path, options = {})
        @status = options[:status] || :ok
        @data = Jbuilder.new { |json| eval(File.read(view_path)) }.target!
      end

      def headers
        @headers ||= {}
      end

    end
  end
end
