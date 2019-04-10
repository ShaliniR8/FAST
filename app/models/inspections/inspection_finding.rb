class InspectionFinding < Finding
	
	belongs_to :owner, foreign_key: "audit_id", class_name:"Inspection"


	def get_source
		"<a style='font-weight:bold' href='/inspections/#{owner.id}'>
			Inspection ##{owner.id}
		</a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
	end

end