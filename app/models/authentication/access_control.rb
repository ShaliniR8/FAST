class AccessControl < ActiveRecord::Base


  has_many :assignments,  :foreign_key => "access_controls_id", :class_name => "Assignment", :dependent => :destroy

  has_many :privileges, :through => :assignments


  after_create :set_viewer_access
  after_create :update_rules_config
  after_destroy :update_rules_config
  validates :action, presence: true, allow_blank: false
  validates :entry, presence: true, allow_blank: false



  def set_special_access
    if self.entry == "audits" && self.action == "viewer"
      self.list_type = false
      self.save
    end
  end



  def set_viewer_access
    self.viewer_access = !(self.class.entry_options.values.include? self.entry)
    self.save
    self.set_special_access
  end



  def self.list_type_options
    {
      "Allow List" => true
    }
  end



  def self.generate_desc(type, action)
    case type
    when 'Checklist'
      case action
      when 'add'
        "This allows the user to add a #{type} to an Audit"
      when 'edit'
        "This allows the user to edit a #{type} that has been added to an Audit"
      when 'destroy'
        "This allows the user to delete a #{type} that has been added to an Audit"
      else
        ""
      end
    else
      case action
      when "new"
        "This gives the user access to create new #{type}s"
      when "show"
        if ["a", "e", "i", "o", "u"].include?(type[0].downcase)
          "This gives the user access to view details about an #{type}."
        else
          "This gives the user access to view details about a #{type}."
        end
      when "edit"
        "This gives the user access to see the \"Edit\" button on the #{type} page and to edit the #{type}."
      when "destroy"
        if type.downcase == "document"
          "This gives the user access to see the red \"X\" buttons on the #{type} page and to delete a #{type}."
        else
          "This gives the user access to see the \"Delete\" button on the #{type} page and to delete the #{type}."
        end
      when "index"
        "This gives the user access to see a listing of all the #{type}s in the #{type} table."
      when "viewer"
        "This gives the user access to see all viewer access enabled #{type}s."
      when "module"
        "This gives the user access to the #{type} Module from the gateway page."
      when 'admin'
        "This gives the user access to #{type}s that they are not associated with."
      when 'override'
        "This gives the user access to see the \"Override\" button on the #{type} page and the ability to delete the #{type}."
      when 'notify'
        if ["a", "e", "i", "o", "u"].include?(type[0].downcase)
          "Users with this access rule will be notified when an #{type} is created."
        else
          "Users with this access rule will be notified when a #{type} is created."
        end
      when 'library'
        "This gives the user access to see the ASAP Library"
      else
        ""
      end
    end
  end


  def self.module_map
    {
      "safety_reporting" => ["reports", "meetings", "records", "faa_reports", "submissions", "ASAP", "corrective_actions"],
      "smsim" => ["SMS IM", "ims", "packages", 'sms_meetings'],
      "safety_assurance" => ["audits", "Safety Assurance", "inspections", "investigations", "evaluations", "findings", "sms_actions", 'recommendations', 'checklist'],
      "srm" => ["sras", "safety_plans", 'hazards', 'risk_controls', 'srm_meetings', 'Safety Risk Management'],
      "safety_promotion" => ["Safety Promotion", "newsletters", "safety_surveys"],
      "other" => ["documents", "Role", "home"],
      "templates" => Template.find(:all).map(&:name),
      "checklist_templates" => Checklist.where(owner_type: 'ChecklistHeader').map(&:title),
    }
  end



  def self.get_descriptions
    {
      "submissions"=>{
        "new"                 => generate_desc("Submission", "new"),
        "show"                => generate_desc("Submission", "show"),
        "destroy"             => generate_desc("Submission", "destroy"),
        "index"               => generate_desc("Submission", "index"),
        "library"             => generate_desc("Submission", "library"),
        "admin"               => generate_desc("Submission", "admin"),
        "shared"              => "Only apply this to accounts that will be shared by multiple users. This will block the user from accessing any previous submissions.",
      },

      "records"=>{
        "summary"             => "This gives the user access to the \"View Narrative\" button on the Meeting page",
        "show"                => generate_desc("Report", "show"),
        "edit"                => generate_desc("Report", "edit"),
        "destroy"             => generate_desc("Report", "destroy"),
        "index"               => generate_desc("Report", "index"),
        "override"            => generate_desc("Report", "override"),
        "admin"               => generate_desc("Report", "admin"),
        "query"               => "This gives the user access to query from reports.",
        "deid"                => "This gives the user access to De-Identified reports",
      },

      "reports"=>{
        "new"                 => generate_desc("Event", "new"),
        "show"                => generate_desc("Event", "show"),
        "edit"                => generate_desc("Event", "edit"),
        "destroy"             => generate_desc("Event", "destroy"),
        "index"               => generate_desc("Event", "index"),
        "override"            => generate_desc("Event", "override"),
        "admin"               => generate_desc("Event", "admin"),
      },

      "meetings"=>{
        "new"                 => generate_desc("Safety Reporting Meeting", "new"),
        "show"                => generate_desc("Safety Reporting Meeting", "show"),
        "edit"                => generate_desc("Safety Reporting Meeting", "edit"),
        "destroy"             => generate_desc("Safety Reporting Meeting", "destroy"),
        "index"               => generate_desc("Safety Reporting Meeting", "index"),
        "override"            => generate_desc("Safety Reporting Meeting", "override"),
        "admin"               => generate_desc("Safety Reporting Meeting", "admin"),
      },

      "faa_reports"=>{
        "new"                 => generate_desc("FAA Report", "new"),
        "show"                => generate_desc("FAA Report", "show"),
        "edit"                => generate_desc("FAA Report", "edit"),
        "index"               => generate_desc("FAA Report", "index"),
        "destroy"             => generate_desc("FAA Report", "destroy"),
        "enhance"             => "This gives the user access to add and edit Safety Enhancements in the FAA Report.",
      },

      "corrective_actions"=>{
        "new"                 => generate_desc("Safety Reporting Corrective Action", "new"),
        "show"                => generate_desc("Safety Reporting Corrective Action", "show"),
        "edit"                => generate_desc("Safety Reporting Corrective Action", "edit"),
        "destroy"             => generate_desc("Safety Reporting Corrective Action", "destroy"),
        "index"               => generate_desc("Safety Reporting Corrective Action", "index"),
        "override"            => generate_desc("Safety Reporting Corrective Action", "override"),
        "notify"              => generate_desc("Safety Reporting Corrective Action", "notify"),
        "admin"               => generate_desc("Safety Reporting Corrective Action", "admin"),
      },

      "documents"=>{
        "new"                 => generate_desc("Document", "new"),
        "index"               => generate_desc("Document", "index"),
        "destroy"             => generate_desc("Document", "destroy"),
      },

      "audits"=>{
        "new"                 => generate_desc("Audit", "new"),
        "show"                => generate_desc("Audit", "show"),
        "edit"                => generate_desc("Audit", "edit"),
        "destroy"             => generate_desc("Audit", "destroy"),
        "index"               => generate_desc("Audit", "index"),
        "viewer"              => generate_desc("Audit", "viewer"),
        "override"            => generate_desc("Audit", "override"),
        "notify"              => generate_desc("Audit", "notify"),
        "admin"               => generate_desc("Audit", "admin"),
      },

      "inspections"=>{
        "new"                 => generate_desc("Inspection", "new"),
        "show"                => generate_desc("Inspection", "show"),
        "edit"                => generate_desc("Inspection", "edit"),
        "destroy"             => generate_desc("Inspection", "destroy"),
        "index"               => generate_desc("Inspection", "index"),
        "viewer"              => generate_desc("Inspection", "viewer"),
        "override"            => generate_desc("Inspection", "override"),
        "notify"              => generate_desc("Inspection", "notify"),
        "admin"               => generate_desc("Inspection", "admin"),
      },

      "evaluations"=>{
        "new"                 => generate_desc("Evaluation", "new"),
        "show"                => generate_desc("Evaluation", "show"),
        "edit"                => generate_desc("Evaluation", "edit"),
        "destroy"             => generate_desc("Evaluation", "destroy"),
        "index"               => generate_desc("Evaluation", "index"),
        "viewer"              => generate_desc("Evaluation", "viewer"),
        "override"            => generate_desc("Evaluation", "override"),
        "notify"              => generate_desc("Evaluation", "notify"),
        "admin"               => generate_desc("Evaluation", "admin"),
      },

      "investigations"=>{
        "new"                 => generate_desc("Investigation", "new"),
        "show"                => generate_desc("Investigation", "show"),
        "edit"                => generate_desc("Investigation", "edit"),
        "destroy"             => generate_desc("Investigation", "destroy"),
        "index"               => generate_desc("Investigation", "index"),
        "viewer"              => generate_desc("Investigation", "viewer"),
        "override"            => generate_desc("Investigation", "override"),
        "notify"              => generate_desc("Investigation", "notify"),
        "admin"               => generate_desc("Investigation", "admin"),
      },

      "findings"=>{
        "new"                 => generate_desc("Finding", "new"),
        "show"                => generate_desc("Finding", "show"),
        "edit"                => generate_desc("Finding", "edit"),
        "destroy"             => generate_desc("Finding", "destroy"),
        "index"               => generate_desc("Finding", "index"),
        "override"            => generate_desc("Finding", "override"),
        "notify"              => generate_desc("Finding", "notify"),
        "admin"               => generate_desc("Finding", "admin"),
      },

      "sms_actions"=>{
        "new"                 => generate_desc("Safety Assurance Corrective Action", "new"),
        "show"                => generate_desc("Safety Assurance Corrective Action", "show"),
        "edit"                => generate_desc("Safety Assurance Corrective Action", "edit"),
        "destroy"             => generate_desc("Safety Assurance Corrective Action", "destroy"),
        "index"               => generate_desc("Safety Assurance Corrective Action", "index"),
        "override"            => generate_desc("Safety Assurance Corrective Action", "override"),
        "notify"              => generate_desc("Safety Assurance Corrective Action", "notify"),
        "admin"               => generate_desc("Safety Assurance Corrective Action", "admin"),
      },

      "recommendations"=>{
        "new"                 => generate_desc("Recommendation", "new"),
        "show"                => generate_desc("Recommendation", "show"),
        "edit"                => generate_desc("Recommendation", "edit"),
        "destroy"             => generate_desc("Recommendation", "destroy"),
        "index"               => generate_desc("Recommendation", "index"),
        'admin'               => generate_desc('Recommendation', 'admin'),
        "override"            => generate_desc("Recommendation", "override"),
        "notify"              => generate_desc("Recommendation", "notify"),
        "admin"               => generate_desc("Recommendation", "admin"),
      },

      "checklist"=>{
        "add"                 => generate_desc("Checklist", "add"),
        "edit"                => generate_desc("Checklist", "edit"),
        "destroy"             => generate_desc("Checklist", "destroy"),
        "admin"               => "This gives the user access to all checklist templates to be added to Audits, Inspections, Evaluations and Investigations",
      },

      'sras'=>{
        "new"                 => generate_desc("SRA(SRM)", "new"),
        "show"                => generate_desc("SRA(SRM)", "show"),
        "edit"                => generate_desc("SRA(SRM)", "edit"),
        "destroy"             => generate_desc("SRA(SRM)", "destroy"),
        "index"               => generate_desc("SRA(SRM)", "index"),
        "viewer"              => generate_desc("SRA(SRM)", "viewer"),
        "override"            => generate_desc("SRA(SRM)", "override"),
        "notify"              => generate_desc("SRA(SRM)", "notify"),
        "admin"               => generate_desc("SRA(SRM)", "admin"),
      },

      'hazards'=>{
        "new"                 => generate_desc("Hazard", "new"),
        "show"                => generate_desc("Hazard", "show"),
        "edit"                => generate_desc("Hazard", "edit"),
        "destroy"             => generate_desc("Hazard", "destroy"),
        "index"               => generate_desc("Hazard", "index"),
        "override"            => generate_desc("Hazard", "override"),
        "notify"              => generate_desc("Hazard", "notify"),
        "admin"               => generate_desc("Hazard", "admin"),
      },

      'risk_controls'=>{
        "new"                 => generate_desc("Risk Control", "new"),
        "show"                => generate_desc("Risk Control", "show"),
        "edit"                => generate_desc("Risk Control", "edit"),
        "destroy"             => generate_desc("Risk Control", "destroy"),
        "index"               => generate_desc("Risk Control", "index"),
        "override"            => generate_desc("Risk Control", "override"),
        "notify"              => generate_desc("Risk Control", "notify"),
        "admin"               => generate_desc("Risk Control", "admin"),
      },

      'safety_plans'=>{
        "new"                 => generate_desc("Safety Plan", "new"),
        "show"                => generate_desc("Safety Plan", "show"),
        "edit"                => generate_desc("Safety Plan", "edit"),
        "destroy"             => generate_desc("Safety Plan", "destroy"),
        "index"               => generate_desc("Safety Plan", "index"),
        "override"            => generate_desc("Safety Plan", "override"),
        "notify"              => generate_desc("Safety Plan", "notify"),
        "admin"               => generate_desc("Safety Plan", "admin"),
      },

      'srm_meetings'=>{
        "new"                 => generate_desc("SRA(SRM) Meeting", "new"),
        "show"                => generate_desc("SRA(SRM) Meeting", "show"),
        "edit"                => generate_desc("SRA(SRM) Meeting", "edit"),
        "destroy"             => generate_desc("SRA(SRM) Meeting", "destroy"),
        "index"               => generate_desc("SRA(SRM) Meeting", "index"),
        "override"            => generate_desc("SRA(SRM) Meeting", "override"),
        "admin"               => generate_desc("SRA(SRM) Meeting", "admin"),
      },

      'ims'=>{
        "new"                 => generate_desc("IM", "new"),
        "show"                => generate_desc("IM", "show"),
        "edit"                => generate_desc("IM", "edit"),
        "destroy"             => generate_desc("IM", "destroy"),
        "index"               => generate_desc("IM", "index"),
        "viewer"              => generate_desc("IM", "viewer"),
        "override"            => generate_desc("IM", "override"),
        "admin"               => generate_desc("IM", "admin"),
       },

      'packages'=>{
        "new"                 => generate_desc("Package", "new"),
        "show"                => generate_desc("Package", "show"),
        "edit"                => generate_desc("Package", "edit"),
        "destroy"             => generate_desc("Package", "destroy"),
        "index"               => generate_desc("Package", "index"),
        "viewer"              => generate_desc("Package", "viewer"),
        "override"            => generate_desc("Package", "override"),
        "admin"               => generate_desc("Package", "admin"),
       },

      'sms_meetings'=>{
        "new"                 => generate_desc("SMS IM Meeting", "new"),
        "show"                => generate_desc("SMS IM Meeting", "show"),
        "edit"                => generate_desc("SMS IM Meeting", "edit"),
        "destroy"             => generate_desc("SMS IM Meeting", "destroy"),
        "index"               => generate_desc("SMS IM Meeting", "index"),
        "viewer"              => generate_desc("SMS IM Meeting", "viewer"),
        "override"            => generate_desc("SMS IM Meeting", "override"),
        "admin"               => generate_desc("SMS IM Meeting", "admin"),
       },

       'newsletters'=>{
        "new"                 => generate_desc("Newsletter", "new"),
        "show"                => generate_desc("Newsletter", "show"),
        "edit"                => generate_desc("Newsletter", "edit"),
        "destroy"             => generate_desc("Newsletter", "destroy"),
        "index"               => generate_desc("Newsletter", "index"),
        "override"            => generate_desc("Newsletter", "override"),
        "notify"              => generate_desc("Newsletter", "notify"),
       },

       'safety_surveys'=>{
        "new"                 => generate_desc("Safety Survey", "new"),
        "show"                => generate_desc("Safety Survey", "show"),
        "edit"                => generate_desc("Safety Survey", "edit"),
        "destroy"             => generate_desc("Safety Survey", "destroy"),
        "index"               => generate_desc("Safety Survey", "index"),
        "override"            => generate_desc("Safety Survey", "override"),
        "notify"              => generate_desc("Safety Survey", "notify"),
       },

       'safety_badges'=>{
        "new"                 => generate_desc("Safety Badge", "new"),
        "show"                => generate_desc("Safety Badge", "show"),
        "edit"                => generate_desc("Safety Badge", "edit"),
        "destroy"             => generate_desc("Safety Badge", "destroy"),
        "index"               => generate_desc("Safety Badge", "index"),
        "override"            => generate_desc("Safety Badge", "override"),
        "notify"              => generate_desc("Safety Badge", "notify"),
       },

       'ASAP' =>{
        'module'              => generate_desc("Safety Reporting", "module"),
       },

       'SMS IM'=>{
        'module'              => generate_desc("SMS IM", "module"),
       },

       'Safety Assurance'=>{
        'module'              => generate_desc("Safety Assurance", "module"),
       },

       'Safety Risk Management'=>{
        'module'              => generate_desc("SRA(SRM)", "module"),
       },

       'Safety Promotion'=>{
        'module'              => generate_desc("Safety Promotion", "module"),
       },

       'trackings'=>{
        "new"                 => generate_desc("Tracking", "new"),
        "index"               => generate_desc("Tracking", "index"),
       },

       'home'=>{
        'query_all'           =>'This gives the user access to the Query Center for Safety Reporting, Safety Assurance, and SRA(SRM) modules should they have access to them.'
       }
    }
  end

  def self.get_meta
    {
      "submissions"=>{
        "View"=>"show",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Shared"=>"shared",
        "ASAP Library"=>"library",
        "Full Access"=>"admin"
      },
      "records"=>{
        "View Narrative" => "summary",
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Query"=>"query",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      "reports"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      "trackings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Override" => 'override'
      },
      "meetings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      "faa_reports"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Listing"=>"index",
        "Delete"=>"destroy",
        "Safety Enhancement"=>"enhance"
      },
      "corrective_actions"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "documents"=>{
        "New"=>"new",
        "Listing"=>"index",
        "Delete"=>"destroy"
      },
      "audits"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "inspections"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "evaluations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "investigations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "findings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "sms_actions"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "recommendations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      "checklist"=>{
        "Add"=>"add",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        'Full Access'=>'admin'
      },
      'sras'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      'hazards'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Full Access"=>"admin",
        "Override" => 'override',
        "Notify" => 'notify'
      },
      'risk_controls'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Full Access'=>'admin',
        "Override" => 'override',
        "Notify" => 'notify'
      },
      'safety_plans'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Override" => 'override',
        "Notify" => 'notify'
      },
      'srm_meetings'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      'ims'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      'packages'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Full Access"=>"admin",
        "Override" => 'override'
      },
      'sms_meetings'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        "Full Access"=>"admin",
        "Override" => 'override'
       },
       'newsletters'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Admin"=>"admin",
        "Override" => 'override',
        "Notify" => 'notify'
       },
       'safety_surveys'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Admin"=>"admin",
        "Override" => 'override',
        "Notify" => 'notify'
       },
       'ASAP'=>{
        'Module Access'=>'module'
       },
       'SMS IM'=>{
        "Module Access"=>'module'
       },
       'Safety Assurance'=>{
        'Module Access'=>'module'
       },
       'Safety Risk Management'=>{
        'Module Access'=>'module'
       },
       'Safety Promotion'=>{
        'Module'=>'module'
       },
       'home' =>{
        'Access'=>'query_all',
       },
    }
  end

  def self.action_options
    h = Hash.new

    h["New"] = "new"
    h["View"] = "show"
    h["Edit"] = "edit"
    h["Add"] = "add"
    h["Delete"] = "destroy"
    h["De-Identified"] = "deid"
    h["Listing"] = "index"
    h["Query"] = "query"
    h["Viewable"] = "viewable"
    h["Attach"] = "address"
    h["All"] = "all"
    h["Viewer Access"] = "viewer"
    h["View De-Identified"] = "viewer_template_deid"
    h["View Identified"] = "viewer_template_id"
    h["Notifier"] = "notifier"
    h["View Narrative"] = "summary"
    h["Submitter"] = "submitter"
    h["Safety Enhancement"] = "enhance"
    h["Summary"] = "summary"
    h["Module Access"] = "module"
    h["Tabulation"] = "tabulation"
    h["Access"] = "query_all"
    h["Full Access"] = "admin"
    h["Shared"] = "shared"
    h["Override"] = "override"
    h["Notify"] = "notify"
    h["ASAP Library"] = "library"
    h["Confidential"] = "confidential" if CONFIG::GENERAL[:has_confidential_forms].present?

    return h
  end

  def self.entry_options
    {
      "Submissions"                           => "submissions",
      "Reports"                               => "records",
      "Event Reports"                         => "reports",
      "Trackings"                             => "trackings",
      "SR Meetings"                           => "meetings",
      "Corrective Actions(Safety Reporting)"  => "corrective_actions",
      "FAA Reports"                           => "faa_reports",
      "Documents"                             => "documents",
      "Audits"                                => "audits",
      "Inspections"                           => "inspections",
      "Evaluations"                           => "evaluations",
      "Investigations"                        => "investigations",
      "Findings"                              => "findings",
      "Corrective Actions(Safety Assurance)"  => "sms_actions",
      "Recommendations"                       => "recommendations",
      "Checklists"                            => "checklist",
      "SRAs"                                  => "sras",
      "Hazards"                               => "hazards",
      "Risk Controls"                         => "risk_controls",
      "Safety Plans"                          => "safety_plans",
      "SMS IM Meetings"                       => "sms_meetings",
      "IM Plans"                              => "ims",
      "IM Packages"                           => "packages",
      "SRA(SRM) Meetings"                     => "srm_meetings",
      "Newsletters"                           => "newsletters",
      "Safety Surveys"                        => "safety_surveys",
      "Safety Reporting"                      => "ASAP",
      "SMS IM"                                => "SMS IM",
      "Safety Assurance"                      => "Safety Assurance",
      "SRA(SRM)"                              => "Safety Risk Management",
      "Safety Promotion"                      => "Safety Promotion",
      "Query Center"                          => "home",
    }.sort.to_h
  end



  def self.object_types
    {
      "SR Meetings"                           => "meetings",
      "Corrective Actions(Safety Reporting)"  => "corrective_actions",
      "Audits"                                => "audits",
      "Inspections"                           => "inspections",
      "Evaluations"                           => "evaluations",
      "Investigations"                        => "investigations",
      "Findings"                              => "findings",
      "Corrective Actions(Safety Assurance)"  => "sms_actions",
      "Recommendations"                       => "recommendations",
      "SRA(SRM)"                              => "sras",
      "Hazards"                               => "hazards",
      "Risk Controls"                         => "risk_controls",
      "Verifications"                         => "verifications",
    }.sort.to_h
  end


  def self.get_template_opts
    h = Hash.new

    h["Notifier"] = "notifier"
    h["View De-Identified"] = "viewer_template_deid"
    h["Submitter"] = "submitter"
    h["View Identified"] = "viewer_template_id"
    h["Confidential"] = "confidential" if CONFIG::GENERAL[:has_confidential_forms].present?

    return h
  end


  def self.get_checklist_template_opts
    h = Hash.new

    h["Attach"] = "address"
    h["Viewable"] = "viewable"
    h["All"] = "all"

    return h
  end



  def get_type
    self.viewer_access ?  "Form Access" : (self.list_type ? "Allow List" : "Block List")
  end



  def find_entry
    if self.viewer_access
      self.entry
    else
      self.class.entry_options.key(self.entry)
    end
  end



  def find_action
    self.class.action_options.key(self.action)
  end



  def find_desc
    if self.class.get_descriptions[self.entry].present? && self.class.get_descriptions[self.entry][self.action].present?
      self.class.get_descriptions[self.entry][self.action]
    else
      if ["address", "viewable", "all"].include?(self.action)
        get_checklist_template_desc(self.entry, self.action)
      else
        get_template_desc(self.entry, self.action)
      end
    end
  end



  def get_template_desc(template_name, action)
    case action
    when "viewer_template_deid"
      "This gives the user access to view a de-identified version of #{template_name} Submissions/Reports when the viewer access is enabled. Please note that access to viewing Submissions/Report is also required."
    when "submitter"
      "This gives the user access to submit a new Submission for #{template_name}."
    when "notifier"
      "Users with this access rule will receive an email notification when a new #{template_name} Submission is submitted."
    when "viewer_template_id"
      "This gives the user access to view an identified version of #{template_name} Submissions/Reports and also allows the user to edit Reports of type #{template_name}. Please note that access to editing Reports is also required."
    when "confidential"
      "This gives the user access to view the #{template_name} that are confidential."
    else
      ""
    end
  end


  def get_checklist_template_desc(checklist_template_name, action)
    case action
    when "viewable"
      "This gives the user access to view a checklist of type #{checklist_template_name}."
    when "address"
      "This gives the user access to attach a checklist of type #{checklist_template_name} to an object such as Audit."
    when "all"
      "This gives the user complete access to #{checklist_template_name} and allows the user to view and address any checklist of this type."
    else
      ""
    end
  end

  def update_rules_config
    restricting_rules = Hash.new{ |h, k| h[k] = [] }
    AccessControl.all.each do |acs|
      restricting_rules[acs.entry] << acs.action
    end
    restricting_rules.update(restricting_rules) { |key, val| val.uniq }
    Rails.application.config.restricting_rules = restricting_rules
    Rails.logger.info "[INFO] Access Rules have been updated- restricting_rules application config updated"
  end

  def self.get_headers
    [
      {:field => "find_entry",    :title => "Object"},
      {:field => "find_action",   :title => "Access"},
    ]
  end
end
