module GmailApi

  class Thread

    def self.list(client, parameters={})
      Collection.new(client, client.execute(GmailApi.api.users.threads.list, parameters), 'threads' ) do |client, result|
        Thread.new(client, result)
      end
    end

    def initialize(client, result)
      @result = result
      @raw    = JSON(result.body)
      @client = client
    end

    def messages
      @messages ||= get_messages
    end

    def id
      @raw['id']
    end

    private

    def get_messages
      @raw['messages'].map do |message|
        Message.new(@client, OpenStruct.new(body: message.to_json))
      end
    end

  end

end