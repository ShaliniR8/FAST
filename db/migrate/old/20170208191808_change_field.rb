class ChangeField < ActiveRecord::Migration
  def self.up
    change_column :submission_fields,:value,:text
    change_column :record_fields,:value,:text
  end

  def self.down
    change_column :submission_fields,:value,:string
    change_column :record_fields,:value,:string
  end
end
