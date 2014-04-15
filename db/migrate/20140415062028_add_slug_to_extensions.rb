class AddSlugToExtensions < ActiveRecord::Migration
  def up
  	add_column :extensions, :slug, :string
  end

 

  def down
  	 remove_column :extensions, :slug
  end
end
