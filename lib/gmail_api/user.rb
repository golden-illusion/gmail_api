module GmailApi
  class User
    def self.user_profile client
      result = client.execute GmailApi.api.users.get_profile
      result = result.try(:body) || result
      JSON.parse result
    end
  end
end