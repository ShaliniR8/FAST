class AddObjIdToAgendas < ActiveRecord::Migration
  def self.up
    add_column :agendas, :obj_id, :integer
    add_column :agendas, :user_poc_id, :integer
  end

  def self.down
    remove_column :agendas, :user_poc_id
    remove_column :agendas, :obj_id
  end
end
