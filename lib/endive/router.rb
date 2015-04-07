require 'endive/router/base_method'
require 'endive/router/helper'
require 'endive/router/tree'


module Endive
  class Router
    include BaseMethod
    include Helper
    extend TreeRoutes

    DEFAULT_ACTIONS = [:index, :show, :destroy, :update, :create]




    def self.build(&block)
      @routes_tree = nil
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

  end
end