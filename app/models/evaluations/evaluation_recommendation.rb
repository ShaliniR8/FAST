class EvaluationRecommendation < Recommendation
  belongs_to :evaluation, foreign_key: "owner_id", class_name:"Evaluation"
  def owner
  	self.evaluation
  end

	
end