require 'cgi'
module Endive
  class ParamsParser
    EMPTY_JSON = '{}'
    CONTENT_TYPE_HEADER_KEY = 'Content-Type'

    GET =     'GET'
    POST =    'POST'
    PUT =     'PUT'
    DELETE =  'DELETE'
    OPTIONS = 'OPTIONS'

    JSON_TYPE = 'application/json'
    FORM_TYPE = 'application/x-www-form-urlencoded'

    attr_reader :request

    def initialize(request)
      @request = request
    end


    def get_params
      case request.method
        when GET, DELETE, OPTIONS
          parse_query_string
        when POST, PUT
          parse_query_string_and_post_body
        end
    end

    def parse_formencoded str
      str.split('&').reduce(Endive::SymHash.new) do |p, kv|
        key, value = kv.split('=').map {|s| CGI.unescape s}
        p[key] = value
        p
      end
    end

    def parse_query_string
      parse_formencoded(request.query_string || '')
    end

    def parse_post_body
      body = request.body.to_s
      case
      when form_encoded?
        parse_formencoded body
      when json? && !body.empty?
        SymHash.new JSON.parse body
      else
        {}
      end
    end

    def parse_query_string_and_post_body
      parse_query_string.merge! parse_post_body
    end

    def form_encoded?
      content_type? FORM_TYPE
    end

    def json?
      content_type? JSON_TYPE
    end

    def content_type? type
      if request.headers[CONTENT_TYPE_HEADER_KEY]
        request.headers[CONTENT_TYPE_HEADER_KEY].split(';').include? type
      else
        nil
      end
    end


  end
end