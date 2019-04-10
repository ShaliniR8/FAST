class AddAnonymousToSubmissionss < ActiveRecord::Migration
  def self.up
    add_column :submissions, :anonymous, :boolean
  end

  def self.down
    remove_column :submissions, :anonymous
  end
end
