class InspectionItem < ChecklistItem
  belongs_to :inspection,foreign_key:"owner_id",class_name: "Inspection"
  after_create :find_created_by

  def find_created_by
  end

  def self.get_status
    [
      'New',
      'Open',
      'Completed'
    ]
  end

  def self.get_level_of_compliance
    [
      'Meets Requirements',
      'Unsat',
      'Other'
    ]
  end

end
