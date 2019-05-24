class Document < ActiveRecord::Base

  has_one :attachment, as: :owner, dependent: :destroy

  belongs_to :created_by,foreign_key:"users_id",class_name:"User"

  accepts_nested_attributes_for :attachment, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}


  def self.get_categories
    [
     "ProSafeT Information",
     "General Information",
     "Safety Reporting Guides Information",
     "Safety Assurance Guides Information",
     "SRA(SRM) Guides Information",
     "SMS IM Guides Information",
     "Other"
    ]
  end

  def self.get_tracking_identifiers
    [
      'Android'
    ]
  end

end
