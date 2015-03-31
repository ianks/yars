require 'rack/test'

describe Yars::Server do
  describe '.new' do
    it 'initializes' do
      expect(Yars::Server.new app: {}, host: '0.0.0.0', port: 8000)
        .to be_a Yars::Server
    end
  end

  describe 'get' do
    let(:app) do
      ->(_env) { Rack::Response.new('Hello!', 200, 'Dag' => 'Gummit').finish }
    end

    let!(:server) do
      Thread.new { Kernel.silence { Yars::Server.start(app: app) } }
    end

    after { server.kill }

    it 'responds with 200 status' do
      get '/'
      expect(last_response.status).to eq 200
    end

    it 'responds with correct headers' do
      get '/'
      expect(last_response.headers['Dag']).to eq 'Gummit'
    end

    it 'responds with correct body' do
      get '/'
      expect(last_response.body).to eq 'Hello!'
    end
  end
end
