class ChecklistItem < ActiveRecord::Base
  belongs_to :submitter,foreign_key:"user_id",class_name:"User"
  has_many :packages,foreign_key: "owner_id",class_name: "Package"
  accepts_nested_attributes_for :packages
  def get_revision_date
    self.revision_date.present? ?   self.revision_date.strftime("%Y-%m-%d")  : ""
  end
end
