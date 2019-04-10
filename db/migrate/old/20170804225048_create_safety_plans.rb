class CreateSafetyPlans < ActiveRecord::Migration
  def self.up
    create_table :safety_plans do |t|
      t.string :title
      t.string :risk_factor
      t.text :concern
      t.text :objective
      t.text :background
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :safety_plans
  end
end
