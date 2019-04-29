class OrmSubmissionField < ActiveRecord::Base

  belongs_to :orm_field,        :foreign_key => "orm_field_id",       :class_name => "OrmField"
  belongs_to :orm_submission,   :foreign_key => "orm_submission_id",  :class_name => "OrmSubmission"



end
