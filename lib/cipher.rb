# Cipher encrypts/decrypts messages using the rules described at
# http://en.wikipedia.org/wiki/Playfair_cipher
# Additional rules:
#  - 'X' is used to append to a digraph if needed,
#  - 'J' is replaced with 'I'
class Cipher
  def initialize(key, msg)
    key = prepare(key)
    msg = prepare(msg)

    validate(key, msg)

    @digraphs = Message.new(key, msg)
  end

  def encrypt
    @digraphs.map(&:encrypt).join
  end

  def decrypt
    @digraphs.map(&:decrypt).join
  end

  private

  def prepare(str)
    str.strip.delete(' ').upcase
  end

  def validate(*args)
    args.each do |str|
      fail 'It cannot be empty.' if str.nil? || str.length == 0
      fail 'It must be in range of A-Z characters.' unless num?(str)
    end
  end

  def num?(str)
    !str.match(/[^[:alpha:]]/)
  end
end

# Breaks a message into pair of digraphs
class Message
  include Enumerable

  def initialize(key, message)
    @key = key
    @msg = message
    @msg_size = message.size

    @grid = memo_key
  end

  def memo_key
    alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ' # no J in here
    uniq_key = @key.chars.to_a.uniq.join
    uniq_key + (alphabet.split(//) - uniq_key.split(//)).join
  end

  def each
    counter = 0
    while counter < @msg_size
      if counter + 1 == @msg_size
        yield Digraph.new(@msg[counter], 'X', @grid)
        break
      elsif @msg[counter] != @msg[counter + 1]
        yield Digraph.new(@msg[counter], @msg[counter + 1], @grid)
        counter += 2
      else
        yield Digraph.new(@msg[counter], 'X', @grid)
        counter += 1
      end
    end
  end
end

# Represents a pair of letters and allows to encrypt/decrypt it within a grid
class Digraph
  attr_reader :grid, :coords

  def initialize(first_char, second_char, grid)
    @grid = grid

    first_pos = grid.index(first_char)
    second_pos = grid.index(second_char)

    @coords = [
      first_pos % 5, first_pos / 5,
      second_pos % 5, second_pos / 5
    ]
  end

  def encrypt
    translate.map { |x| grid[x] }.join
  end

  def decrypt
    translate(true).map { |x| grid[x] }.join
  end

  def translate(decrypt = nil)
    if coords[1] == coords[3]
      decrypt ? decrypt_row : encrypt_row
    elsif coords[0] == coords[2]
      decrypt ? decrypt_column : encrypt_column
    else
      translate_rectangle
    end
  end

  def encrypt_row
    [
      (coords[1] * 5) + ((coords[0] + 1) % 5),
      (coords[3] * 5) + ((coords[2] + 1) % 5)
    ]
  end

  def decrypt_row
    [
      (coords[1] * 5) + ((coords[0] - 1) % 5),
      (coords[3] * 5) + ((coords[2] - 1) % 5)
    ]
  end

  def encrypt_column
    [
      (((coords[1] + 1) % 5) * 5) + coords[0],
      (((coords[3] + 1) % 5) * 5) + coords[2]
    ]
  end

  def decrypt_column
    [
      (((coords[1] - 1) % 5) * 5) + coords[0],
      (((coords[3] - 1) % 5) * 5) + coords[2]
    ]
  end

  def translate_rectangle
    [
      (coords[1] * 5) + coords[2],
      (coords[3] * 5) + coords[0]
    ]
  end
end
