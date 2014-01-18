class AddLastCommitToExtensions < ActiveRecord::Migration
    def change
        add_column :extensions, :last_commit, :datetime
    end
end
