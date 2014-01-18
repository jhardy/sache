require 'sinatra'
require 'octokit'
require 'Haml'
require 'json'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require './config/environments' #database configuration


enable :sessions

class Extension < ActiveRecord::Base
    serialize :tags
    validates_uniqueness_of :url, {:message => 'This extension already exists.'}
end

# helpers do
#     def is_pjax?
#         #  headers['X-PJAX']
#         env['HTTP_X_PJAX']
#     end
# end

configure do
    set :root, File.dirname(__FILE__) # You must set app root
    register Sinatra::AssetPack

    assets {
        serve '/js',     from: 'app/js'        # Default
        serve '/css',    from: 'app/css'       # Default
        serve '/img',    from: 'app/img'       # Default

        # The second parameter defines where the compressed version will be served.
        # (Note: that parameter is optional, AssetPack will figure it out.)
        # The final parameter is an array of glob patterns defining the contents
        # of the package (as matched on the public URIs, not the filesystem)
        js :app,  ['/js/main.js']
    }
end


get '/' do
    @extensions = Extension.all

    haml :index

end

get '/extensions.json' do
    content_type :json
    @extensions = Extension.all.to_json
end

get '/extensions' do
    haml :index
end

post '/extensions' do

    project_url = params[:project_url]


    username = project_url[/\:(.*?)\//, 1]
    reponame = project_url[/\/(.*?).git/, 1]


    repo_info = Octokit.repo("#{username}/#{reponame}")
    parsed_params = { name: reponame, author: username, url: project_url, last_commit: repo_info.updated_at, watchers: repo_info.watchers}


    manifest_data = Octokit.contents("#{username}/#{reponame}", :path => 'sassmanifest.json', :accept => "application/vnd.github-blob.raw")
    manifest_hash = JSON.parse(manifest_data)

    manifest_hash.merge!(parsed_params)


    @extension = Extension.new(manifest_hash)

    puts @extension

    if @extension.save

        flash.now[:notice] = 'Thanks for adding your awesome exension!'
        #redirect "/", :notice => 'Thanks for adding your awesome exension!'
    else
        status 409
        flash.now[:error] = @extension.errors.first[1]
        #render :success => false, :errors => @extension.errors.full_messages
        #redirect "/", :error => @extension.errors.first[1]
    end
end



