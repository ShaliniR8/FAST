class CreateSubmissionFields < ActiveRecord::Migration
  def self.up
    create_table :submission_fields do |t|
      t.string :value
      t.belongs_to :submissions
      t.belongs_to :fields
      t.timestamps
    end
  end

  def self.down
    drop_table :submission_fields
  end
end
