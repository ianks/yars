describe Yars::Server do
  it 'initializes' do
    expect(Yars::Server.new '0.0.0.0', '8000', [], {}).to be_a Yars::Server
  end
end
