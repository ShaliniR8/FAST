class CreateFrameworkExpectations < ActiveRecord::Migration
  def self.up
    create_table :framework_expectations do |t|
      t.belongs_to :framework
      t.belongs_to :user
      t.string	   :title
      t.string     :revision_level
      t.date	   :revision_date
      t.string     :department
      t.string     :reference_number
      t.text       :reference
      t.text       :expectation
      t.text       :instruction
      t.timestamps
    end
  end

  def self.down
    drop_table :framework_expectations
  end
end
