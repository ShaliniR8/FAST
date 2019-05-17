class SubmissionTransaction < Transaction
  belongs_to :submission, foreign_key: "owner_id", class_name: "Submission"

end
