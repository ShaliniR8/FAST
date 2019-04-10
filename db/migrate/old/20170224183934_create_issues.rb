class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.belongs_to :faa_report
      t.date	    :issue_date
      t.string		:title
      t.string		:safety_issue
      t.string		:corrective_action
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
