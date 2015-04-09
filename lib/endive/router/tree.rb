module Endive
  class Router

    class Tree
      attr_accessor :children, :value

      def initialize(v)
        @value = v
        @children = {}
      end
    end


    module TreeRoutes

      def routes
        @routes ||= new_tree
      end

      def new_tree
        t = Tree.new({ to: nil, path: nil, method: nil })
        t.children['get'] = Tree.new({ to: nil, path: nil, method: 'get' })
        t.children['post'] = Tree.new({ to: nil, path: nil, method: 'post' })
        t.children['put'] = Tree.new({ to: nil, path: nil, method: 'put' })
        t.children['delete'] = Tree.new({ to: nil, path: nil, method: 'delete' })
        t
      end

      def add_route(method, path, controller_action)
        path = path.to_s
        scopes = path.split('/')

        current_tree = routes.children[method]
        current_path = ''


        scopes[1..scopes.size].each do |scope|
          current_path += "/#{scope}"

          current_tree.children[scope] ||= Tree.new({ to: nil, path: current_path })
          current_tree = current_tree.children[scope]

        end

        current_tree.value = { method: method, to: controller_action, path: path }
      end


      def show_tree tree
        return if tree.nil?

        p tree.value if tree.value[:to].present?

        tree.children.keys.each do |key|
          show_tree tree.children[key]
        end

      end


      def find_route(method, path)
        result = { params: { }, path: path, method: method, to: nil }


        current_tree = routes.children[method.to_s]
        scopes = path.split('/')


        scopes[1..scopes.size].each do |scope|

          child_tree = current_tree.children[scope]

          if child_tree.present?
            current_tree = child_tree
          else

            param_scope = find_param_scope current_tree

            if param_scope.present?
              result[:params].merge!({ param_scope[1..param_scope.size] => scope })
              current_tree = current_tree.children[param_scope]
            else
              return result
            end

          end

        end

        result[:to] = current_tree.value[:to]
        result
      end


      def find_param_scope tree

        tree.children.keys.each do |key|

          return key if key[0] == ':'

        end

        nil
      end

    end


  end
end