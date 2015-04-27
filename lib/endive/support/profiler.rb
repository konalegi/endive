module Endive
  module Support
    class Profiler
      require 'ruby-prof'
      class << self
        def profile_simple &block
          result = RubyProf.profile do
            yield
          end

          # Print a flat profile to text
          printer = RubyProf::FlatPrinter.new(result)
          printer.print(STDOUT)
        end

        def execution_time &block
          now = Time.now.to_f
          yield
          ((Time.now.to_f - now.to_f) * 1000).round(2)
        end

      end
    end
  end
end