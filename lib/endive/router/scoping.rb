module Endive
  module Router
    module Scoping
      def scope(*args)
        options = args.extract_options!.dup
        scope = {}

        options[:path] = args.flatten.join('/') if args.any?
        options[:constraints] ||= {}


        @scope.options.each do |option|
          if option == :blocks
            value = block
          elsif option == :options
            value = options
          else
            value = options.delete(option)
          end
          if value
            scope[option] = send("merge_#{option}_scope", @scope[option], value)
          end
        end

        @scope = @scope.new scope
        yield
        self
      ensure
        @scope = @scope.parent
      end

      def namespace(path, options = {})
        path = path.to_s

        defaults = {
          module:         path,
          path:           options.fetch(:path, path),
          as:             options.fetch(:as, path),
        }

        scope(defaults.merge!(options)) { yield }
      end

      private
        def merge_path_scope(parent, child) #:nodoc:
          Mapper.normalize_path("#{parent}/#{child}")
        end

        def merge_shallow_path_scope(parent, child) #:nodoc:
          Mapper.normalize_path("#{parent}/#{child}")
        end

        def merge_as_scope(parent, child) #:nodoc:
          parent ? "#{parent}_#{child}" : child
        end

        def merge_shallow_prefix_scope(parent, child) #:nodoc:
          parent ? "#{parent}_#{child}" : child
        end

        def merge_module_scope(parent, child) #:nodoc:
          parent ? "#{parent}/#{child}" : child
        end

        def merge_controller_scope(parent, child) #:nodoc:
          child
        end

        def merge_action_scope(parent, child) #:nodoc:
          child
        end

        def merge_path_names_scope(parent, child) #:nodoc:
          merge_options_scope(parent, child)
        end

        def merge_constraints_scope(parent, child) #:nodoc:
          merge_options_scope(parent, child)
        end

        def merge_defaults_scope(parent, child) #:nodoc:
          merge_options_scope(parent, child)
        end

        def merge_blocks_scope(parent, child) #:nodoc:
          merged = parent ? parent.dup : []
          merged << child if child
          merged
        end

        def merge_options_scope(parent, child) #:nodoc:
          (parent || {}).except(*override_keys(child)).merge!(child)
        end

        def merge_shallow_scope(parent, child) #:nodoc:
          child ? true : false
        end

        def override_keys(child) #:nodoc:
          child.key?(:only) || child.key?(:except) ? [:only, :except] : []
        end
    end
  end
end