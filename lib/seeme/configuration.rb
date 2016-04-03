module Seeme
	class Configuration
    DEFAULT_ENDPOINT_URI = "seeme.hu"
    DEFAULT_API_VERSION = "v1"

    attr_accessor :endpoint_uri, :api_version, :secure_http, :api_key, :secure_http, :default_number, :mock, :callback_url

    def initialize
      @endpoint_uri = DEFAULT_ENDPOINT_URI
      @api_version = DEFAULT_API_VERSION
      @secure_http = true
      @mock = false
    end

    def endpoint_url
      "#{protocol_param}://#{@endpoint_uri}"
    end

    def is_url_valid?
      !!URI.parse(endpoint_url)
    rescue URI::InvalidURIError
      false
    end

    private
    def protocol_param
      @secure_http ? "https" : "http"
    end
  end
end