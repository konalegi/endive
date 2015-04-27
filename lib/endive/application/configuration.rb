module Endive
  class Application
    class Configuration

      attr_accessor :root
      attr_accessor :router, :view_path

      def initialize()
        @view_path = "app/views"
      end

      def load_database_configs()
        @db_config ||= load_yaml("#{root}/config/database.yml")
      end

      def db_config
        @db_config[Endive.env]
      end

      def run_initializers()
        Dir.glob("#{root}/config/initializers/**/*.rb"){ |file| require(file) }
      end

      def load_routes()
        require "#{root}/config/routes.rb"
        @router ||= Endive::Routing::Mapping::Mapper.instance.router
      end

      private
        def load_yaml(path)
          yaml = Pathname.new(path) if path

          config = if yaml && yaml.exist?
            require "yaml"
            require "erb"
            YAML.load(ERB.new(yaml.read).result) || {}
          else
            raise "Could not load database configuration. No such file - #{path}"
          end

          config
        end

    end
  end
end