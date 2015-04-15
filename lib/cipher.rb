class Cipher
  attr_reader :key, :grid

  def initialize(key)
    @key = prepare(key)

    check(@key)

    @grid = generate_grid
  end

  def encrypt(msg)
  end

  def decrypt(msg)
  end

  private
    def prepare(str)
      str.delete(' ').upcase
    end

    def check(str)
      if str.nil? || str.length == 0
        fail 'It cannot be empty.'
      end

      if num?(str)
        fail 'It must be in range of A-Z characters.'
      end
    end

    def num?(str)
      str.match(/[^[:alpha:]]/)
    end

    def generate_grid
      grid = ''
      alphabet = 'ABCDEFGHIJKLMNOPRSTUVWXYZ'

      @key.chars.each do |l|
        if !grid.include?(l) && alphabet.include?(l)
          grid += l
        end
      end

      alphabet.chars.each do |l|
        if !grid.include?(l)
          grid += l
        end
      end

      grid
    end
end
