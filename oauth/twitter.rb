require "faraday"
require "faraday_middleware"

module Twitter
  class RateLimitedError < StandardError
    attr_reader :reset_at

    def initialize(reset_at:)
      @reset_at = reset_at
    end
  end

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
end
