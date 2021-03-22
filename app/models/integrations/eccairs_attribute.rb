class EccairsAttribute < ProsafetBase


  has_many :eccairs_mappings, foreign_key: :eccairs_attribute_id, class_name: 'EccairsMapping'
  has_many :fields, :through => :eccairs_mappings

  has_one :eccairs_unit, primary_key: :default_unit_id, foreign_key: :unit_id

end
