module Endive
  module Dispatch
    class BaseController
      include Celluloid::Logger
      attr_reader :headers, :params, :data

      def initialize(params)
        @params = params
        @headers = {}
        @data = {}
      end

      def render(view_path, options = {})
        view_path = File.join(ROOT_DIR, Endive::VIEWS_DIR, [view_path, Endive::TEMPLATE_DEFAULT_EXT].join)
        @data = Jbuilder.new { |json| eval(File.read(view_path)) }.target!
      end

    end
  end
end
