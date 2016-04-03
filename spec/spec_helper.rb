require 'seeme'
require 'byebug'
require 'webmock/rspec'
require 'vcr'


WebMock.disable_net_connect!(allow_localhost: true)

def stub_base_url
  "#{Seeme.endpoint_uri}/gateway"
end

def configure_seeme
  Seeme.configure do |c|
    c.api_key = "user"
    c.secure_http = false
    c.callback_url = "http://localhost/callback"
  end
end