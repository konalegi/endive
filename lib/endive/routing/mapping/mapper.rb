module Endive
  module Routing
    module Mapping
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
          @scope = Mapping::Scope.new({ path_names: {}})
          @concerns = {}
          @nesting = []

          instance_eval &block
        end

        include Mapping::HttpHelpers
        include Mapping::Scoping
        include Mapping::Concerns
        include Mapping::Resources
      end
    end
  end
end