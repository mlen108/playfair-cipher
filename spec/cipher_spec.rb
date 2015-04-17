require 'cipher'

describe Cipher do
  context 'when the key and message are empty' do
    it 'will raise an error' do
      expect{ described_class.new }.to raise_error
      expect{ described_class.new('') }.to raise_error
      expect{ described_class.new('', '') }.to raise_error
    end
  end

  context 'when the key is not valid' do
    it 'will raise an error' do
      expect{ described_class.new('?#(&$', 'abc') }.to raise_error
      expect{ described_class.new('1234567', 'abc') }.to raise_error
    end
  end

  context 'when the key is valid' do
    it 'will not raise an exception' do
      expect{ described_class.new('playfair example', 'abc') }.not_to raise_error
      expect{ described_class.new('playfair example', 'ABC') }.not_to raise_error
    end
  end

  context 'when the message is empty' do
    it 'will raise an error' do
      expect{ described_class.new('playfair example', '') }.to raise_error
    end
  end

  context 'when the message is not valid' do
    it 'will raise an error' do
      expect{ described_class.new('playfair example', '1234567') }.to raise_error
    end
  end

  context 'when the message is valid' do
    subject{ described_class.new('playfair example', 'Hide the gold in the tree stump') }

    it 'will encrypt it' do
      expect(subject.encrypt).to eq('BMODZBXDNABEKUDMUIXMMOUVIF')
    end
  end

  context 'when the message is valid' do
    subject{ described_class.new('playfair example', 'BMODZ BXDNA BEKUD MUIXM MOUVI F') }

    it 'will decrypt it' do
      expect(subject.decrypt).to eq('HIDETHEGOLDINTHETREXESTUMP')
    end
  end
end
