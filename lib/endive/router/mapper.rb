module Endive
  module Router
    class Mapper
      attr_reader :router

      class << self
        attr_reader :instance

        def build(&block)
          @instance = new block
        end

        def normalize_path(path)
          path = "/#{path}"
          path.squeeze!('/')
          path.sub!(%r{/+\Z}, '')
          path = '/' if path == ''
          path
        end
      end

      def initialize(block)
        @router = Endive::Router::TreeRouter.new
        @scope = Endive::Router::Scope.new({})
        @concerns = {}
        @nesting = []

        instance_eval &block
      end

      include Endive::Router::HttpHelpers
      include Endive::Router::Scoping
      include Endive::Router::Resources
    end
  end
end