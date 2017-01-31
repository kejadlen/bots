require "tech_mottos/version"

require "active_support"
require "twitter"

module TechMottos
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

  class TechMottos
    attr_reader :wordnik, :inflector, :twitter

    def initialize
      @wordnik = Wordnik.new(ENV.fetch("WORDNIK_API_KEY"))
      @inflector = ActiveSupport::Inflector
      @twitter = Twitter::Client::Authed.new(
        api_key: ENV.fetch("TWITTER_API_KEY"),
        api_secret: ENV.fetch("TWITTER_API_SECRET"),
        access_token: ENV.fetch("TWITTER_ACCESS_TOKEN"),
        access_token_secret: ENV.fetch("TWITTER_ACCESS_TOKEN_SECRET")
      )
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
      twitter.conn.post("statuses/update.json", status: motto)
    end
  end
end
