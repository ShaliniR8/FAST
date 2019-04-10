class CreateSubmissions < ActiveRecord::Migration
  def self.up
    create_table :submissions do |t|
      t.belongs_to :records
      t.belongs_to :templates
      t.text :description
      t.datetime :event_date
      t.timestamps
    end
  end

  def self.down
    drop_table :submissions
  end
end
