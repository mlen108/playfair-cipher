class Cipher
  attr_reader :grid

  def initialize(key, message)
    key = prepare(key)
    message = prepare(message)

    check(key)
    check(message)

    @digraphs = Message.new(key, message)
  end

  def encrypt
    @digraphs.map { |d| d.encrypt }.join
  end

  def decrypt
    @digraphs.map { |d| d.decrypt }.join
  end

  private

  def prepare(str)
    str.delete(' ').upcase
  end

  def check(str)
    if str.nil? || str.length == 0
      fail 'It cannot be empty.'
    end

    fail 'It must be in range of A-Z characters.' unless num?(str)
  end

  def num?(str)
    !str.match(/[^[:alpha:]]/)
  end
end

class Message
  include Enumerable

  attr_reader :key, :message

  def initialize(key, message)
    @key = key
    @msg = message

    @grid = ''
    memo_key
  end

  def memo_key
    grid = ''
    alphabet = ('A'..'Z').to_a

    @key.chars.each do |l|
      if !grid.include?(l) && alphabet.include?(l)
        grid += l
      end
    end

    alphabet.each do |l|
      if l == 'J'
        l = 'I'
      end
      if !grid.include?(l)
        grid += l
      end
    end

    @grid = grid
  end

  def each
    msg_fixed = @msg.tr('J', 'I')

    counter = 0
    while counter < msg_fixed.size
      if counter + 1 == msg_fixed.size
        yield Digraph.new(msg_fixed[counter], 'X', @grid)
        break
      elsif msg_fixed[counter] != msg_fixed[counter + 1]
        yield Digraph.new(msg_fixed[counter], msg_fixed[counter + 1], @grid)
        counter += 2
      else
        yield Digraph.new(msg_fixed[counter], 'X', @grid)
        counter += 1
      end
    end
  end
end

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
