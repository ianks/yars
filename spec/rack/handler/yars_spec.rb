describe Rack::Handler::Yars do
  let :app do
    -> { ['200', { 'Content-Type' => 'text/html' }, ['A rack app.']] }
  end

  it 'starts the app' do
    expect_any_instance_of(Yars::Server).to receive :start
    Rack::Handler::Yars.run app
  end
end
