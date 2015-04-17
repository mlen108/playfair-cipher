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

# Represents a pair of letters and allows to encrypt/decrypt them
class Digraph
  # TODO(mlen) - refactor this encrypt/decrypt madness
  attr_reader :first_char, :second_char, :grid

  def initialize(first_char, second_char, grid)
    @first_char = first_char
    @second_char = second_char
    @grid = grid
  end

  def encrypt
    first_char_pos = grid.index(first_char)
    second_char_pos = grid.index(second_char)

    first_char_coords = [first_char_pos % 5, first_char_pos / 5]
    second_char_coords = [second_char_pos % 5, second_char_pos / 5]

    # letters appear on the same row
    if first_char_coords[1] == second_char_coords[1]
      first_encrypted = grid[(first_char_coords[1] * 5) + ((first_char_coords[0] + 1) % 5)]
      second_encrypted = grid[(second_char_coords[1] * 5) + ((second_char_coords[0] + 1) % 5)]
    # letters appear on the same column
    elsif first_char_coords[0] == second_char_coords[0]
      first_encrypted = grid[(((first_char_coords[1] + 1) % 5) * 5) + first_char_coords[0]]
      second_encrypted = grid[(((second_char_coords[1] + 1) % 5) * 5) + second_char_coords[0]]
    # letters are not on the same row or column (they form a rectangle)
    else
      first_encrypted = grid[(first_char_coords[1] * 5) + second_char_coords[0]]
      second_encrypted = grid[(second_char_coords[1] * 5) + first_char_coords[0]]
    end

    first_encrypted + second_encrypted
  end

  def decrypt
    first_char_pos = grid.index(first_char)
    second_char_pos = grid.index(second_char)

    first_char_coords = [first_char_pos % 5, first_char_pos / 5]
    second_char_coords = [second_char_pos % 5, second_char_pos / 5]

    # letters appear on the same row
    if first_char_coords[1] == second_char_coords[1]
      first_decrypted = grid[(first_char_coords[1] * 5) + ((first_char_coords[0] - 1) % 5)]
      second_decrypted = grid[(second_char_coords[1] * 5) + ((second_char_coords[0] - 1) % 5)]
    # letters appear on the same column
    elsif first_char_coords[0] == second_char_coords[0]
      first_decrypted = grid[(((first_char_coords[1] - 1) % 5) * 5) + first_char_coords[0]]
      second_decrypted = grid[(((second_char_coords[1] - 1) % 5) * 5) + second_char_coords[0]]
    # letters are not on the same row or column (they form a rectangle)
    else
      first_decrypted = grid[(first_char_coords[1] * 5) + second_char_coords[0]]
      second_decrypted = grid[(second_char_coords[1] * 5) + first_char_coords[0]]
    end

    first_decrypted + second_decrypted
  end
end
