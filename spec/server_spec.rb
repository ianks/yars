describe Yars::Server do
  describe '.new' do
    it 'initializes' do
      expect(Yars::Server.new app: {}, host: '0.0.0.0', port: 8000)
        .to be_a Yars::Server
    end
  end

  describe '.start' do
    it 'boots a TCPServer' do
      expect(TCPServer).to receive(:new).with('localhost', 8000)
      expect { Yars::Server.start app: {} }.to raise_error
    end
  end
end
