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




  def self.get_user_guides
    [
      {name: 'Administrative', href: 'administrative', class: 'doc',
        topics: [
          {name: 'User Privileges',               href: 'privileges',   class: 'tv'},
          {name: 'Creating/Editing a Custom ORM', href: 'custom_orms',  class: 'tv'},
          {name: 'Risk Matrix Customization',     href: 'risk_matrix',  class: ''},
        ]
      },
      {name: 'Safety Reporting', href: 'safety_reporting', class: 'doc',
        topics: [
          {name: 'Dashboard Walkthrough',             href: 'sr_dashboard',     class: ''},
          {name: 'Filing a Safety Report',            href: 'file_report',      class: 'tv'},
          {name: 'Continuing an In-Progress Report',  href: 'continue_report',  class: 'tv'},
          {name: 'Filing an ORM',                     href: 'file_orm',         class: 'tv'},
        ]
      },
      {name: 'Safety Assurance', href: 'safety_assurance', class: 'doc',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'sa_dashboard', class: ''},
          {name: 'Create a New Audit',    href: 'audit',        class: 'tv'},
        ]
      },

      {name: 'Safety Risk Assessment (SRA/SRM)', href: 'sra', class: 'doc',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'srm_dashboard',  class: 'tv'},
          {name: 'Create an SRA/M',       href: 'srm',            class: 'tv'},
        ]
      },

      {name: 'SMS-IM', href: 'sms_im', class: 'doc',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'sms_dashboard', class: 'tv'},
        ]
      },

    ]
  end

end
