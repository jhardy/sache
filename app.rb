require 'sinatra'
require 'octokit'
require 'Haml'
require 'json'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'will_paginate'
require 'will_paginate/active_record'
require './config/environments' #database configuration


enable :sessions




module WillPaginate
    module ViewHelpers
        def page_entries_info(collection, options = {})
            entry_name = options[:entry_name] || (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))

            if collection.total_pages < 2
                case collection.size
                    when 0; "(No Extensions)"
                    when 1; "(1 Extension Available)"
                    else;   " "
                end
            else
                %{(%d&nbsp;-&nbsp;%d of %d)} % [
                    collection.offset + 1,
                    collection.offset + collection.length,
                    collection.total_entries
                  ]
            end
        end
    end
end

class Extension < ActiveRecord::Base

    validates_uniqueness_of :url, {:message => 'Ooops! It looks like this extension has already been added.'}
    self.per_page = 20
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


    @featured = Extension.where(:featured => true)

    @extensions = Extension.paginate(:page => params[:page], :order => 'created_at DESC')
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
    unless params[:project_url].empty?
        project_url =  %r{github\.com[:/](.+?)/(.+?)(?:\.git|)$}i.match(params[:project_url])
        username = project_url[1]
        reponame = project_url[2]
    else
        halt 404, "We appreciate minimalism, but you still actually have to provide a URL!"
    end

    begin
        repo_info = Octokit.repo("#{username}/#{reponame}")
    rescue Octokit::NotFound => e
        halt 404, "Slow down turbo! Double check that URL because the repo doesn't exist."
    end

    begin
        manifest_data = Octokit.contents("#{username}/#{reponame}", :path => 'sache.json', :accept => "application/vnd.github-blob.raw")
    rescue Octokit::NotFound => e
        halt 404, "Dang! Make sure you have a sache.json file in your repo."
    end

    manifest_hash = JSON.parse(manifest_data)

    parsed_params = { name: reponame, author: username, url: params[:project_url], last_commit: repo_info.updated_at, watchers: repo_info.watchers, keywords: manifest_hash["tags"].join(', ')}

    manifest_hash.merge!(parsed_params)
    @extension = Extension.new(manifest_hash)

    puts @extension

    if @extension.save

        flash.now[:notice] = 'Sweeeeet! Thanks for adding your exension!'
    else
        status 409
        flash.now[:error] = @extension.errors.first[1]
    end
end

get '/tag/:tag' do
    @extensions = Extension.where("? = ANY (tags)", params[:tag]).paginate(:page => params[:page], :order => 'created_at DESC')
    haml :tag
end

get '/user/:user' do
    @extensions = Extension.where(:author => params[:user]).paginate(:page => params[:page], :order => 'created_at DESC')
    haml :user
end

get '/search' do
    @extensions = Extension.where("keywords ILIKE ?", '%' + params[:query] + '%').paginate(:page => params[:page], :order => 'created_at DESC')
    haml :search
end


not_found do
    status 404
    haml :404
end

helpers do

    def truncate w
        words = w.split()
        return words[0..180].join(' ') + (words.length > 180 ? '...' : '')

    end

end