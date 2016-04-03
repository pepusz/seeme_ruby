require 'uri'
require 'faraday'
require 'multi_json'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash'
require 'os'
require 'openssl'
require "seeme/version"
require "seeme/configuration"
require "seeme/sms"
require "seeme/client"

module Seeme
  extend SingleForwardable

	def_delegators :config, :endpoint_uri, :endpoint_uri=, :api_version, :api_version=,
                 :endpoint_url, :api_key, :default_number, :callback_url

	class << self
    def configure
      yield config if block_given?
    end

    def config
      @config ||= Configuration.new
    end

    def reset_config
      @config = nil
    end


  end
end
