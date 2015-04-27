module Endive
  module Routing
    module Journey
      module TreeRouter

        class Tree
          def initialize
            @root_node = TreeRouter::Node.new(root: true)
          end

          def add_to_tree(method, path, data)
            path_nodes = prepare_paths(method, path)
            current_node  = @root_node
            path_nodes.each do |_path|
              child = current_node.get_child(_path)
              current_node = child and next if child
              current_node = current_node.set_child(_path)
            end
            current_node.data = data
          end

          def find_by_path(method, path)
            path_nodes = prepare_paths(method, path)
            current_node, opts  = @root_node, {}

            path_nodes.each do |_path|
              current_node = current_node.get_child(_path)
              raise RouteNotFound.new("Path #{path} not found at point #{_path}") unless current_node
              opts[current_node.unparameterized_path] = _path if current_node.parameterized?
            end
            current_node.data.merge(opts)
          end

          def prepare_paths(method, path)
            path_nodes = path.split(/\//).reject {|x| x.blank? }
            path_nodes.unshift(method)
          end

        end
      end
    end
  end
end