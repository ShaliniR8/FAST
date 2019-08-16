class SmsActionExtensionRequest < ExtensionRequest

  belongs_to :owner, foreign_key: :owner_id, class_name: 'SmsAction'


end
