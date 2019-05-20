class InvestigationActionNotification < SmsActionNotification

  belongs_to :owner, foreign_key: :owner_id, class_name: 'InvestigationAction'




end
