class MoreSp < ActiveRecord::Migration
  def self.up
    add_column :safety_plans,:status,:string,:default=>"New"
  end

  def self.down
  end
end
