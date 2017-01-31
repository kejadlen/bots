require "rake"

require_relative "../tech_mottos"

namespace :tech_mottos do
  desc "Tweet a Tech Motto"
  task :tweet do
    wordnik = TechMottos::Wordnik.new(ENV.fetch("WORDNIK_API_KEY"))
    twitter = Twitter::Client::Authed.new(
      api_key: ENV.fetch("TWITTER_API_KEY"),
      api_secret: ENV.fetch("TWITTER_API_SECRET"),
      access_token: ENV.fetch("TWITTER_ACCESS_TOKEN"),
      access_token_secret: ENV.fetch("TWITTER_ACCESS_TOKEN_SECRET")
    )
    tech_mottos = TechMottos::TechMottos.new(wordnik, twitter)
    tech_mottos.tweet!
  end
end
