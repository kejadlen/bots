require "active_support"
require "faraday"
require "faraday_middleware"

class Wordnik
  URL = "http://api.wordnik.com/v4/"

  attr_reader :conn

  def initialize(api_key)
    @conn = Faraday.new(url: URL, params: { api_key: api_key }) { |conn|
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    }
  end

  def random_words(params)
    params[:minCorpusCount] ||= 2
    params[:minDictionaryCount] ||= 3
    conn.get("words.json/randomWords", params).body.map {|word| word["word"] }
  end
end

class Twitter
  attr_reader :conn

  def initialize(api_key, api_secret, access_token, access_token_secret)
    @conn = Faraday.new('https://api.twitter.com/1.1') do |conn|
      conn.request :url_encoded
      conn.request :oauth, {
        consumer_key: api_key,
        consumer_secret: api_secret,
        token: access_token,
        token_secret: access_token_secret,
      }

      conn.response :raise_error

      conn.adapter Faraday.default_adapter
    end
  end

  def tweet(text)
    conn.post('statuses/update.json', status: text)
  end
end

class TechMottos
  attr_reader :wordnik, :inflector, :twitter

  def initialize
    @wordnik = Wordnik.new(ENV.fetch("WORDNIK_API_KEY"))
    @inflector = ActiveSupport::Inflector
    @twitter = Twitter.new(ENV.fetch("TWITTER_API_KEY"),
                           ENV.fetch("TWITTER_API_SECRET"),
                           ENV.fetch("TWITTER_ACCESS_TOKEN"),
                           ENV.fetch("TWITTER_ACCESS_TOKEN_SECRET"))
  end

  def motto
    nouns = wordnik.random_words(includePartOfSpeech: :noun)
    verbs = wordnik.random_words(includePartOfSpeech: "verb-transitive")
    adverbs = wordnik.random_words(includePartOfSpeech: :adverb)

    verb_1, verb_2 = verbs.sample(2)
    adverb = adverbs.sample
    noun = inflector.pluralize(nouns.sample)
    [verb_1.capitalize, adverb, "and", verb_2, noun].join(" ")
  end

  def tweet!
    twitter.tweet(motto)
  end
end

if __FILE__ == $0
  TechMottos.new.tweet!
end
