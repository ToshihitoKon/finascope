# frozen_string_literal: true

require "openssl"
require "base64"

class UserHash
  def initialize(uid)
    raise ArgumentError, "uid is nil" if uid.nil?

    @base_uid = uid
    @key = Digest::SHA256.digest(user_hash + Constants::HASH[:fixed_salt])
  end

  def user_hash
    @user_hash ||= Digest::SHA256.hexdigest(@base_uid + Constants::HASH[:user_salt])[0..23]
  end

  def user_info_hash
    @user_info_hash ||= Digest::SHA256.hexdigest(@base_uid + Constants::HASH[:user_infromation_salt])[0..23]
  end

  # Encrypted data layout (Base64-encoded):
  #   [IV: 12 bytes] + [ciphertext: N bytes] + [GCM auth_tag: 16 bytes]
  def encrypt(data)
    cipher = OpenSSL::Cipher.new(Constants::HASH[:algorithm])
    cipher.encrypt
    cipher.key = @key
    iv = OpenSSL::Random.random_bytes(12)
    cipher.iv = iv
    ciphertext = cipher.update(data) + cipher.final
    auth_tag = cipher.auth_tag
    Base64.strict_encode64(iv + ciphertext + auth_tag)
  end

  def decrypt(base64_data)
    raw = Base64.decode64(base64_data)
    iv = raw[0, 12]
    auth_tag = raw[-16, 16]
    ciphertext = raw[12, raw.bytesize - 28]
    cipher = OpenSSL::Cipher.new(Constants::HASH[:algorithm])
    cipher.decrypt
    cipher.key = @key
    cipher.iv = iv
    cipher.auth_tag = auth_tag
    cipher.update(ciphertext) + cipher.final
  end
end
