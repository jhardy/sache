class AddKeywordsToExtension < ActiveRecord::Migration
  def up
  	add_column :extensions, :keywords, :string
  end

  def down
  	 remove_column :extensions, :keywords
  end
end
