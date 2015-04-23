require 'endive/routing/journey/tree_router/tree'
require 'endive/routing/journey/tree_router/node'

module Endive
  module Routing
    module Journey
      module TreeRouter
        class Router < Journey::AbstractRouter
          def initialize
            @template_hash = {}
            @tree = TreeRouter::Tree.new
          end

          def add_route(methods, path, controller, action, options = {})
            Array.wrap(methods).each do |method|
              method = method.to_s
              @template_hash[method] ||= {}
              params = { controller: controller, action: action, options: options }
              @template_hash[method][path] = params
              @tree.add_to_tree(method, path, params)
            end
          end

          def find_route_template(method, path)
            method = method.to_s
            @template_hash[method.to_s][path]
          end

          def find_route(method, path)
            method = method.to_s
            @tree.find_by_path(method, path)
          end

        end
      end
    end
  end
end