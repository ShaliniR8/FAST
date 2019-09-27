class AddMeetingTitleToMeetings < ActiveRecord::Migration
  def self.up
    add_column :meetings, :title, :string
    CustomOption.create(
      title: 'Meeting Titles',
      field_type: 'Checkbox',
      options: 'ASAP Meeting;Fatigue Meeting;Incident Meeting',
      description: 'This manages options for Meeting Title.'
    )
  end

  def self.down
    remove_column :meetings, :title
    CustomOption.where(title: 'Meeting Titles').destroy_all
  end
end
