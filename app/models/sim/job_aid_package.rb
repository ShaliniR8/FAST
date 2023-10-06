class JobAidPackage < Package
  belongs_to :item,foreign_key:"owner_id",class_name:"ChecklistRow"
  def self.display_name
    'Job Aid Package'
  end

  def self.meeting_type
    'JobMeeting'
  end
end
