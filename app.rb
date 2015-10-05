require 'dotenv'
Dotenv.load

require 'sinatra/base'
require 'sinatra/activerecord'

require 'thin'
require 'has_secure_token'
require 'bcrypt'
require 'yaml'

# Can be used in ./svnth.rb like User.find, User.all etc
require './models/user'

class App < Sinatra::Base
  configure do
    enable :logging
  end
  set :environment, ENV['RACK_ENV']
  set :public_folder, Proc.new { File.join(root, "public") }
  set :views, Proc.new { File.join(root, "templates") }
  register Sinatra::ActiveRecordExtension

  require "./lib/svnth"

  EventMachine.run do
    Thin::Server.start App, '0.0.0.0', 4000
  end
end
