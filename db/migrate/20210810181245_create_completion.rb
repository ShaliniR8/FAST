class CreateCompletion < ActiveRecord::Migration
  def self.up
    create_table :completions do |t|
      t.integer    :user_id
      t.date       :complete_date
      t.belongs_to :owner, polymorphic:true, foreign_key: true, index: true

      t.timestamps
    end
  end

  def self.down
    drop_table :completions
  end
end
