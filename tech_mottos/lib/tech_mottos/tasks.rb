require "rake"

require_relative "../tech_mottos"

namespace :tech_mottos do
  desc "Tweet a Tech Motto"
  task :tweet do
    TechMottos::TechMottos.new.tweet!
  end
end
