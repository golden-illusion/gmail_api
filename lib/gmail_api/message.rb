require 'base64'

module GmailApi

  class Messages
    include Enumerable

    def self.list(client, parameters={})
      new( client, client.execute(GmailApi.api.users.messages.list, parameters) )
    end

    attr_accessor :messages, :response

    def initialize(client, response)
      @client   = client
      @response = JSON(response.body)
      @messages = @response['messages']
    end

    def each
      if block_given?
        @messages.each do |message_info|
          yield(Message.find(@client, message_info['id']))
        end
      else
        Enumerator.new(@messages)
      end
    end

    def next
      self.class.list(@client, 'pageToken' => @response['nextPageToken'] )
    end

  end

  class Message

    attr_accessor :id, :response

    #  List valid parameters:
    #   includeSpamTrash  => boolean Include messages from SPAM and TRASH in the results. (Default: false)
    #   labelIds          => string  Only return messages with labels that match all of the specified label IDs.
    #   maxResults        => unsigned integer  Maximum number of messages to return.
    #   pageToken         => string  Page token to retrieve a specific page of results in the list.
    #   q                 => string  Only return messages matching the specified query. Supports the same query format as the Gmail search box. For example, "from:someuser@example.com rfc822msgid: is:unread".

    def self.list(client, parameters={})
      Messages.list(client, parameters)
    end

    def self.find(client, id)
      new( client.execute(GmailApi.api.users.messages.get, id: id, format: 'full') ).tap do |m|
        m.id = m.raw['id']
      end
    end

    def self.create(options={}) 

    end

    def initialize(response)
      @response = response
      @message = JSON(@response.body)
    end

    def trash
    end

    # Snippet of email content
    def snippet
      @message['snippet']
    end

    def content
      Base64.urlsafe_decode64 find_content('text/plain')
    end

    def html_content
      Base64.urlsafe_decode64 find_content('text/html')
    end

    def raw
      @message
    end

    private

      def find_content(content_type)
        part = @message['payload']['parts'].find { |hash| hash['mimeType'] =~ /#{content_type}/ } || {}
        body = part.fetch('body', {})
        body.fetch('data', '')
      end

  end

end