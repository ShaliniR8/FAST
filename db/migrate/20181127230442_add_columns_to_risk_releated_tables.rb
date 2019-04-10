class AddColumnsToRiskReleatedTables < ActiveRecord::Migration
  def self.up
    add_column :risk_matrix_tables, :row_count, :integer
    add_column :risk_matrix_tables, :column_count, :integer
  end

  def self.down
    remove_column :risk_matrix_tables, :row_count
    remove_column :risk_matrix_tables, :column_count
  end
end
