describe Yars::UnboundedSignalingQueue do
  let(:q) { Yars::UnboundedSignalingQueue.new }
  let(:data) { %w(one two three four) }

  describe '#push' do
    it 'can be pushed to' do
      threads = []

      8.times do
        threads << Thread.new do
          data.each { |num| expect(q << num).to eq num }
        end
      end

      threads.each(&:join)
    end
  end

  describe '#pop' do
    it 'can be popped from' do
      threads = []
      vals = []

      data.each { |num| q << num }

      data.length.times do
        threads << Thread.new do
          val = q.pop
          vals << val
          expect(data).to include val
        end
      end

      threads.each(&:join)

      expect(vals).to match_array data
    end
  end
end
