class CreateSubscriptionsTable < ActiveRecord::Migration
  def self.up
    create_table :subscriptions, :force => true do |t|
      t.timestamps
      t.integer :user_id, foreign_key: true
      t.integer :frequency
      t.string :day
      t.belongs_to :owner, polymorphic:true, foreign_key: true, index: true
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
