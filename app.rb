Dotenv.load

require 'base64'
require 'yaml'

# Can be used in ./svnth.rb like User.find, User.all etc
require './models/user'
require './models/device'
require './models/mapping_profile'
require './models/code_map'

class App < Sinatra::Base
  configure do
    enable :logging
  end
  set :environment, ENV['RACK_ENV']
  set :public_folder, Proc.new { File.join(root, "public") }
  set :views, Proc.new { File.join(root, "templates") }
  register Sinatra::ActiveRecordExtension

  require "./lib/svnth"
end
