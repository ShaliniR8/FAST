class CreateAgendas < ActiveRecord::Migration
  def self.up
    create_table :agendas do |t|
      t.string :type
      t.belongs_to :owner
      t.belongs_to :event
      t.belongs_to :user
      t.string :title
      t.string :status
      t.boolean :discussion
      t.boolean :accepted
      t.text    :comment
      t.timestamps
    end
  end

  def self.down
    drop_table :agendas
  end
end
