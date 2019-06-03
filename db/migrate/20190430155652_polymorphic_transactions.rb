class PolymorphicTransactions < ActiveRecord::Migration

  def self.up
    [ 'Audit',
      'CorrectiveAction',
      'Evaluation',
      'Finding',
      'Hazard',
      'Im',
      'Inspection',
      'Investigation',
      'Meeting',
      'Package',
      'Recommendation',
      'Record',
      'Report',
      'RiskControl',
      'SafetyPlan',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update transactions set type = replace(type, '#{type}Transaction', '#{type}')"
    end
    rename_column :transactions, :type, :owner_type
  end

  def self.down
    [ 'Audit',
      'CorrectiveAction',
      'Evaluation',
      'Finding',
      'Hazard',
      'Im',
      'Inspection',
      'Investigation',
      'Meeting',
      'Package',
      'Recommendation',
      'Record',
      'Report',
      'RiskControl',
      'SafetyPlan',
      'SmsAction',
      'Sra',
      'Submission'
    ].each do |type|
      execute "update transactions set owner_type = replace(owner_type, '#{type}', '#{type}Transaction')"
    end
    rename_column :transactions, :owner_type, :type
  end

end
