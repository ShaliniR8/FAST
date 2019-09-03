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
      {name: 'Administrative', href: 'administrative', class: 'doc title',
        topics: [
          {name: 'User Privileges',               href: 'standard_video', content: 'privileges',     class: 'tv'},
          {name: 'Creating/Editing a Custom ORM', href: 'standard_video', content: 'custom_orms',    class: 'tv'},
          {name: 'Risk Matrix Customization',     href: 'risk_matrix',    class: ''},
          {name: 'Query Center',                  href: 'query_center',   class: 'doc'},
        ]
      },
      {name: 'Safety Reporting', href: 'safety_reporting', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough',                         href: 'sr_dashboard',         class: ''},
          {name: 'Filing a Safety Report',                        href: 'standard_video',       content: 'file_report',          class: 'tv'},
          {name: 'Continuing an In-Progress Report',              href: 'standard_video',       content: 'continue_report',      class: 'tv'},

          {name: 'Create a New Event',                            href: 'standard_video',       content: 'new_event',            class: 'tv'},
          {name: 'Add Reports to Existing Event',                 href: 'standard_video',       content: 'add_to_event',         class: 'tv'},
          {name: 'Create a New Meeting',                          href: 'standard_video',       content: 'new_meeting',          class: 'tv'},
          {name: 'Process a Meeting',                             href: 'standard_video',       content: 'process_meeting',      class: 'tv'},
          {name: 'Start a Corrective Action from Report',         href: 'standard_video',       content: 'car_from_report',      class: 'tv'},
          {name: 'Start a Corrective Action from Event',          href: 'standard_video',       content: 'car_from_event',       class: 'tv'},
          {name: 'Edit a Corrective Action',                      href: 'standard_video',       content: 'edit_car',             class: 'tv'},
          {name: 'Corretive Action - Advanced Search',            href: 'standard_video',       content: 'car_advanced_search',  class: 'tv'},
          {name: 'Create an FAA Report',                          href: 'standard_video',       content: 'new_faa_report',       class: 'tv'},
          {name: 'Edit an FAA Report',                            href: 'standard_video',       content: 'edit_faa_reports',     class: 'tv'},
          {name: 'Filing an ORM',                                 href: 'standard_video',       content: 'file_orm',             class: 'tv'},
        ]
      },
      {name: 'Safety Assurance', href: 'safety_assurance', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'sa_dashboard', class: ''},
          {name: 'Create a New Audit',    href: 'standard_video', content: 'audit',        class: 'tv'},
        ]
      },

      {name: 'Safety Risk Assessment (SRA/SRM)', href: 'sra', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video', content: 'srm_dashboard',  class: 'tv'},
          {name: 'Create an SRA/M',       href: 'standard_video', content: 'srm',            class: 'tv'},
        ]
      },

      {name: 'SMS-IM', href: 'sms_im', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video', content: 'sms_dashboard', class: 'tv'},
        ]
      },

    ]
  end

end
