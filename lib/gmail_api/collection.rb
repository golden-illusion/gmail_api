module GmailApi

  class Collection
    include Enumerable

    attr_reader :collection, :resource, :response

    def initialize(client, response, resource, &block)

      @client = client
      @collection = []
      @resource = resource
      @response = response
      @block = block

      #fail "Calls cannot be emtpy" if calls.empty?
      fail "Block must be given"   unless block_given?


      @batched_results = get_batched_results(&block)

    end

    def calls
      return [] unless JSON(@response.body)[@resource]
      JSON(@response.body)[@resource].map do |resource|
        { api_method: GmailApi.api.users.__send__(@resource).get, parameters: { id: resource['id'], format: 'full', 'userId'=>'me' } }
      end
    end

    def each(&block)
      @collection.each do |obj|
        yield(obj)
      end
    end

    def next_page
      self.class.new(@client, @client.execute(@response.next_page), @resource) do |client, result|
        @block.call(client, result)
      end
    end

    def next_page_token
      @response.next_page_token
    end

    def next_page?
      calls.any? && @response.next_page_token.nil?
    end

    def count
      JSON(@response.body)["resultSizeEstimate"]
    end

    private

    def get_batched_results(&block)
      return if calls.empty?
      @batched_results = @client.execute_batch(calls) do |result|
        @collection << yield(@client, result)
      end
    end

  end

end