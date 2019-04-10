class AddSraIdToRecord < ActiveRecord::Migration
  def self.up
    add_column :records, :sra_id, :integer
  end

  def self.down
    remove_column :records, :sra_id
  end
end
