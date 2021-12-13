class CreateNewsletterAttachments < ActiveRecord::Migration
  def self.up
    create_table :newsletter_attachments do |t|
      t.string     :name
      t.string     :caption
      t.belongs_to :owner, polymorphic:true, foreign_key: true, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletter_attachments
  end
end
