class AddFeaturedToExtensions < ActiveRecord::Migration
  def up
  	add_column :extensions, :featured, :boolean, defaut: false
  end

  def down
  	 remove_column :extensions, :featured
  end
end
