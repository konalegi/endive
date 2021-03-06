module Endive
  module Server
    class ReelRequest < AbstractRequest
      EXT_REGEXP = /\.(?<ext>[a-z]*)/
      attr_accessor :base_request
      def initialize(base_request)
        @base_request = base_request
      end

      delegate :headers, :respond, :websocket?, :body, :query_string, :path, to: :base_request

      def params
        @params ||= Support::ParamsParser.get_params method, headers, query_string, body
      end

      def method
        @meth ||= @base_request.websocket? ? :websocket : @base_request.method.downcase.to_sym
      end

      def ext
        @ext ||= (EXT_REGEXP =~ @base_request.path ? $1 : nil)
      end

      def path
        @path ||= begin
          if ext
            @base_request.path.gsub(EXT_REGEXP, '')
          else
            @base_request.path
          end
        end
      end

    end
  end
end