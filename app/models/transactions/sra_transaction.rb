class SraTransaction < Transaction
  belongs_to :sra, foreign_key: "owner_id",class_name:"Sra"
end
