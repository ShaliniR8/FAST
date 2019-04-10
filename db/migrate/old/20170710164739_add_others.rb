class AddOthers < ActiveRecord::Migration
  def self.up
    add_column :sras,:other_department,:string
    add_column :sras,:other_manual,:string
    add_column :sras,:other_program,:string
  end

  def self.down
  end
end
