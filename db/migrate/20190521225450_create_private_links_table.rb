class CreatePrivateLinksTable < ActiveRecord::Migration
  def self.up
    create_table "private_links", :force => true do |t|
      t.string      :email
      t.string      :name
      t.string      :digest
      t.date        :expire_date
      t.string      :access_level
      t.string      :link
      t.timestamps
    end
  end

  def self.down
    drop_table :private_links
  end
end
