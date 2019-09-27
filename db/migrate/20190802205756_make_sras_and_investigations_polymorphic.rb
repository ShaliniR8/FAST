class MakeSrasAndInvestigationsPolymorphic < ActiveRecord::Migration
  def self.up
    %w[investigations sras].each do |table|
      rename_column table.to_sym, :record_id, :owner_id
      add_column table.to_sym, :owner_type, :string
      execute "UPDATE #{table} SET owner_type = 'Record' WHERE owner_id IS NOT NULL"
      remove_column :records, "#{table[0..-2]}_id".to_sym
    end
  end

  def self.down
    %w[investigations sras].each do |table|
      execute "UPDATE #{table} SET owner_id=NULL WHERE owner_type='Event'"
      remove_column table.to_sym, :owner_type
      rename_column table.to_sym, :owner_id, :record_id
      add_column :records, "#{table[0..-2]}_id".to_sym, :integer
    end
  end
end
