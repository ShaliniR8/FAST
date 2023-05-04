class Document < ActiveRecord::Base

  has_one :attachment, as: :owner, dependent: :destroy

  belongs_to :created_by,foreign_key:"users_id",class_name:"User"

  accepts_nested_attributes_for :attachment, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}


  def self.get_categories
    CONFIG::DOCUMENT_CATEGORIES
  end

  def self.get_tracking_identifiers
    [
      'Android'
    ]
  end




  def self.get_user_guides
    [
      {name: 'Introduction to ProSafeT', href: '', class: 'doc title',
        topics: [
          {name: 'Portal Access Guide',               href: 'standard_video', class: 'tv', content: ['portal_access_guide']},
        ]
      },
      {name: 'Administrative', href: 'administrative', class: 'doc title',
        topics: [
          {name: 'User Privileges',               href: 'standard_video', class: 'tv', content: ['user_privileges']},
          {name: 'Create and Edit a Safety Report Template', href: 'standard_video', class: 'tv', content: ['create_edit_safety_report_template']},
          {name: 'Add Privileges to Safety Report Templates', href: 'standard_video', class: 'tv', content: ['add_privileges_to_safety_report_templates']},
          {name: 'Add Target Privileges to User Assignments', href: 'standard_video', class: 'tv', content: ['add_target_privileges_user_assignments']},
          {name: 'Create and Edit an ORM Template', href: 'standard_video', class: 'tv', content: ['create_edit_orm_template']},
          {name: 'Create Category/Root Cause Templates', href: 'standard_video', class: 'tv', content: ['create_category_root_cause_templates']},
          {name: 'Manage Custom Options', href: 'standard_video', class: 'tv', content: ['manage_custom_options']},
          {name: 'Create Message Templates', href: 'standard_video', class: 'tv', content: ['create_message_templates']},
          {name: 'Create Distribution Lists', href: 'standard_video', class: 'tv', content: ['create_distribution_lists']},
          {name: 'Create Checklist Headers', href: 'standard_video', class: 'tv', content: ['create_checklist_headers']},
          {name: 'Create Checklist Templates', href: 'standard_video', class: 'tv', content: ['create_checklist_templates']},
          {name: 'Create Automated Notifications', href: 'standard_video', class: 'tv', content: ['create_automated_notifications']},
        ]
      },
      {name: 'Safety Reporting', href: 'safety_reporting', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough',               href: 'standard_video',  class: 'tv',  content: ['sr_dashboard_walkthrough']},
          {name: 'Filing a Safety Report',              href: 'standard_video',  class: 'tv',  content: ['filing_a_safety_report'],},
          {name: 'Continuing an In-Progress Report',    href: 'standard_video',  class: 'tv',  content: ['continuing_an_in_progress_report'],},
          {name: 'Filing an ORM',                       href: 'standard_video',  class: 'tv',  content: ['filing_an_orm'],},
          {name: 'Create a New Event',                  href: 'standard_video',  class: 'tv',  content: ['create_a_new_event'],},
          {name: 'Adding a Report to an Event',         href: 'standard_video',  class: 'tv',  content: ['adding_a_report_to_an_event'],},
          {name: 'Create a New Corrective Action',                  href: 'standard_video',  class: 'tv',  content: ['sr_create_a_new_corrective_action'],},
          {name: 'Create a New FAA Report',                         href: 'standard_video',  class: 'tv',  content: ['create_a_new_faa_report'],},
          {name: 'Create a New Meeting',                            href: 'standard_video',  class: 'tv',  content: ['sr_create_a_new_meeting'],},
          {name: 'Advanced Search',               href: 'standard_video',  class: 'tv',  content: ['sr_advanced_search']}, 
          {name: 'Query Center',                        href: 'standard_video',  class: 'tv',  content: ['sr_query_center'],},
        ]
      },
      {name: 'Safety Assurance', href: 'safety_assurance', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video',  class: 'tv', content: ['sa_dashboard_walkthrough'],},
          {name: 'Create a New Audit',                href: 'standard_video',  class: 'tv', content: ['create_a_new_audit'],},
          {name: 'Create a Recurring Audit',                href: 'standard_video',  class: 'tv', content: ['create_a_recurring_audit'],},
          {name: 'Create an Audit from a Checklist',                href: 'standard_video',  class: 'tv', content: ['create_an_audit_from_a_checklist'],},
          {name: 'Add a Finding',              href: 'standard_video',  class: 'tv', content: ['add_a_finding'],},
          {name: 'Create a New Corrective Action',    href: 'standard_video',  class: 'tv', content: ['create_a_new_corrective_action'],},
          {name: 'Create a New Evaluation',           href: 'standard_video',  class: 'tv', content: ['create_a_new_evaluation'],},
          {name: 'Create a Recurring Evaluation',           href: 'standard_video',  class: 'tv', content: ['create_a_recurring_evaluation'],},
          {name: 'Create a New Inspection',           href: 'standard_video',  class: 'tv', content: ['create_a_new_inspection'],},
          {name: 'Create a Recurring Inspection',           href: 'standard_video',  class: 'tv', content: ['create_a_recurring_inspection'],},
          {name: 'Create a New Investigation',           href: 'standard_video',  class: 'tv', content: ['create_a_new_investigation'],},
          {name: 'Create a New Recommendation',           href: 'standard_video',  class: 'tv', content: ['create_a_new_recommendation'],},
          {name: 'Advanced Search',               href: 'standard_video',  class: 'tv',  content: ['sa_advanced_search']}, 
          {name: 'Query Center',          href: 'standard_video',  class: 'tv', content: ['sa_query_center'],},
        ]
      },

      {name: 'Safety Risk Assessment (SRA/SRM)', href: 'sra', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough',       href: 'standard_video',   class: 'tv', content: ['sra_dashboard_walkthrough'],  },
          {name: 'Create a New SRA',                        href: 'standard_video',   class: 'tv', content: ['create_a_new_sra'],},
          {name: 'Create a New Hazard',                     href: 'standard_video',   class: 'tv', content: ['create_a_new_hazard'],},
          {name: 'Create a New Risk Control',               href: 'standard_video',   class: 'tv', content: ['create_a_new_risk_control'],},
          {name: 'Risk Register',                href: 'standard_video',   class: 'tv', content: ['risk_register'],},
          {name: 'Create a New Safety Plan',                href: 'standard_video',   class: 'tv', content: ['create_a_new_safety_plan'],},
          {name: 'Create a New Meeting',                            href: 'standard_video',  class: 'tv',  content: ['sra_create_a_new_meeting'],},
          {name: 'Advanced Search',             href: 'standard_video',   class: 'tv', content: ['sra_advanced_search'],},
          {name: 'Query Center',                href: 'standard_video',   class: 'tv', content: ['sra_query_center'],},
        ]
      },

      {name: 'Safety Promotion', href: '', class: 'doc title',
        topics: [
          {name: 'Dashboard Walkthrough', href: 'standard_video', class: 'tv', content: ['sp_dashboard_walkthrough']},
          {name: 'Create and Publish a Newsletter', href: 'standard_video', class: 'tv', content: ['create_and_publish_a_newsletter']},
          {name: 'Acknowledge a Newsletter', href: 'standard_video', class: 'tv', content: ['acknowledge_a_newsletter']},
          {name: 'Create and Publish a Safety Survey', href: 'standard_video', class: 'tv', content: ['create_and_publish_a_safety_survey']},
          {name: 'Complete a Safety Survey', href: 'standard_video', class: 'tv', content: ['complete_a_safety_survey']},
        ]
      },

    ]
  end

end
