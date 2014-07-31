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
      client
    end

    def client
      @client ||= GmailApi.client
      @client.authorization.clear_credentials!
      @client
    end

    def execute(api_method, params={})
      result = __execute__(api_method, params)
      if result.status == 401
        result = refresh_and_retry_execution(api_method, params)
      end
      result
    end

    def authorization
      authorization = GmailApi.client_secrets.to_authorization
      authorization.update_token!(
        access_token: access_token,
        refresh_token: refresh_token
      )
      authorization
    end   

    def refresh_and_retry_execution(api_method, params)
      @client.authorization.fetch_access_token!
      __execute__(api_method, params)    
    end

    def messages(parameters={})
      Message.list(self, parameters)
    end

    private

      def __execute__(api_method, params={})
        @client.execute(
          api_method: api_method,
          parameters: params.merge('userId' => 'me'),
          authorization: authorization
        )
      end

  end  
end