require 'uber/inheritable_attr'

module Endive
  module Support
    module Callbacks

      def self.included(base)
        base.class_eval do
          extend Uber::InheritableAttr
          extend ClassMethods
          inheritable_attr :_callbacks
          self._callbacks = Hash.new
        end
      end


      module ClassMethods

        def define_callback(name)
          name = name.to_sym
          _callbacks[name] = []

          define_singleton_method(name) do |method_name, options = {}|
            _callbacks[name] << { method_name => options }
          end
        end

        def run_callback(name, instance, options = {})
          name = name.to_sym
          methods = _callbacks[name]
          action_name = options[:action_name]

          methods.each do |method|
            method.each do |method_name, method_options|
              if method_options[:only].present?
                instance.send(method_name) if method_options[:only].include? action_name
              else
                instance.send(method_name)
              end
            end
          end
        end

      end


      def run_callback(name, options = {})
        self.class.run_callback(name, self, options)
      end

    end
  end
end