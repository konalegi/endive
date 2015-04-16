require 'cgi'
module Endive
  module Dispatch
    class Responder

      include Celluloid::Logger
      attr_accessor :opts, :path

      def initialize path, opts = {}
        @path = path
        @opts = opts
        @data = {}
      end

      def dispatch(params)
        ctrl = controller_class.new(params)

        info "Processing by #{ctrl.class.to_s} action : #{action}, params : #{params}"

        ctrl.send(action)
        [ctrl.data, ctrl.headers]
      end

      private

      def controller_class
        @controller_class ||= begin
          path, action = @opts[:to].split('#')
          class_names = path.split('/')
          controller_class_name = [class_names.map(&:camelize).join('::'), 'Controller'].join
          Object.const_get(controller_class_name)
        end
      end

      def action
        @action ||= begin
          path, action = @opts[:to].split('#')
          action
        end
      end

      def view_path
        @view_path ||= begin
          path, action = @opts[:to].split('#')
          File.join(ROOT_DIR, VIEWS_DIR, path, [action, TEMPLATE_DEFAULT_EXT].join)
        end
      end
    end
  end
end