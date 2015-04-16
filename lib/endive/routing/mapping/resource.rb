module Endive
  module Routing
    module Mapping
      module Resources

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

          def name
            @as || @name
          end

          def plural
            @plural ||= name.to_s
          end

          def singular
            @singular ||= name.to_s.singularize
          end

          alias :member_name :singular

          def resource_scope
            { :controller => controller }
          end

          def member_scope
            "#{path}/:#{param}"
          end

          def nested_param
            :"#{singular}_#{param}"
          end

          def nested_scope
            "#{path}/:#{nested_param}"
          end


          alias :collection_scope :path
        end
      end
    end
  end
end
