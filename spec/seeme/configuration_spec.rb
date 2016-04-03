require 'spec_helper'

describe 'configuration' do
  before :each do
    Seeme.reset_config
  end
  it 'has endpoint uri' do
    expect(Seeme.endpoint_uri).to eq Seeme::Configuration::DEFAULT_ENDPOINT_URI
    Seeme.endpoint_uri = "google.com"
    expect(Seeme.endpoint_uri).to eq "google.com"
    Seeme.configure do |config|
      config.endpoint_uri = "yahoo.com"
    end
    expect(Seeme.endpoint_uri).to eq "yahoo.com"
  end

  it 'has valid enpoint url' do
    Seeme.endpoint_uri = "google.com"
    expect(Seeme.config.is_url_valid?).to be true
    Seeme.endpoint_uri = "invalid##host.com"
    expect(Seeme.config.is_url_valid?).to be false
  end

  it 'has api version' do
    expect(Seeme.api_version).to eq Seeme::Configuration::DEFAULT_API_VERSION
    Seeme.api_version = "v2"
    expect(Seeme.api_version).to eq "v2"
    Seeme.configure do |config|
      config.api_version= "v3"
    end
    expect(Seeme.api_version).to eq "v3"
  end

  it 'has auth id' do
    Seeme.configure do |config|
      config.api_key = "auth_id2"
    end
    expect(Seeme.config.api_key).to eq "auth_id2"
  end  

  it 'has https' do
    expect(Seeme.config.secure_http).to eq true
  end
  
  it 'has http' do
    Seeme.configure do |config|
      config.secure_http= false
    end
    expect(Seeme.config.secure_http).to eq false
  end
end