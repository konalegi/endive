module Endive
  module Server
    class AbstractRequest

      def params; end
      def method; end
      def body; end
      def query_string; end
      def headers; end
      def repond; end
      def websocket?; end
      def path; end
      def ext; end

    end
  end
end