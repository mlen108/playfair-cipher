class Cipher
  attr_reader :memo_key

  def initialize(key)
    @memo_key = key

    check

    @grid = generate_grid
  end

  def encrypt(msg)
  end

  def decrypt(msg)
  end

  private
    def check
      if @memo_key.nil? || @memo_key.length == 0
        fail 'It cannot be empty.'
      end

      if num?(@memo_key)
        fail 'It must be in range of A-Z characters.'
      end
    end

    def num?(str)
      str.match(/[^[:alpha:]]/)
    end

    def generate_grid
    end
end
