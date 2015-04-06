module Endive
  class Router

    def self.routes
      @routes ||= Hash.new
    end

    def self.add_route(method, path, controller_action)
      hash = routes[method] || Hash.new
      routes[method] = hash
      hash[path] = controller_action
    end


    def self.find_route(method, path)
      routes[method.to_s].keys.select { |k| k.match(path.to_s) }.first
    end


    HTTPABLE = [:get, :post, :put, :delete, :options]
    DEFAULT_ACTIONS = [:index, :show, :destroy, :update, :create]


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


    def self.build(&block)
      @routes = {}
      builder = new block
    end

    def initialize(block)
      @options = {}
      @concerns = {}
      instance_eval &block
    end

    def resources(name, options = {}, &block)
      options = @options.merge options

      # actions = Array.wrap(options[:only]) || DEFAULT_ACTIONS
      actions = options[:only] || DEFAULT_ACTIONS
      mod = options[:module].to_s
      scope = options[:scope].to_s
      param = options[:param] || 'id'


      get "#{name}", action: :index, controller: name, module: mod, scope: scope  if actions.include? :index
      get "#{name}/:#{param}", action: :show, controller: name, module: mod, scope: scope if actions.include? :show
      post "#{name}", action: :create, controller: name, module: mod, scope: scope if actions.include? :create
      put "#{name}/:#{param}", action: :update, controller: name, module: mod, scope: scope if actions.include? :update
      delete "#{name}/:#{param}", action: :destroy, controller: name, module: mod, scope: scope if actions.include? :destroy



      if block_given?

        @options[:module] = mod.present? ? "#{mod}" : nil
        @options[:controller] = name.to_s
        @options[:scope] = scope + resources_path(name, options)
        @options[:param] = options[:param]

        block.call

        @options[:scope] = scope
        @options[:param] = nil

      end

    end


    def resource(name, options = {}, &block)
      options = @options.merge options

      # actions = Array.wrap(options[:only]) || DEFAULT_ACTIONS
      actions = options[:only] || DEFAULT_ACTIONS


      mod = options[:module].to_s
      scope = options[:scope].to_s


      get "#{name}", action: :show, controller: "#{name}s", module: mod, scope: scope if actions.include? :show
      post "#{name}", action: :create, controller: "#{name}s", module: mod, scope: scope if actions.include? :create
      put "#{name}", action: :update, controller: "#{name}s", module: mod, scope: scope if actions.include? :update
      delete "#{name}", action: :destroy, controller: "#{name}s", module: mod, scope: scope if actions.include? :destroy



      if block_given?

        @options[:module] = mod.present? ? "#{mod}" : nil
        @options[:controller] = "#{name}s"
        @options[:scope] = scope + resource_path(name)

        block.call

        @options[:scope] = scope

      end

    end

    def root(action)
      get '/', to: action
    end

    def scope(name, options = {}, &block)
      old_scope = @options[:scope]
      old_module = @options[:module]

      @options[:scope] = concat_scope_names @options[:scope], name
      @options[:module] = concat_module_names @options[:module], options[:module]
      instance_eval(&block)

      @options[:scope] = old_scope
      @options[:module] = old_module
    end


    def namespace(name, options = {}, &block)
      old_scope = @options[:scope]
      old_module = @options[:module]

      @options[:scope] = concat_scope_names @options[:scope], name
      @options[:module] = concat_module_names @options[:module], name
      instance_eval(&block)

      @options[:scope] = old_scope
      @options[:module] = old_module
    end


    def member(&block)
      old_scope = @options[:scope]
      @options[:scope] = scope_for_member old_scope
      instance_eval(&block)
      @options[:on] = nil
      @options[:scope] = old_scope
    end


    def collection(&block)
      old_scope = @options[:scope]
      @options[:scope] = scope_for_collection old_scope
      instance_eval(&block)
      @options[:on] = nil
      @options[:scope] = old_scope
    end


    def concerns *names
      names.each do |name|
        @concerns[name].call
      end
    end

    def concern(name, &block)
      @concerns[name] = lambda &block
    end



    private

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