require 'ruby-prof'
module Endive
  module Support
    class Profiler

      class << self

        def profile_simple filename = nil, &block
          print_with_printer(RubyProf::FlatPrinter, filename, block)
        end

        def profile_with_graph_printer filename = nil, &block
          print_with_printer(RubyProf::GraphPrinter, filename, block)
        end

        def execution_time msg, &block
          now = Time.now.to_f
          yield
          Endive.logger.debug msg % [((Time.now.to_f - now.to_f) * 1000).round(2)]
        end

        private
          def standart_filename
            "#{Endive.root}/tmp/profile_#{Time.now.to_i}.log"
          end

          def print_with_printer(printer_class, filename, block)
            File.open(filename || standart_filename, 'w') do |file|
              result = RubyProf.profile do
                block.call
              end

              printer = printer_class.new(result)
              printer.print(file)
            end
          end
      end
    end
  end
end