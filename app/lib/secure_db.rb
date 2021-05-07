# frozen_string_literal: true

require 'base64'
require 'rbnacl'

# Encrypt and Decrypt from Database
class SecureDB
  class NoDbKeyError < StandardError; end

  # Generate key for Rake tasks (typically not called at runtime)
  def self.generate_key
    key = RbNaCl::Random.random_bytes(RbNaCl::SecretBox.key_bytes)
    Base64.strict_encode64 key
  end

  def self.key
    return @key if @key

    db_key = ENV.delete('DB_KEY')
    raise NoDbKeyError unless db_key

    @key = Base64.strict_decode64(db_key)
  end

  # Encrypt or else return nil if data is nil
  def self.encrypt(plaintext)
    return nil unless plaintext

    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    ciphertext = simple_box.encrypt(plaintext)
    Base64.strict_encode64(ciphertext)
  end

  # Decrypt or else return nil if database value is nil already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64

    ciphertext = Base64.strict_decode64(ciphertext64)
    simple_box = RbNaCl::SimpleBox.from_secret_key(key)
    simple_box.decrypt(ciphertext).force_encoding(Encoding::UTF_8)
  end
end
