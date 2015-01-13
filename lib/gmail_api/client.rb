module GmailApi
  class Client

    attr_reader :access_token, :refresh_token

    #
    # Set up new client to access gmail api
    #
    def initialize(access_token: nil, refresh_token: nil)
      @access_token = access_token
      @refresh_token = refresh_token
      fail AccessTokenMissing.new('Access token is required') if access_token.nil?
      authorization
      client
    end

    def client
      @client ||= GmailApi.client
      @client.authorization.clear_credentials!
      @client
    end

    def execute(api_method, params={}, options={})
      result = __execute__(api_method, params, options)
      if result.status == 401
        result = refresh_and_retry_execution(api_method, params, options)
      end
      result
    end

    def authorization
      @authorization ||= GmailApi.client_secrets.to_authorization
      @authorization.update_token!(
        access_token: access_token,
        refresh_token: refresh_token
      )
      @authorization
    end

    def refresh_and_retry_execution(api_method, params, options)
      @authorization.refresh!
      __execute__(api_method, params, options)
    rescue ::Signet::AuthorizationError => e
      return e.response.body
    end

    def execute_batch(calls, &block)
      batch = Google::APIClient::BatchRequest.new do |result|
        yield(result)
      end
      @authorization.refresh!
      @client.authorization = @authorization
      calls.each do |c|
        c[:authorization] = @authorization
        batch.add(c)
      end
      @client.execute(batch)
    end

    def messages(parameters={})
      Message.list(self, parameters)
    end

    def threads(parameters={})
      Thread.list(self, parameters)
    end

    def send_mail(params={}, options={}, thread_id=nil, attachments)
      Message.create(self, params, options, thread_id, attachments)
    end

    def user_profile
      User.user_profile self
    end

    def create_label request_body={}, headers={}
      Label.create self, request_body, headers
    end

    def find type, params={}
      type = GmailApi.const_get(type) if GmailApi.const_defined?(type)
      if type.respond_to? :find
        type.find(self, params)
      end
    end

    def attachment_name_valid? message_id, filename
      filenames = Message.find(self, message_id).attachments.map do |attachment|
        attachment[:filename] if attachment.has_key?(:filename)
      end
      filenames.include? filename
    end

    def modify_message params={}, options={}
      Message.modify self, params, options
    end

    def find_by name: name
      Label.find_by self, name: name
    end

    private

      def __execute__(api_method, params={}, options={})
        if api_method.is_a?(Google::APIClient::Request)
          options = api_method
        else
          options.merge!(
            api_method: api_method,
            parameters: params.merge('userId' => 'me'),
            authorization: @authorization
          )
        end
        @client.execute(options)
      end

  end
end