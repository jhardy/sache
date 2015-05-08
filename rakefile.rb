require "./app"
require "sinatra/activerecord/rake"


desc "Update Extensions"
task :update_extensions do
    app = Sinatra::Application.new
    app.helpers.upldate_all
end


desc "Backup Production Database"
task :backup_db do
	sh "heroku pgbackups:capture --expire"
end
