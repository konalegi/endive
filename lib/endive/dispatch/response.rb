module Endive
  module Dispatch
    class Response
      attr_accessor :body, :headers, :status

      def initialize
        @body = nil
        @headers = {}
        @status = nil
      end

    end
  end
end