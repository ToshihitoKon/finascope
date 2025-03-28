require "nanoid"

module ID
  def self.generate
    Nanoid.generate(size: 12, alphabet: "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
  end
end
