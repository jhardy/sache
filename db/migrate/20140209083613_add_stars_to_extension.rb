class AddStarsToExtension < ActiveRecord::Migration
  def up
  	add_column :extensions, :stars, :integer
  end

  def down
  	 remove_column :extensions, :stars
  end
end
