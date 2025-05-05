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
      puts res.inspect
      raise Exceptions::InternalServerError.exception("failed to download Firebase jwk") if res.code != "200"

      @jwks = JSON.parse(res.body)
    end

    def decode_jwt(jwt)
      payload = JWT.decode(jwt, nil, true, { algorithm: "RS256", jwks: jwks })
      header = payload[0]

      raise JWT::DecodeError.exception("aud not match") if header["aud"] != "temama-finascope"
      raise JWT::DecodeError.exception("iss not match") if header["iss"] != "https://securetoken.google.com/temama-finascope"

      { uid: header["user_id"], name: header["name"], picture_url: header["picture"] }
    rescue JWT::DecodeError => e
      raise Exceptions::InternalServerError.exception("failed to decode JWT: #{e}")
    end
  end
end
