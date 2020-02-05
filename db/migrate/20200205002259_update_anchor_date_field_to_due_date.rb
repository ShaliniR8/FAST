class UpdateAnchorDateFieldToDueDate < ActiveRecord::Migration
  def self.up
    AutomatedNotification.all.each do |notification|
      notification.anchor_date_field = 'due_date'
      notification.save
    end
  end

  def self.down
  end
end
