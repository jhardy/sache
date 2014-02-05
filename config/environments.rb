#These Settings Establish the Proper Database Connection for Heroku Postgres
#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
#This is automatically configured on Heroku, you only need to worry if you also
#want to run your app locally
configure :production, :development do
        db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/sachein_dev')

        ActiveRecord::Base.establish_connection(
                        :adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
                        :host     => db.host,
                        :username => db.user,
                        :password => db.password,
                        :database => db.path[1..-1],
                        :encoding => 'utf8'
        )
end