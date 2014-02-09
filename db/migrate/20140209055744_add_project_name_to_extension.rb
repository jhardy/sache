class AddProjectNameToExtension < ActiveRecord::Migration
  def up
  	add_column :extensions, :project_name, :string
  end

  def down
  	 remove_column :extensions, :project_name
  end
end
