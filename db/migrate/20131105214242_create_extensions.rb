class CreateExtensions < ActiveRecord::Migration
  def up
    create_table :extensions do |t|
        t.string    :name
        t.text      :description
        t.text      :tags
        t.string    :author
        t.string    :watchers
        t.string    :website
        t.string    :version
        t.string    :sass_version
        t.timestamps
    end

  end

  def down
    drop_table :extensions
  end
end
