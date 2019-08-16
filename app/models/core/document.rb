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
          {name: 'User Privileges',               href: 'standard_video', class: 'tv', content: ['privileges']},
          {name: 'Creating/Editing a Custom ORM', href: 'standard_video', class: 'tv', content: ['custom_orms']},
          #{name: 'Risk Matrix Customization',     href: 'risk_matrix',    class: ''},
        ]
      },
      {name: 'Safety Reporting', href: 'safety_reporting', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough',               href: 'standard_video',  class: 'tv',  content: ['sr_dashboard']},
          {name: 'Filing a Safety Report',              href: 'standard_video',  class: 'tv',  content: ['file_report'],},
          {name: 'Continuing an In-Progress Report',    href: 'standard_video',  class: 'tv',  content: ['continue_report'],},
          {name: 'Filing an ORM',                       href: 'standard_video',  class: 'tv',  content: ['file_orm'],},
          {name: 'Create a New Event',                  href: 'standard_video',  class: 'tv',  content: ['new_event'],},
          {name: 'Adding a Report to an Event',         href: 'standard_video',  class: 'tv',  content: ['add_to_event'],},
          {name: 'Corrective Actions',                  href: 'standard_video',  class: 'tv',  content: ['car_from_report', 'car_from_event', 'edit_car', 'car_advanced_search'],},
          {name: 'FAA Reports',                         href: 'standard_video',  class: 'tv',  content: ['new_faa_report', 'edit_faa_reports'],},
          {name: 'Meetings',                            href: 'standard_video',  class: 'tv',  content: ['new_meeting', 'process_meeting'],},
        ]
      },
      {name: 'Safety Assurance', href: 'safety_assurance', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video',  class: 'tv', content: ['sa_dashboard'],},
          {name: 'Audits',                href: 'standard_video',  class: 'tv', content: ['audit_new', 'audit_recurring', 'audit_edit'],},
          {name: 'Findings',              href: 'standard_video',  class: 'tv', content: ['finding_new'],},
          {name: 'Corrective Actions',    href: 'standard_video',  class: 'tv', content: ['car_new'],},
          {name: 'Evaluations',           href: 'standard_video',  class: 'tv', content: ['evaluation_new', 'evaluation_recurring'],},
          {name: 'Inspections',           href: 'standard_video',  class: 'tv', content: ['inspection_new', 'inspection_recurring'],},
          {name: 'Investigations',        href: 'standard_video',  class: 'tv', content: ['investigation_new'],},
          {name: 'Query Center',          href: 'standard_video',  class: 'tv', content: ['safety_assurance_query_center'],},
        ]
      },

      {name: 'Safety Risk Assessment (SRA/SRM)', href: 'sra', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough',       href: 'standard_video',   class: 'tv', content: ['sra_dashboard'],  },
          {name: 'SRAs',                        href: 'standard_video',   class: 'tv', content: ['sra_new', 'sra_edit'],},
          {name: 'Hazards',                     href: 'standard_video',   class: 'tv', content: ['hazard_new'],},
          {name: 'Root Cause Trend Analysis',   href: 'standard_video',   class: 'tv', content: ['root_cause_analysis'],},
          {name: 'Risk Controls',               href: 'standard_video',   class: 'tv', content: ['risk_control_new', 'risk_control_assign'],},
          {name: 'Safety Plans',                href: 'standard_video',   class: 'tv', content: ['safety_plan_new', 'safety_plan_evaluate'],},
          {name: 'Advanced Search',             href: 'standard_video',   class: 'tv', content: ['sra_advanced_search'],},
          {name: 'Query Center',                href: 'standard_video',   class: 'tv', content: ['sra_query_center'],},
        ]
      },

      {name: 'SMS-IM', href: 'sms_im', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video', class: 'tv', content: ['sms_dashboard']},
        ]
      },

    ]
  end

end
