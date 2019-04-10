class AddRiskMatrixToRecords < ActiveRecord::Migration
  def self.up
    add_column :records, :severity, :string
    add_column :records, :likelihood, :string
    add_column :records, :risk, :string
    add_column :records, :statement, :text
  end

  def self.down
    remove_column :records, :serverity
    remove_column :records, :likelihood
    remove_column :records, :risk
    remove_column :records, :statement
  end
end
