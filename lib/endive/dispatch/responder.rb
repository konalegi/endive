require 'cgi'
module Endive
  module Dispatch
    class Responder

      include Celluloid::Logger

      # should initilized with ControllerPath and ActionName
      def initialize controller_path, action_name
        @controller_path = controller_path
        @action_name = action_name.to_sym
      end

      def dispatch(params)
        ctrl = controller_class.new(params)
        Endive.logger.info "Processing by #{ctrl.class.to_s} action: #{@action_name}, params: #{params}"

        Support::Profiler.execution_time "#{ctrl.class.to_s}##{@action_name} Run In: %s ms" do
          ctrl.send(@action_name)
        end

        Support::Profiler.execution_time "View: #{view_path} Rendered in: %s ms" do
          ctrl.render(view_path)
        end

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
        @view_path ||= File.join(@controller_path, @action_name.to_s)
      end
    end
  end
end