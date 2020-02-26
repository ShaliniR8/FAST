class AddAsapClosingFieldsToRecords < ActiveRecord::Migration
  def self.up
    add_column :records,  :eir,                  :string
    add_column :records,  :scoreboard,           :boolean
    add_column :records,  :asap,                 :boolean
    add_column :records,  :sole,                 :boolean
    add_column :records,  :disposition,          :string
    add_column :records,  :company_disposition,  :string
    add_column :records,  :narrative,            :text
    add_column :records,  :regulation,           :text
    add_column :records,  :notes,                :text
  end

  def self.down
    remove_column :records,  :eir
    remove_column :records,  :scoreboard
    remove_column :records,  :asap
    remove_column :records,  :sole
    remove_column :records,  :disposition
    remove_column :records,  :company_disposition
    remove_column :records,  :narrative
    remove_column :records,  :regulation
    remove_column :records,  :notes
  end
end
