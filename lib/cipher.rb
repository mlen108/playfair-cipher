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
    uniq_key = @key.split(//).uniq
    (uniq_key + (alphabet.split(//) - uniq_key)).join
  end

  def each
    counter = 0
    while counter < @msg_size
      if @msg[counter] != @msg[counter + 1]
        yield Digraph.new(@msg[counter], @msg[counter + 1], @grid)
        counter += 2
      else
        yield Digraph.new(@msg[counter], 'X', @grid)
        counter += 1 if counter + 1 != @msg_size
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
    translate(:+).map { |x| grid[x] }.join
  end

  def decrypt
    translate(:-).map { |x| grid[x] }.join
  end

  def translate(smb)
    if coords[1] == coords[3]
      translate_row(smb)
    elsif coords[0] == coords[2]
      translate_column(smb)
    else
      translate_rectangle
    end
  end

  def translate_row(smb)
    coords.each_slice(2).map { |k, v|
      (v * 5) + (k.send(smb, 1) % 5)
    }
  end

  def translate_column(smb)
    coords.each_slice(2).map { |k, v|
      ((v.send(smb, 1) % 5) * 5) + k
    }
  end

  def translate_rectangle
    [[1, 2], [3, 0]].map { |k, v|
      (coords[k] * 5) + coords[v]
    }
  end
end
