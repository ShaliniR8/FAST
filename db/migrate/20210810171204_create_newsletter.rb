class CreateNewsletter < ActiveRecord::Migration
  def self.up
    create_table :newsletters do |t|
      t.string  :title
      t.string  :status, index: true
      t.text    :distribution_list
      t.date    :complete_by_date, index: true
      t.date    :publish_date, index: true
      t.date    :archive_date, index: true
      t.integer :user_id, foreign_key: true, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :newsletters
  end
end
