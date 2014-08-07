module GmailApi

  class Label

    def self.find_collection(client, ids)
      ids.reject { |id| id =~ /INBOX|CATEGORY_/ }.map { |id| find(client, id) }
    end
      
    def self.find(client, id)
      new client.execute(GmailApi.api.users.labels.get, id: id)
    end

    def initialize(response)
      @raw_label = response
    end

    def name
      @raw_label['name']
    end

    def id
      @raw_label['id']
    end

    def type
      @raw_label['type']
    end


  end
  
end