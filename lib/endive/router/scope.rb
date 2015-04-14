module Endive
  module Router
    class Scope # :nodoc:
      attr_reader :parent, :scope_level
      RESOURCE_SCOPES = [:resource, :resources]
      OPTIONS = [:path, :module, :controller, :action, :path_names, :defaults, :options]
      RESOURCE_METHOD_SCOPES = [:collection, :member, :new]

      def initialize(hash, parent = {}, scope_level = nil)
        @hash = hash
        @parent = parent
        @scope_level = scope_level
      end

      def new(hash)
        self.class.new hash, self, scope_level
      end

      def resource_scope?
        RESOURCE_SCOPES.include? scope_level
      end

      def resource_method_scope?
        RESOURCE_METHOD_SCOPES.include? scope_level
      end

      def new_level(level)
        self.class.new(self, self, level)
      end

      def fetch(key, &block)
        @hash.fetch(key, &block)
      end

      def [](key)
        @hash.fetch(key) { @parent[key] }
      end

      def []=(k,v)
        @hash[k] = v
      end

      def options
        OPTIONS
      end
    end
  end
end