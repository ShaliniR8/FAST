class JobAid < Im
	has_many :items,foreign_key:"owner_id",class_name:"JobAidItem",:dependent=>:destroy
	def self.display_name
		"Job Aid"
	end

	def self.get_headers
	  [
	  	{:field=>"get_id", :title=>"ID"},
	  	{:field=>"title" ,:size=>"",:title=>"Title"},
	  	{:field=>"job_aid",:size=>"",:title=>"Job Aid"},
	  	{:field=>"get_completion_date",:size=>"",:title=>'Scheduled Completion Date'},
	  	{:field=>"get_eva",:size=>"",:title=>'Lead Evaluator'},
	  	{:field=>"get_rev",:size=>"",:title=>'Preliminary Reviewer'},
	  	{:field=>"status",:size=>"",:title=>"Status"}
	  ]
	end
end
