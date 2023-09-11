class AddOperationTypeToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :operation_type, :string
  end

  def self.down
    remove_column :reports, :operation_type
  end
end
