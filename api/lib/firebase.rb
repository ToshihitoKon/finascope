require "net/http"
require "uri"
require "jwt"
require "json"

# https://firebase.google.com/docs/auth/admin/verify-id-tokens?hl=ja#verify_id_tokens_using_a_third-party_jwt_library
class Firebase
  class << self
    def jwks
      return @jwks if @jwks

      url = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
      res = Net::HTTP.get_response(URI.parse(url))
      raise Exceptions::InternalServerError.exception("failed to download Firebase jwk") if res.code != "200"

      @jwks = JSON.parse(res.body)
    end

    def decode_jwt(jwt)
      JWT.decode(jwt, nil, true, { algorithm: "RS256", jwks: jwks })
    rescue JWT::DecodeError => e
      raise Exceptions::InternalServerError.exception("failed to decode JWT: #{e}")
    end
  end
end
