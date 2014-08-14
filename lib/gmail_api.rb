require "gmail_api/version"
require 'gmail_api/errors'
require 'gmail_api/client'
require 'gmail_api/collection'
require 'gmail_api/label'
require 'gmail_api/thread'
require 'gmail_api/message'
require 'google/api_client'
require 'google/api_client/client_secrets'

module GmailApi

  #
  # Some configuration is required to use GmailApi, add a configuration block like:
  #
  #  GmailApi.configure do |conf|
  #    # secrets required by google api client gem to get access to your google app
  #    # for more information on secrets file go to https://developers.google.com/api-client-library/ruby/guide/aaa_client_secrets
  #    conf.secrets = {
  #                     client_id: "client_id",
  #                     client_secret: "client_secret",
  #                     redirect_uris: ["http://localhost:3000"],
  #                     auth_uri: "https://accounts.google.com/o/oauth2/auth",
  #                     token_uri: "https://accounts.google.com/o/oauth2/token"
  #                   } 
  #  end
  #

  @@configured = false
  @@secrets = {}

  def self.secrets=(options={})
    @@secrets = { 'web' => options }
  end

  def self.client_secrets
    fail NoSecrets.new('Secrets is empty, google needs this information to authorize the requests') if @@secrets.empty?
    fail NotConfigured.new('GmailApi is not yet configured please add the configuration options on app initialization') unless configured?
    @@client_secrets ||= Google::APIClient::ClientSecrets.new(@@secrets)
  end

  def self.configured?
    @@configured
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
