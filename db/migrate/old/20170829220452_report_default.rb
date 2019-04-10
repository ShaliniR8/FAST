class ReportDefault < ActiveRecord::Migration
  def self.up
    change_column :reports,:statement,:text,:default=>""
    change_column :records,:statement,:text,:default=>""
  end

  def self.down
  end
end
