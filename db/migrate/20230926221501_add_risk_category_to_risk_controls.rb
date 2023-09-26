class AddRiskCategoryToRiskControls < ActiveRecord::Migration
  def self.up
    add_column :risk_controls, :risk_category, :string
  end

  def self.down
    remove_column :risk_controls, :risk_category
  end
end
