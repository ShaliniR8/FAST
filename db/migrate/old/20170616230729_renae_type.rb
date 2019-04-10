class RenaeType < ActiveRecord::Migration
  def self.up
    rename_column :evaluations,:inspection_type,:evaluation_type
  end

  def self.down
  end
end
