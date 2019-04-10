class BaseConfig

	#########################
	# GLOBAL CONFIGURATIONS #
	#########################


	RISK_MATRIX = {
		:likelihood 			=> ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
		:severity 				=> (0..4).to_a.reverse,
		:risk_factor 			=> {"Green - Acceptable" => "lime", "Yellow - Acceptable with mitigation" => "yellow", "Orange - Unacceptable" => "orange"},
	}


	def self.airline_code
		'SCX'
	end

	def self.airline
		Object.const_get(BaseConfig.airline_code + "_Config").airline_config
	end


	def self.faa_info
		Object.const_get(BaseConfig.airline[:code] + "_Config")::FAA_INFO
	end


	def self.getTimeFormat
		{
			:timepicker 			=> "H:i",
			:datepicker 			=> "Y-m-d",
			:datetimepicker 	=> "Y-m-d H:i",
			:dateformat 			=> "%Y-%m-%d",
			:datetimeformat 	=> "%Y-%m-%d %H:%M",
		}
	end


end
