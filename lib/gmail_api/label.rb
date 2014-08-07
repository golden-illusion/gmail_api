module GmailApi

  class Label

    def self.find_collection(client, ids)
      ids.reject { |id| id =~ /INBOX|CATEGORY_/ }.map { |id| find(client, id) }
    end
      
    def self.find(client, id)
      new client.execute(GmailApi.api.users.labels.get, id: id)
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