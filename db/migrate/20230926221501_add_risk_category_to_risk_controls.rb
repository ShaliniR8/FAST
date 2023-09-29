class AddRiskCategoryToRiskControls < ActiveRecord::Migration
  def self.up
    add_column :risk_controls, :risk_category, :string
    CustomOption.create(title: "Risk Categories",  description: "This contains a list of risk categories")
  end

  def self.down
    remove_column :risk_controls, :risk_category
    CustomOption.where(title: "Risk Categories").first.destroy
  end
end
