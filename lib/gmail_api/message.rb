require 'base64'
require 'mime'

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

    ##
    # available methods:
    #   cc: Gmail Message CC header
    #   from: Gmail Message FROM header
    #   to:  Gmail Message TO header
    #   raw_content: Encoded email body
    #   content: Decoded email body in plain text
    #   thread_id: Gmail Message THREAD header
    ##

    attr_accessor :id, :response, :client

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
      new(client, client.execute(GmailApi.api.users.messages.get, id: id, format: 'full') ).tap do |m|
        m.id = m.raw['id']
      end
    end

    # options
    #   to: sender
    #   subject: email subject
    #   body:    email content in plain text 

    def self.create(client, options={})
      message = MIME::Mail.new
      options.each { |k,v| message.__send__("#{k}=", v) }
      # need to use this because of ruby reserved word send
      method = GmailApi.api.users.messages.discovered_methods.find {|m| m.name == 'send' }
      client.execute(method, {}, body_object: { raw: Base64.urlsafe_encode64(message.to_s) } )
    end

    def initialize(client=nil, response=nil)
      @client   = client
      @response = response
      @message  = response && JSON(response.body) || {}
    end

    def trash
    end

    # Snippet of email content
    def snippet
      @message['snippet']
    end

    def raw_content
      find_content('text/plain')
    end

    def from
      find_header_hash('from')['value']
    end

    def to
      find_header_hash('to')['value']
    end

    def cc
      find_header_hash('cc')['value']
    end

    def thread_id
      raw['threadId']
    end

    def labels
      Label.find_collection(client, raw['labelIds']).map(&:name)
    end

    def content
      Base64.urlsafe_decode64 raw_content
    end

    def html_content
      Base64.urlsafe_decode64 find_content('text/html')
    end

    def raw
      @message
    end

    private

      def find_header_hash(name)
        raw['payload']['headers'].find {|h| h['name'].downcase == name } || {}
      end

      def find_content(content_type)
        body = fetch_body || fetch_part_body(content_type)
        body.fetch('data', '')
      end

      def fetch_body
        body = @message['payload']['body']
        return if body['size'] == 0
        body
      end

      def fetch_part_body(content_type)
        part = @message['payload']['parts'] && @message['payload']['parts'].find { |hash| hash['mimeType'] =~ /#{content_type}/ } || {}
        part.fetch('body', {})
      end

  end

end