class InspectionNotice < Notice
  belongs_to :inspection, foreign_key: "owner_id",class_name:"Inspection"
end
