class ChangeDispositionsInAgendaToString < ActiveRecord::Migration
  def self.up
    change_column :agendas, :accepted, :string
  end

  def self.down
  end
end
