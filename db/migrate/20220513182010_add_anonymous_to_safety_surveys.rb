class AddAnonymousToSafetySurveys < ActiveRecord::Migration
  def self.up
    add_column :safety_surveys, :anonymous, :boolean, :default => false
  end

  def self.down
    remove_column :safety_surveys, :anonymous
  end
end
