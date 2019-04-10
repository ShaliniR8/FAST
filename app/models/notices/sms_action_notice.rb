class SmsActionNotice < Notice
	belongs_to :sms_action, foreign_key: "owner_id",class_name:"SmsAction"
end
