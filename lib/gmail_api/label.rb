module GmailApi

  class Label

    def self.find_collection(client, ids)
      calls = ids.reject { |id| id =~ /INBOX|CATEGORY_|STARRED|SENT/ }.map { |id| { api_method: GmailApi.api.users.labels.get, parameters: { id: id, 'userId'=>'me' }  } }
      labels = []
      client.execute_batch(calls) do |result|
        labels << Label.new(result)
      end
      labels
    end
      
    def self.find(client, id)
      new client.execute()
    end

    def initialize(response)
      @response = response
      @raw      = response && JSON(response.body) || {}
    end

    def name
      @raw['name']
    end

    def id
      @raw['id']
    end

    def type
      @raw['type']
    end


  end
  
end