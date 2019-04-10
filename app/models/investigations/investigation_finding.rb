class InvestigationFinding < Finding
	belongs_to :owner,foreign_key:"audit_id",class_name:"Investigation"


	def get_source
		"<a style='font-weight:bold' href='/investigations/#{owner.id}'>
			Investigation ##{owner.id}
		</a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
	end

end