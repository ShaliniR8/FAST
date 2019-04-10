class InvestigationRecommendation < Recommendation
  belongs_to :investigation,foreign_key: "owner_id",class_name:"Investigation"
  
  def owner
  	self.investigation
  end


	def get_source
		"<a style='font-weight:bold' href='/investigations/#{owner.id}'>
			Investigation ##{owner.id}
		</a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
	end

	
end