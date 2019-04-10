class CreateViewerComments < ActiveRecord::Migration
  def self.up
    create_table :viewer_comments do |t|
      t.string :type
      t.belongs_to :owner
      t.text :content
      t.belongs_to :user
      
      t.timestamps
    end
  end

  def self.down
    drop_table :viewer_comments
  end
end
