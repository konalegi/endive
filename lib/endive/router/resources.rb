module Endive

  module Router

    module Resources

      RESOURCE_OPTIONS  = [:as, :controller, :path, :only, :except, :param, :concerns]
      CANONICAL_ACTIONS = %w(index create new show update destroy)

      class Resource #:nodoc:
        attr_reader :controller, :path, :options, :param

        def initialize(entities, options = {})
          @name       = entities.to_s
          @path       = (options[:path] || @name).to_s
          @controller = (options[:controller] || @name).to_s
          @as         = options[:as]
          @param      = (options[:param] || :id).to_sym
          @options    = options
        end

        def default_actions
          [:index, :create, :show, :update, :destroy]
        end

        def actions
          if only = @options[:only]
            Array(only).map(&:to_sym)
          elsif except = @options[:except]
            default_actions - Array(except).map(&:to_sym)
          else
            default_actions
          end
        end

        def resource_scope
          { :controller => controller }
        end

        def member_scope
          "#{path}/:#{param}"
        end

        alias :collection_scope :path
      end

      class SingularResource < Resource
      end

      def resources(*resources, &block)
        options = resources.extract_options!.dup

        resource_scope(:resources, Resource.new(resources.pop, options)) do
          yield if block_given?

          concerns(options[:concerns]) if options[:concerns]

          collection do
            get  :index if parent_resource.actions.include?(:index)
            post :create if parent_resource.actions.include?(:create)
          end

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

        self
      end

      def parent_resource #:nodoc:
        @scope[:scope_level_resource]
      end

      def path_for_action(action, path) #:nodoc:
        if path.blank? && canonical_action?(action)
          @scope[:path].to_s
        else
          "#{@scope[:path]}/#{action_path(action, path)}"
        end
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
      end

      def collection
        with_scope_level(:collection) do
          scope(parent_resource.collection_scope) do
            yield
          end
        end
      end

      def with_scope_level(kind)
        @scope = @scope.new_level(kind)
        yield
      ensure
        @scope = @scope.parent
      end

      def member
        unless resource_scope?
          raise ArgumentError, "can't use member outside resource(s) scope"
        end

        with_scope_level(:member) do
          scope(parent_resource.member_scope) { yield }
        end
      end

      def resource_scope? #:nodoc:
        @scope.resource_scope?
      end

      def action_path(name, path = nil) #:nodoc:
        name = name.to_sym if name.is_a?(String)
        path || @scope[:path_names][name] || name.to_s
      end

      def resource_method_scope? #:nodoc:
        @scope.resource_method_scope?
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
          route_options[:path] = Endive::Router::Mapper.normalize_path(route_options[:path])
          add_route(_path, route_options)
        end
        self
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
        path  = Endive::Router::Mapper.normalize_path(path)
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

    end

  end

end