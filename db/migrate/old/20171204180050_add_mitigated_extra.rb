class AddMitigatedExtra < ActiveRecord::Migration
  def self.up
    add_column :findings,:mitigated_severity,:string
    add_column :findings,:mitigated_probability,:string
    add_column :findings,:extra_risk,:string
    add_column :findings,:mitigated_risk,:string
  end

  def self.down
  end
end
