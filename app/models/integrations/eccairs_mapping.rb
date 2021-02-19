class EccairsMapping < ProsafetBase

  belongs_to :eccairs_attribute,  foreign_key: :eccairs_attribute_id, class_name: 'EccairsAttribute'
  belongs_to :field,              foreign_key: :field_id,             class_name: 'Field'

end
