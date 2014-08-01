require "gmail_api/version"
require 'gmail_api/errors'
require 'gmail_api/client'
require 'gmail_api/message'
require 'google/api_client'
require 'google/api_client/client_secrets'

module GmailApi

  #
  # Some configuration is required to use GmailApi, add a configuration block like:
  #
  #  GmailApi.configure do |conf|
  #    # secrets file is required by google api client gem to get access to your google app
  #    # for more information on secrets file go to https://developers.google.com/api-client-library/ruby/guide/aaa_client_secrets
  #    conf.secrets_file = 'secrets file location'
  #  end
  #

  @@configured = false

  def self.configured?
    !!@@configured
  end
    
  def self.secrets_file=(file_location=nil)
    @@secrets_file = file_location
  end

  def self.secrets_file
    @@secrets_file
  end

  def self.client_secrets
    fail NoSecretsFile.new("tell me all your secrets") if @@secrets_file.nil?
    @@client_secrets ||= Google::APIClient::ClientSecrets.load(@@secrets_file)
  end

  def self.configure
    yield(self)
    @@configured = true
  end

  def self.client
    @client ||= Google::APIClient.new(application_name: 'Close GmailApi', application_version: '0.0.1')
  end

  def self.api
    @@api ||= Google::APIClient.new.discovered_api('gmail', 'v1')
  end
  
end
