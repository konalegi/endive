module Endive
  class Router
    module BaseMethod

      HTTPABLE = [:get, :post, :put, :delete, :options]

      HTTPABLE.each do |m|

        define_method m do |path, options = {}, &block|

          options = @options.merge options if @options.present?

          mod = options[:module].to_s
          scope = options[:scope].to_s
          controller_name =  build_controller_name(options)
          action_name = options[:action] || path


          path =  "/#{path}" if path[0] != '/'
          path = scope + path if scope.present?



          options[:to] = "#{controller_name}##{action_name}" if options[:to].nil?

          path = ::Mustermann.new path

          self.class.add_route m.to_s, path, options[:to]

        end

      end

    end

  end
end