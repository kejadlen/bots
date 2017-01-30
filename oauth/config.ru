require "roda"

require_relative "twitter"

class App < Roda
  use Rack::Session::Cookie, secret: ENV["SECRET"]

  plugin :render

  route do |r|
    twitter = Twitter::Client::OAuth.new(
      api_key: ENV.fetch("TWITTER_API_KEY"),
      api_secret: ENV.fetch("TWITTER_API_SECRET"),
    )

    r.root do
      callback = "http://#{r.host_with_port}/tokens"
      request_token = twitter.request_token(callback: callback)

      r.session[:token] = request_token["oauth_token"]
      r.session[:token_secret] = request_token["oauth_token_secret"]

      url = "https://api.twitter.com/oauth/authorize?oauth_token=#{r.session[:token]}"
      r.redirect url
    end

    r.get "tokens" do
      token = r.session.delete(:token)
      token_secret = r.session.delete(:token_secret)

      access_token = twitter.access_token(
        token: token,
        token_secret: token_secret,
        oauth_verifier: r.params["oauth_verifier"],
      )

      @oauth_token = access_token["oauth_token"]
      @oauth_token_secret = access_token["oauth_token_secret"]

      view :tokens
    end
  end
end

run App.freeze.app
