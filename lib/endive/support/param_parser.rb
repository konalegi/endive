module Endive
  module Support
    class ParamsParser
      require 'cgi'
      class << self

        JSON_TYPE               = 'application/json'
        FORM_TYPE               = 'application/x-www-form-urlencoded'
        CONTENT_TYPE_HEADER_KEY = 'Content-Type'

        def get_params method, headers, query_string, body
          case method
          when :get, :detete, :options
            parse_request query_string
          when :post, :put
            parse_request query_string, headers, body
          end
        end

        def parse_request query_string, headers = nil, body = nil
          complete_request_hash = parse_formencoded(query_string || '')
          return complete_request_hash unless body
          complete_request_hash.merge(parse_post_body(body, headers[CONTENT_TYPE_HEADER_KEY]))
        end

        def parse_post_body body, content_type_header
          content_types = content_type_header ? content_type_header.split(';') : []
          body = body.to_s

          return {} if body.blank?

          return parse_formencoded(body) if content_types.include?(FORM_TYPE)
          return SymHash.new(JSON.parse(body)) if content_types.include?(JSON_TYPE)

          {}
        end

        def parse_formencoded str
          str.split('&').reduce(Endive::Support::SymHash.new) do |p, kv|
            key, value = kv.split('=').map {|s| CGI.unescape s}
            p[key] = value
            p
          end
        end

      end
    end
  end
end