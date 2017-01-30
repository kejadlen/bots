require "twitter/version"

require "faraday"
require "faraday_middleware"

module Twitter
  class Client
    attr_reader :api_key, :api_secret

    def initialize(api_key:, api_secret:)
      @api_key, @api_secret = api_key, api_secret
    end
  end

  class Client::OAuth < Client
    def request_token(callback:)
      resp = conn(callback: callback).post("request_token")
      Faraday::Utils.parse_query(resp.body)
    end

    def access_token(token:, token_secret:, oauth_verifier:)
      oauth = { token: token, token_secret: token_secret }
      resp = conn(oauth).post("access_token", oauth_verifier: oauth_verifier)
      Faraday::Utils.parse_query(resp.body)
    end

    private

    def conn(**oauth)
      return @conn if defined?(@conn)

      oauth = {
        consumer_key: api_key,
        consumer_secret: api_secret
      }.merge(oauth)

      @conn = Faraday.new("https://api.twitter.com/oauth") do |conn|
        conn.request :url_encoded
        conn.request :oauth, oauth

        conn.response :raise_error

        conn.adapter Faraday.default_adapter
      end
    end
  end

  class Client::Authed < Client
    attr_reader :access_token, :access_token_secret

    def initialize(api_key:, api_secret:,
                   access_token:, access_token_secret:)
      super(api_key: api_key, api_secret: api_secret)

      @access_token, @access_token_secret = access_token, access_token_secret

      @conn = Faraday.new("https://api.twitter.com/1.1") do |conn|
        conn.request :oauth,
          consumer_key: api_key,
          consumer_secret: api_secret,
          token: access_token,
          token_secret: access_token_secret
        conn.request :json
        conn.request :url_encoded

        conn.response :raise_error
        conn.response :json, :content_type => /\bjson$/

        conn.adapter Faraday.default_adapter
      end
    end
  end
end
