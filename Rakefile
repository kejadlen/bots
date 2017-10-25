# http://docs.aws.amazon.com/lambda/latest/dg/lambda-python-how-to-create-deployment-package.html
desc "Create a deployment package"
task :package, [:dir] do |_, args|
  dir = args.fetch(:dir)
  zip = File.expand_path("../#{dir}.zip", __FILE__)

  chdir dir do
    cmd = [ "zip", zip ]

    files = `git ls-files *.py`.split("\n")
    cmd.concat(files)

    sh *cmd
  end

  chdir "#{ENV.fetch("VIRTUAL_ENV")}/lib/python3.6/site-packages" do
    rm_r FileList["**/__pycache__"]
    sh "zip \"#{zip}\" -r *"
  end
end
