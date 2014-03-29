class AddDocsToExtensions < ActiveRecord::Migration
  def up
  	add_column :extensions, :docs, :string
  end

  def down
  	 remove_column :extensions, :docs
  end
end
