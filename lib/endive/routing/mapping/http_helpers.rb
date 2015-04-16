module Endive
  module Routing
    module Mapping
      module HttpHelpers

        def get(*args, &block)
          map_method(:get, args, &block)
        end

        def post(*args, &block)
          map_method(:post, args, &block)
        end

        def patch(*args, &block)
          map_method(:patch, args, &block)
        end

        def put(*args, &block)
          map_method(:put, args, &block)
        end

        def delete(*args, &block)
          map_method(:delete, args, &block)
        end

        private
          def map_method(method, args, &block)
            options = args.extract_options!
            options[:via] = method
            match(*args, options, &block)
            self
          end
      end
    end
  end
end