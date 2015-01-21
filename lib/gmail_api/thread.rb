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

    def label_start_with start_with
      @raw["messages"][0]["labelIds"].find{|label| label.start_with? start_with}
    end

    def unread_emails
      messages.each_with_object([]){|m, unreads| unreads << m if m.unread?}
    end

    def have_unread_email?
      messages.find{|m| m.unread?}
    end

    def read_all_email!
      calls = unread_emails.map do |email|
        {
          api_method: GmailApi.api.users.messages.modify,
          parameters: {id: email.id, userId: "me"},
          body_object: {removeLabelIds: ["UNREAD"]}
        }
      end
      results = []
      if calls.any?
        @client.execute_batch(calls) do |result|
          results << result
        end
      end
      results
    end

    private

    def get_messages
      @raw['messages'].map do |message|
        Message.new(@client, OpenStruct.new(body: message.to_json))
      end
    end

  end

end