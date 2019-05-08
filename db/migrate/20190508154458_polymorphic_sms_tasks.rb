class PolymorphicSmsTasks < ActiveRecord::Migration
  def self.up
    [
      'Audit',
      'Finding',
      'Evaluation',
      'Inspection',
      'Investigation'
    ].each do |type|
      execute "update sms_tasks set type = replace(type, '#{type}Task', '#{type}')"
    end
    rename_column :sms_tasks, :type, :owner_type
  end

  def self.down
    [
      'Audit',
      'Finding',
      'Evaluation',
      'Inspection',
      'Investigation'
    ].each do |type|
      execute "update sms_tasks set owner_type = replace(owner_type, '#{type}', '#{type}Task')"
    end
    rename_column :sms_tasks, :owner_type, :type
  end
end
