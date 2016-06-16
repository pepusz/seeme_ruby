module Seeme
  class Sms
    TEMP = "tmp"
    OUTBOUND = "outbound"
    INBOUND = "inbound"
    DRAFT = "draft"
    SENT = "sent"
    attr_reader :id, :from, :to, :text, :date, :type, :status, :delivery_date, :mock, :delivery, :message_id, :errors


  

    def initialize(options={})
      @errors = []

      @from, @to, @text, @message_id = options[:from], options[:to], options[:text], options[:message_id]
      @type = TEMP
      @status = DRAFT
    end

    def send(client)
      raise "Can't send because this message is already sent" if @type != TEMP  || @date.present? || is_sent?
      raise "Can't send because to phone number not provided" if @to.blank?
      raise "Can't send because from phone number not provided" if @from.blank?
      raise "Can't send because message id not provided" if @message_id.blank?
      
      resp = client.get("", params)
      
      resp_body = parse_response(resp)
      if (resp_body[:result] == "OK" && resp.status == 200)
        @date = Time.now
        @status = SENT
        return true
      else
        puts resp_body
        @errors << resp_body[:message]
      end

      return false
    end

    def is_sent?
      @status == SENT
    end

    private
    def params
      {number: @to, sender: @from, message: @text, reference: @message_id}
    end

     def parse_response(response)
      resp_body = {}
      begin
        resp_body = MultiJson.load(response.body)
        resp_body= resp_body.deep_symbolize_keys
        if resp_body[:error].present?
          @errors << resp_body[:error]
        end
      rescue MultiJson::ParseError => exception
        @errors << exception.data
      end
      resp_body
    end

  end
end