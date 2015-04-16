module Endive
  module Routing
    module Journey
      class AbstractRouter
        def add_route(method, path, controller_and_method, options = {});
          local_variables.each do |var|
            puts eval var.to_s
          end
        end

        def find_route_template(method, path); end
        def find_route(method, path); end

        def print; end
      end
    end
  end
end