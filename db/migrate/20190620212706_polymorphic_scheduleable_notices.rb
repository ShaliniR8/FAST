class PolymorphicScheduleableNotices < ActiveRecord::Migration
  def self.up
    [
      'Audit',
      'CorrectiveAction',
      'Evaluation',
      'Finding',
      'Im',
      'Inspection',
      'Investigation',
      'Meeting',
      'Recommendation',
      'RiskControl',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update notices set type = replace(type, '#{type}Notice', '#{type}')"
    end
    rename_column :notices, :type, :owner_type
    add_column :notices, :start_date, :datetime
    add_column :notices, :create_email, :boolean, default: false
  end

  def self.down
    [
      'Audit',
      'CorrectiveAction',
      'Evaluation',
      'Finding',
      'Im',
      'Inspection',
      'Investigation',
      'Meeting',
      'Recommendation',
      'RiskControl',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update notices set owner_type = replace(owner_type, '#{type}', '#{type}Notice')"
    end
    rename_column :notices, :owner_type, :type
    remove_column :notices, :start_date
    remove_column :notices, :create_email
  end
end
