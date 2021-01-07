class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.decimal :lat, precision: 11, scale: 8
      t.decimal :lng, precision: 11, scale: 8
      t.string :map_type
      t.belongs_to :owner, polymorphic:true, foreign_key: true, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :points
  end
end
