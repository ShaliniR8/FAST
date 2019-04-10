class UpdateExpectation < ActiveRecord::Migration
  def self.up
    rename_table :framework_expectations,:expectations
  end

  def self.down
  end
end
