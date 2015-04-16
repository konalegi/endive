module Endive
  module Routing
    module Journey
      module TreeRouter

        class Node
          attr_accessor :data
          def initialize(options = {})
            @options = options.merge({ root: false })
            @childs = {}
          end

          def path
            @options[:path]
          end

          def unparameterized_path
            parameterized? ? path[1..-1] : path
          end

          def root?
            @options[:root]
          end

          def parent
            @options[:parent]
          end

          def get_child(path)
            @childs.fetch(path) { @parameterized_child }
          end

          def set_child(path)
            opts = { path: path, parent: self }
            if path_parameterized?(path)
              raise ArgumentError.new('Only one parameterized child per node') if @parameterized_child
              @parameterized_child = Node.new(opts)
            else
              @childs[path] = Node.new(opts)
            end

            get_child(path)
          end

          def parameterized?
            path[0] == ':'
          end

          def childs
            @childs.keys + Array.wrap(@parameterized_child.try(:path))
          end

          private
            def path_parameterized?(path)
              path[0] == ':'
            end
        end
      end
    end
  end
end