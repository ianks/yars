describe Yars::AtomicQueue do
  let(:q) { Yars::AtomicQueue.new }
  let(:data){ %w(one two three four) }

  describe '#push' do
    it 'can be pushed to' do
      data.each { |num| q << num }
      expect(q.size).to eq 4
    end
  end


  describe '#pop' do
    before { data.each { |num| q << num } }

    it 'can be popped from' do
      data.each { |num| expect(q.pop).to eq num }
    end

    context 'when the queue is empty' do
      before { (q.size + 10).times { q.pop } }

      it 'does not create a negative size' do
        expect(q.size).to eq 0
      end
    end
  end
end
