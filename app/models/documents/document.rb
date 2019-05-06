class Document < ActiveRecord::Base

  include Attachmentable

  belongs_to :created_by,foreign_key:"users_id",class_name:"User"

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
