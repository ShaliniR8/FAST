class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :category
      t.string :link
      t.string :title
      t.belongs_to :users
      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
