class AddResponsibleUserIdToHazards < ActiveRecord::Migration
  def self.up
    add_column :hazards, :respnsible_user_id, :int
  end

  def self.down
    remove_column :hazards, :reponsible_user_id
  end
end
