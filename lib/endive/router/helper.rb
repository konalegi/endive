module Endive

  class Router

    module Helper

      def build_controller_name(options = {})
        controller_name = options[:controller].to_s
        mod = options[:module].to_s

        if controller_name.present?
          controller_name = "#{mod}/" + controller_name if mod.present?
        else
          controller_name = "#{mod}" if mod.present?
        end

        controller_name
      end

      def scope_for_member(scope_name)
        return scope_name if @options[:param].present?

        index = scope_name.size - 1

        while(scope_name[index] != ':' and index >= 0)
          index -= 1
        end

        if index > 0
          scope_name = scope_name[0..index - 1] + ':id'
        end

        scope_name
      end

      def scope_for_collection(scope_name)
        index = scope_name.size - 1

        while(scope_name[index] != ':' and index >= 0)
          index -= 1
        end

        if index > 0
          scope_name = scope_name[0..index - 2]
        end

        scope_name
      end

      def concat_module_names(first, second)
        return first unless second.present?
        first.present? ? first.to_s + "/#{second}" : second
      end

      def concat_scope_names(first, second)
        return first unless second.present?
        first.to_s + "/#{second}"
      end


      def resource_path(name)
        "/#{name}"
      end

      def resources_path(name, options = {})
        param = options[:param] || "#{name[0..-2]}_id"
        "/#{name}/:#{param}"
      end


    end

  end

end