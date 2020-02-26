class SraSection < Section

  belongs_to :owner,    :foreign_key => "owner_id", :class_name => "Sra"

end
