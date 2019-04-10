class AllMitigated < ActiveRecord::Migration
  def self.up
    add_column :investigations,:mitigated_severity,:string
    add_column :investigations,:mitigated_probability,:string
    add_column :hazards,:mitigated_severity,:string
    add_column :hazards,:mitigated_probability,:string
    add_column :sras,:mitigated_severity,:string
    add_column :sras,:mitigated_probability,:string
    add_column :reports,:mitigated_severity,:string
    add_column :reports,:mitigated_probability,:string
    add_column :records,:mitigated_severity,:string
    add_column :records,:mitigated_probability,:string
  end

  def self.down
  end
end
