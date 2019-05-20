class FindingActionNotification < SmsActionNotification

  belongs_to :owner, foreign_key: :owner_id, class_name: 'FindingAction'




end
