class RefactorNotices < ActiveRecord::Migration
  def self.up
    remove_column :notices, :expire_date
    remove_column :notices, :action
    remove_column :notices, :create_email

    change_column :notices, :status, :integer, :default => 1

    add_column :notices, :end_date, :date
    add_column :notices, :category, :integer, :default => 1
  end

  def self.down
    add_column :notices, :expire_date, :date
    add_column :notices, :action, :string
    add_column :notices, :create_email, :boolean

    change_column :notices, :status, :string

    remove_column :notices, :end_date
    remove_column :notices, :category
  end
end
