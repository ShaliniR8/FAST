class AddAltUserToViewerCommentsAndTransactions < ActiveRecord::Migration
  def self.up
    add_column :viewer_comments, :alt_user, :string
    add_column :transactions, :alt_user, :string
  end

  def self.down
    remove_column :viewer_comments, :alt_user
    remove_column :transactions, :alt_user
  end
end
