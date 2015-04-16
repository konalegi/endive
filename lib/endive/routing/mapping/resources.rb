module Endive
  module Routing

    module Mapping
      module Resources

        RESOURCE_OPTIONS  = [:as, :controller, :path, :only, :except, :param, :concerns]
        CANONICAL_ACTIONS = %w(index create new show update destroy)

        def resources(*resources, &block)
          options = resources.extract_options!.dup

          if apply_common_behavior_for(:resources, resources, options, &block)
            return self
          end

          resource_scope(:resources, Resource.new(resources.pop, options)) do
            yield if block_given?

            concerns(options[:concerns]) if options[:concerns]

            collection do
              get  :index if parent_resource.actions.include?(:index)
              post :create if parent_resource.actions.include?(:create)
            end

            set_member_mappings_for_resource
          end

          self
        end

        def resource(*resources, &block)
          options = resources.extract_options!.dup

          if apply_common_behavior_for(:resource, resources, options, &block)
            return self
          end

          resource_scope(:resource, SingletonResource.new(resources.pop, options)) do
            yield if block_given?

            concerns(options[:concerns]) if options[:concerns]

            collection do
              post :create
            end if parent_resource.actions.include?(:create)

            set_member_mappings_for_resource
          end

          self
        end

        def set_member_mappings_for_resource
          member do
            get :edit if parent_resource.actions.include?(:edit)
            get :show if parent_resource.actions.include?(:show)
            if parent_resource.actions.include?(:update)
              patch :update
              put   :update
            end
            delete :destroy if parent_resource.actions.include?(:destroy)
          end
        end



        def nested_options #:nodoc:
          { :as => parent_resource.member_name }
        end


        def apply_common_behavior_for(method, resources, options, &block) #:nodoc:
          if resources.length > 1
            resources.each { |r| send(method, r, options, &block) }
            return true
          end

          if resource_scope?
            nested { send(method, resources.pop, options, &block) }
            return true
          end

          options.keys.each do |k|
            (options[:constraints] ||= {})[k] = options.delete(k) if options[k].is_a?(Regexp)
          end

          scope_options = options.slice!(*RESOURCE_OPTIONS)
          unless scope_options.empty?
            scope(scope_options) do
              send(method, resources.pop, options, &block)
            end
            return true
          end

          unless action_options?(options)
            options.merge!(scope_action_options) if scope_action_options?
          end

          false
        end

        def canonical_action?(action) #:nodoc:
          resource_method_scope? && CANONICAL_ACTIONS.include?(action.to_s)
        end

        def resource_scope(kind, resource) #:nodoc:
          @scope = @scope.new(:scope_level_resource => resource)
          @nesting.push(resource)

          with_scope_level(kind) do
            scope(parent_resource.resource_scope) { yield }
          end
        ensure
          @nesting.pop
          @scope = @scope.parent
        end

        def nested
          unless resource_scope?
            raise ArgumentError, "can't use nested outside resource(s) scope"
          end

          with_scope_level(:nested) do
            scope(parent_resource.nested_scope, nested_options) { yield }
          end
        end

        def collection
          unless resource_scope?
            raise ArgumentError, "can't use nested outside resource(s) scope"
          end

          with_scope_level(:collection) do
            scope(parent_resource.collection_scope) do
              yield
            end
          end
        end

        def member
          unless resource_scope?
            raise ArgumentError, "can't use member outside resource(s) scope"
          end

          with_scope_level(:member) do
            scope(parent_resource.member_scope) { yield }
          end
        end

        def with_scope_level(kind)
          @scope = @scope.new_level(kind)
          yield
        ensure
          @scope = @scope.parent
        end

        def namespace(path, options = {})
          if resource_scope?
            nested { super }
          else
            super
          end
        end

        # match 'path', controller: :photos, action: :update, via: [:post, :get]
        def match(path, *rest)
          options = rest.extract_options!
          paths = [path] + rest

          if @scope[:controller] && @scope[:action]
            options[:to] ||= "#{@scope[:controller]}##{@scope[:action]}"
          end

          paths.each do |_path|

            route_options = options.dup
            route_options[:path] ||= _path  if _path.is_a?(String)
            decomposed_match(_path, route_options)
          end
          self
        end

        def path_for_action(action, path) #:nodoc:
          if path.blank? && canonical_action?(action)
            @scope[:path].to_s
          else
            "#{@scope[:path]}/#{action_path(action, path)}"
          end
        end

        def action_path(name, path = nil) #:nodoc:
          name = name.to_sym if name.is_a?(String)
          path || @scope[:path_names][name] || name.to_s
        end

        def decomposed_match(path, options) # :nodoc:
          case @scope.scope_level
          when :resources
            nested { decomposed_match(path, options) }
          when :resource
            member { decomposed_match(path, options) }
          else
            add_route(path, options)
          end
        end

        def add_route(action, options)
          path = path_for_action(action, options.delete(:path))
          action = action.to_s.dup

          if action =~ /^[\w\-\/]+$/
            options[:action] ||= action.tr('-', '_') unless action.include?("/")
          else
            action = nil
          end

          controller = generate_controller(options)
          action     = options.delete(:action) || @scope[:action]
          via        = options.delete(:via)
          path  = Mapping::Mapper.normalize_path(path)
          @router.add_route(via, path, controller, action, options)
        end

        def generate_controller(options)

          controller = options.delete(:controller) || @scope[:controller]

          if @scope[:module] && !controller.is_a?(Regexp)
            if controller =~ %r{\A/}
              controller = controller[1..-1]
            else
              controller = [@scope[:module], controller].compact.join('/').presence
            end
          end
          controller
        end

        def action_options?(options) #:nodoc:
          options[:only] || options[:except]
        end

        def scope_action_options? #:nodoc:
          @scope[:options] && (@scope[:options][:only] || @scope[:options][:except])
        end

        def scope_action_options #:nodoc:
          @scope[:options].slice(:only, :except)
        end

        def parent_resource #:nodoc:
          @scope[:scope_level_resource]
        end

        def resource_scope? #:nodoc:
          @scope.resource_scope?
        end

        def resource_method_scope? #:nodoc:
          @scope.resource_method_scope?
        end

      end
    end
  end
end