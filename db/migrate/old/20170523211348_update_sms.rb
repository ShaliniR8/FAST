class UpdateSms < ActiveRecord::Migration
  def self.up
    add_column :expectations,:type,:string
  end

  def self.down
  end
end
