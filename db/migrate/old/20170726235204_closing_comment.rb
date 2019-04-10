class ClosingComment < ActiveRecord::Migration
  def self.up
    add_column :sras,:closing_comment,:text
  end

  def self.down
  end
end
