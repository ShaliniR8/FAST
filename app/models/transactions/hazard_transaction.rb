class HazardTransaction < Transaction
  belongs_to :hazard, foreign_key: "owner_id",class_name:"Hazard"
end
