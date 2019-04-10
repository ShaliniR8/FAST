class MoreRisks < ActiveRecord::Migration
  def self.up
    add_column :records,:likelihood_after,:string
    add_column :records,:severity_after,:string
    add_column :records,:risk_factor_after,:string
    add_column :findings,:likelihood_after,:string
    add_column :findings,:severity_after,:string
    add_column :findings,:risk_factor_after,:string
    add_column :investigations,:likelihood_after,:string
    add_column :investigations,:severity_after,:string
    add_column :investigations,:risk_factor_after,:string
    add_column :hazards,:likelihood_after,:string
    add_column :hazards,:severity_after,:string
    add_column :hazards,:risk_factor_after,:string
    add_column :fields,:map_id,:integer
    add_column :templates,:map_template_id,:integer


  end

  def self.down
    remove_column :records,:likelihood_after
    remove_column :records,:severity_after
    remove_column :records,:risk_factor_after
    remove_column :findings,:likelihood_after
    remove_column :findings,:severity_after
    remove_column :findings,:risk_factor_after
    remove_column :investigations,:likelihood_after
    remove_column :investigations,:severity_after
    remove_column :investigations,:risk_factor_after
    remove_column :hazards,:likelihood_after
    remove_column :hazards,:severity_after
    remove_column :hazards,:risk_factor_after  
    remove_column :fields,:map_id
    remove_column :templates,:map_template_id
  end
end
