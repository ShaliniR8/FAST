class SetDefault < ActiveRecord::Migration
  def self.up
    change_column :audits,:status,:string,:default=>"New"
  end

  def self.down
  end
end
