require 'spec_helper'

describe Seeme::Sms do
	context 'structural tests: ' do
	 	let(:valid_temp_message) { Seeme::Sms.new(:from => "12345", :to => "6789",
                                                 :text => "Hello from spec!", :id => "not_valid",
                                                 :date => Time.now, :delivery_date=>Time.now) }

	 	#todo test params
	 	it "should not has an id" do
      expect(valid_temp_message.id).to be_nil
    end
    it "should not has a sent date" do
      expect(valid_temp_message.date).to be_nil
    end

    it "has from phone number" do
      expect(valid_temp_message.from).to eq "12345"
    end

    it "has to phonen umber" do
      expect(valid_temp_message.to).to eq "6789"
    end

    it "has type" do
      expect(valid_temp_message.type).to eq Seeme::Sms::TEMP
    end
	end	
  context "api communication: " do
    before :each do
      configure_seeme
      @client = Seeme::Client.new
      @temp_id = "525e3fb3b218980d35000002"
      WebMock.reset!
      stub_request(:get, stub_base_url+"?callback=1,6,7&callbackurl=http://localhost/callback&format=json&key=user&message=Hello%20sms&number=1234&reference=525e3fb3b218980d35000002&sender=4567").
          to_return(body: MultiJson.dump({"result":"OK","price":14,"code":0,
          																"message":"Your message has been successfully received by the Gateway.",
          																"charset":"GSM-7","split":1,"length":5}), status: 201) 
    end	

		it "should send if type TEMP" do
      sms = Seeme::Sms.new(to: 1234, from: 4567, text: "Hello sms", message_id: "525e3fb3b218980d35000002")
      expect(sms.send(@client)).to eq true
      expect(sms.is_sent?).to eq true
      expect { sms.send(@client) }.to raise_error("Can't send because this message is already sent")
    end




    it "should not send if to or from not provided" do
      sms = Seeme::Sms.new(from: 4567, text: "Hello sms")
      expect { sms.send(@client) }.to raise_error("Can't send because to phone number not provided")
      sms = Seeme::Sms.new(to: 4567, text: "Hello sms")
      expect { sms.send(@client) }.to raise_error("Can't send because from phone number not provided")
    end

    it "should not save if response has error or status code not 201" do
      WebMock.reset!
         stub_request(:get, stub_base_url+"?callback=1,6,7&callbackurl=http://localhost/callback&format=json&key=user&message=Hello%20sms&number=1234&reference=525e3fb3b218980d35000002&sender=4567").
          to_return(body: MultiJson.dump({"result":"ERR","price":0,"code":1,"message":"Missing parameter: number"}), status: 201) 

      sms = Seeme::Sms.new(to: 1234, from: 4567, text: "Hello sms",  message_id: "525e3fb3b218980d35000002")
      expect(sms.send(@client)).to eq false
    end

    it "should fill errors array from response" do
      WebMock.reset!
      stub_request(:post, stub_base_url+ "sms").
          to_return(body: MultiJson.dump({"result":"ERR","price":0,"code":1,"message":"Missing parameter: number"}), status: 200)
      sms = Seeme::Sms.new(to: 1234, from: 4567, text: "Hello sms")
      expect{sms.send(@client)}.to raise_error "Can't send because message id not provided"
      
    end
  end    
end