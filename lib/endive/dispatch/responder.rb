require 'cgi'
module Endive
  module Dispatch
    class Responder

      include Celluloid::Logger

      # should initilized with ControllerPath and ActionName
      def initialize controller_path, action_name, ext = '.json.jbuilder'
        @controller_path = controller_path
        @action_name = action_name.to_sym
        @ext = ext
      end

      def dispatch(params)
        ctrl = controller_class.new(params)
        info "Processing by #{ctrl.class.to_s} action: #{@action_name}, params: #{params}"
        ctrl.send(@action_name)
        ctrl.render(view_path)
        ctrl.headers["Content-Type"] = "application/json; charset=utf-8"
        [ctrl.status, ctrl.data, ctrl.headers]
      end

      private

      def controller_class
        @controller_class ||= begin
          class_names = @controller_path.split('/')
          controller_class_name = [class_names.map(&:camelize).join('::'), 'Controller'].join
          Object.const_get(controller_class_name)
        end
      end

      def view_path
        @view_path ||= File.join(Endive.root, Endive.application.config.view_path, @controller_path, [@action_name, @ext].join)
      end
    end
  end
end