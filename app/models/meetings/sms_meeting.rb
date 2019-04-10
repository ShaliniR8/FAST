class SmsMeeting < Meeting
	has_many :sms_agendas,foreign_key: "owner_id",class_name: "SmsAgenda",:dependent=>:destroy
	accepts_nested_attributes_for :sms_agendas
	#validates :imp, presence: true
	

	def self.get_headers
	  [
	  	{:field=>"get_id",   															:title=>"ID"},
	  	{:field=>"get_time" ,:param=>"review_start",			:title=>"Review Start"},
	  	{:field=>"get_time" ,:param=>"review_end",				:title=>"Review End"},
	  	{:field=>"get_time" ,:param=>"meeting_start",			:title=>"Meeting Start"},
	  	{:field=>"get_time" ,:param=>"meeting_end",				:title=>"Meeting End"},
	  	{:field=>"get_host" ,															:title=>"Host"},
	  	{:field=>"status", 																:title=>"Status"}
	  ]
	end

	def get_sras_count
		0
	end

end