module GmailApi
  class Attachment
    def self.find client, params={}
      client.execute GmailApi.api.users.messages.attachments.get, params
    end
  end
end