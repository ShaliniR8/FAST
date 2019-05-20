class EvaluationComment < ViewerComment
  belongs_to :evaluation,foreign_key: "owner_id",class_name: "Evaluation"

end
