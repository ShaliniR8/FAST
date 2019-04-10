class AddClosingDateToMeetings < ActiveRecord::Migration
  def self.up
	add_column :meetings, :closing_date, :datetime
  end

  def self.down
	remove_column :meetings, :closing_date
  end
end
