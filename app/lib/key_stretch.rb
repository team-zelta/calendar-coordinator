# frozen_string_literal: true

require 'rbnacl'

# Key Stretch
module KeyStretch
  # Create salt
  def new_salt
    RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
  end

  # Hash the password with salt
  def password_hash(salt, password)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64

    RbNaCl::PasswordHash.scrypt(password, salt, opslimit, memlimit, digest_size)
  end
end
