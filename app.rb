require "bundler/setup"
require 'sinatra'
require "sinatra/reloader"
require 'octokit'
require 'haml'
require 'json'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'sinatra/activerecord'
require 'sinatra/assetpack'
require 'will_paginate'
require 'will_paginate/active_record'
require 'friendly_id'

require './config/environments' #database configuration
require './env' if File.exists?('env.rb')

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
    include FriendlyId
    friendly_id :name, :use => :slugged

    validates_uniqueness_of :url, {:message => 'Ooops! It looks like this extension has already been added.'}
    self.per_page = 20

end


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

configure :development do
    register Sinatra::Reloader
end


get '/' do
    #hacky, TODO make this more robust
    ids = [37, 28, 12]
    begin
        @featured = Extension.find(ids)
    rescue ActiveRecord::RecordNotFound => e
        @featured = nil
    end

    @extensions = Extension.paginate(:page => params[:page], :order => sort_column + ' ' + sort_direction)
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
        #%r{github\.com[:/](.+?)/(.+?)(?:\.git|)$}i.match(params[:project_url])    
        begin
            project_url =  %r{github\.com[:/](.+?)/(.+?)(?:\.git)$}i.match(params[:project_url])
            username = project_url[1]
            reponame = project_url[2]
        rescue NoMethodError => e
            halt 400, "That URL looks funny, make sure you use the github SSH URL for your repo"
        end
    else
        halt 400, "We appreciate minimalism, but you still actually have to provide a URL!"
    end

    begin
        client = Octokit::Client.new \
            :client_id => ENV['Github_Client_ID'],
            :client_secret => ENV['Github_Client_Secret']
        repo_info = client.repository("#{username}/#{reponame}")
    rescue Octokit::NotFound => e
        halt 400, "Slow down turbo! Double check that URL because the repo doesn't exist."
    end

    begin
        manifest_data = get_manifest_data(client, username, reponame)
    rescue Octokit::NotFound => e
        halt 400, "Dang! Make sure you have a sache.json file in your repo."
    end

    manifest_hash = set_manifest_hash(manifest_data, repo_info, username, reponame, params[:project_url])
   
    @extension = Extension.new(manifest_hash)

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

get '/search' do
    @extensions = Extension.where("(keywords ILIKE ?) OR (name ILIKE ?)", '%' + params[:query] + '%', '%' + params[:query] + '%').paginate(:page => params[:page], :order => 'created_at DESC')
    haml :search
end

get '/:user' do
    @extensions = Extension.where(:author => params[:user]).paginate(:page => params[:page], :order => 'created_at DESC')
    haml :user
end

get '/project/:id.json' do
    content_type :json
    @extension = Extension.find(params[:id]).to_json
end

get '/project/:project_name' do
    @extensions = Extension.friendly.find(params[:project_name])
    haml :project
end

get '/promote' do
    haml :promote
end

not_found { haml :'404' }

helpers do

    def truncate w
        words = w.split()
        return words[0..40].join(' ') + (words.length > 40 ? '...' : '')
    end

    def sort_column
        Extension.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
        %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def sortable(column, title)
        css_class = column == sort_column ? "current #{sort_direction}" : nil
        direction = column == sort_column && sort_direction == "asc" ? "desc" : "asc"

        "<a data-sort='#{column}' data-direction='#{direction}' class='#{css_class}'>" + title + "</a>"
    end

    def get_manifest_data(client, username, reponame)
        #begin
            manifest_data = client.contents("#{username}/#{reponame}", :path => 'sache.json', :accept => "application/vnd.github-blob.raw")
        #rescue Octokit::NotFound => e
            #halt 400, "Dang! Make sure you have a sache.json file in your repo."
        #end
    end

    def set_manifest_hash(data, repo, username, reponame, url)
        hash = JSON.parse(data)
        parsed_params = { project_name: reponame, author: username, url: url, last_commit: repo.updated_at, stars: repo.watchers, keywords: hash["tags"].join(', '), website: repo.website, docs: repo.docs }
        hash.merge!(parsed_params)
    end

    def set_github_client
        client = Octokit::Client.new \
            :client_id => ENV['Github_Client_ID'],
            :client_secret => ENV['Github_Client_Secret']
    end


    def update_all
        @extensions = Extension.all
        @extensions.each do |e|        
            update(e.id)
        end
    end

    def update id

        client = set_github_client()
        e = Extension.find(id)
        begin
            repo = client.repository("#{e.author}/#{e.project_name}")
            manifest_data = get_manifest_data(client, e.author, e.project_name)
            manifest_hash = set_manifest_hash(manifest_data, repo, e.author, e.project_name, e.url)

            manifest_hash.each{|k, v|; e[k] = v; }
            e.save        

        rescue Octokit::NotFound => k
            e.destroy
        end
    end

end