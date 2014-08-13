module GmailApi

  class Thread

    def self.list(client, parameters={})
      calls = []
      threads = []
      response = client.execute(GmailApi.api.users.threads.list, parameters)
      body = JSON(response.body)
      body['threads'].each do |thread|
        calls << { api_method: GmailApi.api.users.threads.get, parameters: { id: thread['id'], format: 'full', 'userId'=>'me' } }
      end
      client.execute_batch(calls) do |result|
        threads << Thread.new(client, result)
      end
      threads
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