class SmsActionTransaction < Transaction
  belongs_to :sms_action, foreign_key: "owner_id",class_name:"Sms Action"
end
