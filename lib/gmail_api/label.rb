module GmailApi

  class Label

    def self.find_collection(client, ids)
      calls = ids.reject { |id| id =~ /INBOX|CATEGORY_|STARRED|SENT|UNREAD/ }.map { |id| { api_method: GmailApi.api.users.labels.get, parameters: { id: id, 'userId'=>'me' }  } }
      get_batched_labels(client, calls)
    end

    def self.list client
      client.execute GmailApi.api.users.labels.list, {}, {}
    end

    def self.get_batched_labels(client, calls)
      labels = []
      if calls.any?
        client.execute_batch(calls) do |result|
          labels << Label.new(result)
        end
      end
      labels
    end

    def self.find(client, id)
      new client.execute(GmailApi.api.users.labels.get, id: id)
    end

    def self.create client, request_body={}, headers={}
      client.execute(GmailApi.api.users.labels.create, {},
        {body_object: request_body, headers: headers})
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

    def not_found?
      @response.status == 404
    end

    def self.find_by client, name: name
      labels = JSON(self.list(client).response.body)["labels"]
      labels.each do |label|
        return label["id"] if name == label["name"]
      end
    end
  end

end