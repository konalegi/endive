module Endive
  module Support
    class AllowCors
      def self.headers
        h = {}
        h['Access-Control-Allow-Origin'] = '*'
        h['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
        h['Access-Control-Request-Method'] = '*'
        h['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization, JWTAuthorization'
        h['Access-Control-Max-Age'] = (60*60*24*7).to_s
        h
      end
    end
  end
end