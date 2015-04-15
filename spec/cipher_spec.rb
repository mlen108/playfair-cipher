require 'cipher'

describe Cipher do
  context 'when the key is empty' do
    it 'will raise an error' do
      expect{ described_class.new('') }.to raise_error
    end
  end

  context 'when the key is not valid' do
    it 'will raise an error' do
      expect{ described_class.new('1234567') }.to raise_error
    end
  end

  context 'when the message is empty' do
    subject{ Cipher.new('playfair example') }

    it 'will raise an error' do
      expect{ subject.encrypt('') }.to raise_error
      expect{ subject.decrypt('') }.to raise_error
    end
  end

  context 'when the message is not valid' do
    subject{ Cipher.new('playfair example') }

    it 'will not encrypt it & raise an error' do
      expect{ subject.encrypt('1234567') }.to raise_error
    end

    it 'will not decrypt it & raise an error' do
      expect{ subject.decrypt('1234567') }.to raise_error
    end
  end

  context 'when the message is valid' do
    subject{ Cipher.new('playfair example') }

    it 'will encrypt it' do
      expect{ subject.encrypt('Hide the gold in the tree stump') }.to eq('BMODZBXDNABEKUDMUIXMMOUVIF')
    end

    it 'will decrypt it' do
      expect{ subject.decrypt('BMODZBXDNABEKUDMUIXMMOUVIF') }.to eq('Hide the gold in the tree stump')
    end
  end
end
