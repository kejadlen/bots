require "rake/clean"

task default: %w[ tech_mottos alpha_bot ].map {|x| "#{x}.zip" }

# http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html
file "tech_mottos.zip" => `git ls-files tech_mottos/*.py`.split("\n") do |t|
  zip_path = File.expand_path("../#{t.name}", __FILE__)

  chdir "tech_mottos" do
    files = t.prerequisites.map {|p| p.sub(/^tech_mottos\//, "") }
    sh "zip", zip_path, *files
  end

  chdir "#{ENV.fetch("VIRTUAL_ENV")}/lib/python3.6/site-packages" do
    rm_r FileList["**/__pycache__"]
    sh "zip \"#{zip_path}\" -r *"
  end
end
CLOBBER << "tech_mottos.zip"

file "alpha_bot.zip" => `git ls-files alpha_bot/*.py`.split("\n") do |t|
  zip_path = File.expand_path("../#{t.name}", __FILE__)

  chdir "alpha_bot" do
    files = t.prerequisites.map {|p| p.sub(/^alpha_bot\//, "") }
    sh "zip", zip_path, *files

    sh "pipenv lock --requirements > requirements.txt"
    sh "pipenv run pip install --target vendor --requirement requirements.txt"

    chdir "vendor" do
      rm_r FileList["**/__pycache__"]
      sh "zip \"#{zip_path}\" -r *"
    end

    rm "requirements.txt"
  end
end
CLOBBER << "alpha_bot.zip"
