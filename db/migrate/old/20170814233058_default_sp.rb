class DefaultSp < ActiveRecord::Migration
  def self.up
    change_column :safety_plans,:evaluation_items,:text,:default=>""
  end

  def self.down
  end
end
