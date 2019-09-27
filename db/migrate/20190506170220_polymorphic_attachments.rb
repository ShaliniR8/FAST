class PolymorphicAttachments < ActiveRecord::Migration
  def self.up
    [
      'Audit',
      'CorrectiveAction',
      'Document',
      'Evaluation',
      'Finding',
      'Hazard',
      'Inspection',
      'Investigation',
      'MeetingAttachmnet',
      'Message',
      'Record',
      'Report',
      'RiskControl',
      'SafetyPlan',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update attachments set type = replace(type, '#{type}Attachment', '#{type}')"
    end
    rename_column :attachments, :type, :owner_type
  end

  def self.down
    [
      'Audit',
      'CorrectiveAction',
      'Document',
      'Evaluation',
      'Finding',
      'Hazard',
      'Inspection',
      'Investigation',
      'MeetingAttachmnet',
      'Message',
      'Record',
      'Report',
      'RiskControl',
      'SafetyPlan',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update attachments set owner_type = replace(owner_type, '#{type}', '#{type}Attachment')"
    end
    rename_column :attachments, :owner_type, :type
  end
end
