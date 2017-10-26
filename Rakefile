require "rake/clean"

task default: "tech_mottos.zip"

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
