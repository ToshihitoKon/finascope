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

  def encrypt(data)
    cipher = OpenSSL::Cipher.new(Constants::HASH[:algorithm])
    cipher.encrypt
    cipher.key = @key
    cipher.iv = Constants::HASH[:fixed_iv]
    Base64.strict_encode64(cipher.update(data) + cipher.final)
  end

  def decrypt(base64_data)
    cipher = OpenSSL::Cipher.new(Constants::HASH[:algorithm])
    cipher.decrypt
    cipher.key = @key
    cipher.iv = Constants::HASH[:fixed_iv]
    cipher.update(Base64.decode64(base64_data)) + cipher.final
  end
end
