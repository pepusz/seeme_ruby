module Seeme
  class Sms
    TEMP = 'tmp'
    OUTBOUND = 'outbound'
    INBOUND = 'inbound'
    DRAFT = 'draft'
    SENT = 'sent'
    ERROR = 'failed'
    attr_reader :id, :from, :to, :text, :date, :type, :status, :delivery_date,
                :mock, :delivery, :message_id, :errors

    def initialize(options={})
      @errors = []

      @from, @to = options[:from], options[:to]
      @text, @message_id = options[:text], options[:message_id]
      @type = TEMP
      @status = DRAFT
    end

    def send(client)
      fail "Can't send because this message is already sent" if @type != TEMP  || @date.present? || is_sent?
      fail "Can't send because to phone number not provided" if @to.blank?
      fail "Can't send because from phone number not provided" if @from.blank?
      fail "Can't send because message id not provided" if @message_id.blank?

      resp = client.get('', params)

      resp_body = parse_response(resp)

      if (resp_body[:result] == 'OK')
        @date = Time.now
        @status = SENT
        true
      else
        @status = ERROR
        false
      end
    end

    def is_sent?
      @status == SENT
    end

    private
    def params
      { number: @to, sender: @from, message: @text, reference: @message_id }
    end

    def parse_response(response)
      resp_body = {}
      begin
        resp_body = MultiJson.load(response.body)
        resp_body = resp_body.deep_symbolize_keys
        @errors << resp_body[:error] if resp_body[:error].present?
        if resp_body[:result] == 'ERR'
          @errors <<  "#{resp_body[:code]} #{resp_body[:message]}"
        end
      rescue MultiJson::ParseError => exception
        @errors << exception.data
      end
      resp_body
    end

  end
end