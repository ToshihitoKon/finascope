# frozen_string_literal: true

require "net/http"
require "uri"
require "jwt"
require "json"

# https://firebase.google.com/docs/auth/admin/verify-id-tokens?hl=ja#verify_id_tokens_using_a_third-party_jwt_library
class Firebase
  class << self
    @expires_at = Time.now + 3600 # 1 hour

    def jwks_expired?
      @expires_at < Time.now
    end

    def jwks
      return @jwks if @jwks && !jwks_expired?

      warn "downloading Firebase jwk..."
      url = "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com"
      res = Net::HTTP.get_response(URI.parse(url))
      warn res.inspect
      raise Exceptions::InternalServerError, "failed to download Firebase jwk" if res.code != "200"

      @expires_at = Time.now + 3600 # 1 hour
      warn "expires at: #{@expires_at}"

      @jwks = JSON.parse(res.body)
    end

    def decode_jwt(jwt)
      decoded = JWT.decode(jwt, nil, true, { algorithm: "RS256", jwks: jwks })
      payload = decoded[0]

      raise JWT::DecodeError.exception("aud not match") if payload["aud"] != "temama-finascope"
      raise JWT::DecodeError.exception("iss not match") if payload["iss"] != "https://securetoken.google.com/temama-finascope"

      { uid: payload["user_id"], name: payload["name"], picture_url: payload["picture"] }
    rescue JWT::DecodeError => e
      raise Exceptions::Unauthorized, "failed to decode JWT: #{e}"
    end
  end
end
