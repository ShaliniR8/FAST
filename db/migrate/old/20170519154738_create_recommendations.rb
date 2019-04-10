class CreateRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.belongs_to :owner
      t.string :status,:default=>"New"
      t.string :type
      t.string :title
      t.string :department
      t.belongs_to :user
      t.date :response_date
      t.boolean :immediate_action
      t.string  :recommended_action
      t.text 	:description 
      t.timestamps
    end
  end

  def self.down
    drop_table :recommendations
  end
end
