module Endive

  module Router

    class TreeRouter < Endive::Router::AbstractRouter
      def initialize
        @hash = {}
      end

      def add_route(methods, path, controller, action, options = {})

        Array.wrap(methods).each do |method|
          method = method.to_s
          @hash[method] ||= {}
          @hash[method][path] = { controller: controller, action: action, options: options }
        end

      end

      def find_route(method, path)
        @hash[method.to_s][path]
      end

    end

  end

end