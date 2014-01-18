class AddUrlToExtensions < ActiveRecord::Migration
    def change
        add_column :extensions, :url, :string
    end
end
