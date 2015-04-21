describe Yars::AtomicQueue do
  let(:q) { Yars::AtomicQueue.new }
  let(:data) { %w(one two three four) }

  describe '#push' do
    it 'can be pushed to' do
      data.each do |num|
        expect(q << num).to eq num
      end
    end
  end

  describe '#pop' do
    before { data.each { |num| q << num } }

    it 'can be popped from' do
      data.each { |num| expect(q.pop).to eq num }
    end
  end
end
