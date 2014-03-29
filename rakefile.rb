require "./app"
require "sinatra/activerecord/rake"


desc "Update Extensions"
task :update_extensions do
    app = Sinatra::Application.new
    app.helpers.upldate_all
end
