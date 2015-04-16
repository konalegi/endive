module Endive
  module Router
    class Mapper
      attr_reader :router

      class << self
        attr_reader :instance

        def build(router_class, &block)
          @instance = new(router_class, &block)
        end

        def normalize_path(path)
          path = "/#{path}"
          path.squeeze!('/')
          path.sub!(%r{/+\Z}, '')
          path = '/' if path == ''
          path
        end
      end

      def initialize(router_class, &block)
        raise ArgumentError.new('no block given') unless block_given?
        @router = router_class.new
        @scope = Endive::Router::Scope.new({ path_names: {}})
        @concerns = {}
        @nesting = []

        instance_eval &block
      end

      include Endive::Router::HttpHelpers
      include Endive::Router::Scoping
      include Endive::Router::Concerns
      include Endive::Router::Resources
    end
  end
end