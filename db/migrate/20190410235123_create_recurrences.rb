class CreateRecurrences < ActiveRecord::Migration
  def self.up
    create_table 'recurrences', :force => true do |t|
      t.string :title
      t.integer :created_by_id
      t.timestamps
      t.string :status
      t.string :form_type
      t.integer :template_id
      t.string :frequency
      t.integer :next_id
      t.date :next_date
      t.date :end_date
    end
  end

  def self.down
    drop_table :recurrences
  end
end
