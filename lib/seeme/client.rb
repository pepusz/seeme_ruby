module Seeme
	class Client
     OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE if OS.mac?
		def initialize
      @connection = faraday_connection
    end

    def send_sms(to, text, message_id, from=nil)
      raise "You have to setup defult number, or set from parameter" if from.blank? && Seeme.default_number.blank?
      raise "You have to setup defult callback url" if Seeme.callback_url.blank?
      from = Seeme.default_number if from.blank?
      sms = Sms.new({to: to, text: text, from: from, message_id: message_id})
      sms.send(self)
      sms
    end

    def get(path, params={})
      raise "You have to setup defult callback url" if Seeme.callback_url.blank?
    	params["key"] = Seeme.api_key
    	params["callback"]="1,3,4,5,6,7"
      params["callbackurl"] = Seeme.callback_url
      params["format"] = "json"
      @connection.get "/gateway", params
    end

    private
    def faraday_connection
      raise "You have to config api key" if Seeme.api_key.blank?
      Faraday.new(:url => "#{Seeme.endpoint_url}") do |faraday|
        faraday.use Faraday::Request::Retry
        faraday.use Faraday::Response::Logger
        faraday.use Faraday::Adapter::NetHttp
      end
    end
	end
end