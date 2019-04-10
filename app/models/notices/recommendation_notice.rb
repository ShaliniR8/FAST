class RecommendationNotice < Notice
	belongs_to :recommendation, foreign_key: "owner_id",class_name:"Recommendation"
end
