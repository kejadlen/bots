require "rake"

require_relative "../tech_mottos"

namespace :tech_mottos do
  def tech_mottos
    wordnik = TechMottos::Wordnik.new(ENV.fetch("WORDNIK_API_KEY"))
    twitter = Twitter::Client::Authed.new(
      api_key: ENV.fetch("TWITTER_API_KEY"),
      api_secret: ENV.fetch("TWITTER_API_SECRET"),
      access_token: ENV.fetch("TWITTER_ACCESS_TOKEN"),
      access_token_secret: ENV.fetch("TWITTER_ACCESS_TOKEN_SECRET")
    )
    TechMottos::TechMottos.new(wordnik, twitter)
  end

  task :sample do
    puts tech_mottos.motto
  end

  desc "Tweet a Tech Motto"
  task :tweet do
    tech_mottos.tweet!
  end
end
