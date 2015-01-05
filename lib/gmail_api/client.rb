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

    def messages(parameters={}, options={})
      Message.list(self, parameters, options)
    end

    def threads(parameters={})
      Thread.list(self, parameters)
    end

    def send_mail(params={})
      Message.create(self, params)
    end

    def user_profile
      User.user_profile self
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