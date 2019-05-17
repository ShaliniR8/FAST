class AccessLevel < ActiveRecord::Base

  belongs_to :user, foreign_key: 'user_id', class_name: 'User'



  def self.report_types
    [
      'Audit',
      # 'Inspection',
      # 'Evaluation',
      # 'Investigation',
      # 'Corrective Action',
      # 'Recommendation',
    ]
  end

end
