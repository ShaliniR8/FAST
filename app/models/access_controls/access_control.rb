class AccessControl < ActiveRecord::Base


  has_many :assignments,  :foreign_key => "access_controls_id", :class_name => "Assignment", :dependent => :destroy

  has_many :privileges, :through => :assignments


  after_create :set_viewer_access
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
    case action
    when "new"
      "This gives the user access to create new #{type}s"
    when "show"
      #TR 8/21/18 Adds a grammar check
      firstChar = type[0]
      if firstChar.downcase == "a" ||
        firstChar.downcase == "e"  ||
        firstChar.downcase == "i"  ||
        firstChar.downcase == "o"  ||
        firstChar.downcase == "u"
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
      "This gives the user full access to viewing, editing, and creating #{type}s."
    else
      ""
    end
  end



  def self.module_map
    {
      "safety_reporting" => ["reports", "meetings", "records", "faa_reports", "submissions", "ASAP", "corrective_actions"],
      "smsim" => ["SMS IM", "ims", "packages"],
      "safety_assurance" => ["audits", "Safety Assurance", "inspections", "investigations", "evaluations", "findings", "sms_actions", 'recommendations'],
      "srm" => ["sras", "safety_plans", 'hazards', 'risk_controls'],
      "other" => ["documents", "Role", "home"],
      "templates" => Template.find(:all).map(&:name),
    }
  end



  def self.get_descriptions
    {
      "submissions"=>{
        "new"                 => generate_desc("Submission", "new"),
        "show"                => generate_desc("Submission", "show"),
        "destroy"             => generate_desc("Submission", "destroy"),
        "index"               => generate_desc("Submission", "index"),
      },

      "records"=>{
        "summary"             => "This gives the user access to the \"View Summary\" button on the Meeting page",
        "show"                => generate_desc("Report", "show"),
        "edit"                => generate_desc("Report", "edit"),
        "destroy"             => generate_desc("Report", "destroy"),
        "index"               => generate_desc("Report", "index"),
        "query"               => "This gives the user access to query from reports.",
        "deid"                => "This gives the user access to De-Identified reports",
      },

      "reports"=>{
        "new"                 => generate_desc("Event", "new"),
        "show"                => generate_desc("Event", "show"),
        "edit"                => generate_desc("Event", "edit"),
        "destroy"             => generate_desc("Event", "destroy"),
        "index"               => generate_desc("Event", "index"),
      },

      "meetings"=>{
        "new"                 => generate_desc("Safety Reporting Meeting", "new"),
        "show"                => generate_desc("Safety Reporting Meeting", "show"),
        "edit"                => generate_desc("Safety Reporting Meeting", "edit"),
        "destroy"             => generate_desc("Safety Reporting Meeting", "destroy"),
        "index"               => generate_desc("Safety Reporting Meeting", "index"),
      },

      "faa_reports"=>{
        "new"                 => generate_desc("FAA Report", "new"),
        "show"                => generate_desc("FAA Report", "show"),
        "edit"                => generate_desc("FAA Report", "edit"),
        "index"               => generate_desc("FAA Report", "index"),
        "enhance" => "This gives the user access to add and edit Safety Enhancements in the FAA Report.",
      },

      "corrective_actions"=>{
        "new"                 => generate_desc("Safety Reporting Corrective Action", "new"),
        "show"                => generate_desc("Safety Reporting Corrective Action", "show"),
        "edit"                => generate_desc("Safety Reporting Corrective Action", "edit"),
        "destroy"             => generate_desc("Safety Reporting Corrective Action", "destroy"),
        "index"               => generate_desc("Safety Reporting Corrective Action", "index"),
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
      },

      "inspections"=>{
        "new"                 => generate_desc("Inspection", "new"),
        "show"                => generate_desc("Inspection", "show"),
        "edit"                => generate_desc("Inspection", "edit"),
        "destroy"             => generate_desc("Inspection", "destroy"),
        "index"               => generate_desc("Inspection", "index"),
        "viewer"              => generate_desc("Inspection", "viewer"),
      },

      "evaluations"=>{
        "new"                 => generate_desc("Evaluation", "new"),
        "show"                => generate_desc("Evaluation", "show"),
        "edit"                => generate_desc("Evaluation", "edit"),
        "destroy"             => generate_desc("Evaluation", "destroy"),
        "index"               => generate_desc("Evaluation", "index"),
        "viewer"              => generate_desc("Evaluation", "viewer"),
      },

      "investigations"=>{
        "new"                 => generate_desc("Investigation", "new"),
        "show"                => generate_desc("Investigation", "show"),
        "edit"                => generate_desc("Investigation", "edit"),
        "destroy"             => generate_desc("Investigation", "destroy"),
        "index"               => generate_desc("Investigation", "index"),
        "viewer"              => generate_desc("Investigation", "viewer"),
      },

      "findings"=>{
        "new"                 => generate_desc("Finding", "new"),
        "show"                => generate_desc("Finding", "show"),
        "edit"                => generate_desc("Finding", "edit"),
        "destroy"             => generate_desc("Finding", "destroy"),
        "index"               => generate_desc("Finding", "index"),
        "viewer"              => generate_desc("Finding", "viewer"),
      },

      "sms_actions"=>{
        "new"                 => generate_desc("Safety Assurance Corrective Action", "new"),
        "show"                => generate_desc("Safety Assurance Corrective Action", "show"),
        "edit"                => generate_desc("Safety Assurance Corrective Action", "edit"),
        "destroy"             => generate_desc("Safety Assurance Corrective Action", "destroy"),
        "index"               => generate_desc("Safety Assurance Corrective Action", "index"),
        "viewer"              => generate_desc("Safety Assurance Corrective Action", "viewer"),
      },

      "recommendations"=>{
        "new"                 => generate_desc("Recommendation", "new"),
        "show"                => generate_desc("Recommendation", "show"),
        "edit"                => generate_desc("Recommendation", "edit"),
        "destroy"             => generate_desc("Recommendation", "destroy"),
        "index"               => generate_desc("Recommendation", "index"),
        "viewer"              => generate_desc("Recommendation", "viewer"),
        'admin'               => generate_desc('Recommendation', 'admin'),
      },

      'sras'=>{
        "new"                 => generate_desc("SRA", "new"),
        "show"                => generate_desc("SRA", "show"),
        "edit"                => generate_desc("SRA", "edit"),
        "destroy"             => generate_desc("SRA", "destroy"),
        "index"               => generate_desc("SRA", "index"),
        "viewer"              => generate_desc("SRA", "viewer"),
      },

      'hazards'=>{
        "new"                 => generate_desc("Hazard", "new"),
        "show"                => generate_desc("Hazard", "show"),
        "edit"                => generate_desc("Hazard", "edit"),
        "destroy"             => generate_desc("Hazard", "destroy"),
        "index"               => generate_desc("Hazard", "index"),
        "viewer"              => generate_desc("Hazard", "viewer"),
      },

      'risk_controls'=>{
        "new"                 => generate_desc("Risk Control", "new"),
        "new"                 => generate_desc("Risk Control", "new"),
        "show"                => generate_desc("Risk Control", "show"),
        "edit"                => generate_desc("Risk Control", "edit"),
        "destroy"             => generate_desc("Risk Control", "destroy"),
        "index"               => generate_desc("Risk Control", "index"),
        "viewer"              => generate_desc("Risk Control", "viewer"),
      },

      'safety_plans'=>{
        "new"                 => generate_desc("Safety Plan", "new"),
        "new"                 => generate_desc("Safety Plan", "new"),
        "show"                => generate_desc("Safety Plan", "show"),
        "edit"                => generate_desc("Safety Plan", "edit"),
        "destroy"             => generate_desc("Safety Plan", "destroy"),
        "index"               => generate_desc("Safety Plan", "index"),
        "viewer"              => generate_desc("Safety Plan", "viewer"),
      },

      'srm_meetings'=>{
        "new"                 => generate_desc("SRM Meeting", "new"),
        "new"                 => generate_desc("SRM Meeting", "new"),
        "show"                => generate_desc("SRM Meeting", "show"),
        "edit"                => generate_desc("SRM Meeting", "edit"),
        "destroy"             => generate_desc("SRM Meeting", "destroy"),
        "index"               => generate_desc("SRM Meeting", "index"),
        "viewer"              => generate_desc("SRM Meeting", "viewer"),
      },

      'ims'=>{
        "new"                 => generate_desc("IM", "new"),
        "show"                => generate_desc("IM", "show"),
        "edit"                => generate_desc("IM", "edit"),
        "destroy"             => generate_desc("IM", "destroy"),
        "index"               => generate_desc("IM", "index"),
        "viewer"              => generate_desc("IM", "viewer"),
       },

      'packages'=>{
        "new"                 => generate_desc("Package", "new"),
        "show"                => generate_desc("Package", "show"),
        "edit"                => generate_desc("Package", "edit"),
        "destroy"             => generate_desc("Package", "destroy"),
        "index"               => generate_desc("Package", "index"),
        "viewer"              => generate_desc("Package", "viewer"),
       },

      'sms_meetings'=>{
        "new"                 => generate_desc("SMS IM Meeting", "new"),
        "show"                => generate_desc("SMS IM Meeting", "show"),
        "edit"                => generate_desc("SMS IM Meeting", "edit"),
        "destroy"             => generate_desc("SMS IM Meeting", "destroy"),
        "index"               => generate_desc("SMS IM Meeting", "index"),
        "viewer"              => generate_desc("SMS IM Meeting", "viewer"),
       },

       'ASAP'=>{
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

       'trackings'=>{
        "new"                 => generate_desc("Tracking", "new"),
        "index"               => generate_desc("Tracking", "index"),
       },

       'home'=>{
        'query_all'           =>'This gives the user access to the Query Center for Safety Reporting, Safety Assurance, and SRA modules should they have access to them.'
       }
    }
  end

  def self.get_meta
    {
      "submissions"=>{
        "New"=>"new",
        "View"=>"show",
        "Delete"=>"destroy",
        "Listing"=>"index"
      },
      "records"=>{
        "View Summary" => "summary",
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Query"=>"query",
        "De-Identified" => "deid",
      },
      "reports"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index"
      },
      "trackings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index"
      },
      "meetings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index"
      },
      "faa_reports"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Listing"=>"index",
        "Safety Enhancement"=>"enhance"
      },
      "corrective_actions"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        'Admin'=>'admin'
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
        'Admin'=>'admin'
      },
      "inspections"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'

      },
      "evaluations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      "investigations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      "findings"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin',
      },
      "sms_actions"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      "recommendations"=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      'sras'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      'hazards'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"
      },
      'risk_controls'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer",
        'Admin'=>'admin'
      },
      'safety_plans'=>{

        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"
      },
      'srm_meetings'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"
      },
      'ims'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"},
      'packages'=>{
        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"},
      'sms_meetings'=>{

        "New"=>"new",
        "View"=>"show",
        "Edit"=>"edit",
        "Delete"=>"destroy",
        "Listing"=>"index",
        "Viewer"=>"viewer"
       },
       'ASAP'=>{
        'Module'=>'module'
       },
       'SMS IM'=>{
        "Module"=>'module'
       },
       'Safety Assurance'=>{
        'Module'=>'module'
       },
       'Safety Risk Management'=>{
        'Module'=>'module'
       },
       'home' =>{
        'Access'=>'query_all',
       },
    }
  end

  def self.action_options
    {
      'New'                 => 'new',
      'View'                => 'show',
      'Edit'                => 'edit',
      'Delete'              => 'destroy',
      'De-Identified'       => 'deid',
      'Listing'             => 'index',
      'Query'               => 'query',
      'Viewer'              => 'viewer',
      'Full'                => 'full',
      'Notifier'            => 'notifier',
      'View Summary'        => 'summary',
      'Submitter'           => 'submitter',
      'Safety Enhancement'  => 'enhance',
      'Summary'             => 'summary',
      'Tabulation'          => 'tabulation',
      'Access'              => 'query_all',
      'Admin'               => 'admin',
    }
  end

  def self.entry_options
    {
      "Submissions"                           => "submissions",
      "Reports"                               => "records",
      "Event Reports"                         => "reports",
      "Trackings"                             => "trackings",
      "Meetings"                              => "meetings",
      "Corrective Actions(ASAP)"              => "corrective_actions",
      "FAA Reports"                           => "faa_reports",
      "Documents"                             => "documents",
      "Audits"                                => "audits",
      "Inspections"                           => "inspections",
      "Evaluations"                           => "evaluations",
      "Investigations"                        => "investigations",
      "Findings"                              => "findings",
      "Corrective Actions(Safety Assurance)"  => "sms_actions",
      "Recommendations"                       => "recommendations",
      "SRAs"                                  => "sras",
      "Hazards"                               => "hazards",
      "Risk Controls"                         => "risk_controls",
      "Safety Plans"                          => "safety_plans",
      "SMS IM Meetings"                       => "sms_meetings",
      "IM Plans"                              => "ims",
      "IM Packages"                           => "packages",
      "SRM Meetings"                          => "srm_meetings",
      "ASAP"                                  => "ASAP",
      "SMS IM"                                => "SMS IM",
      "Safety Assurance"                      => "Safety Assurance",
      "Safety Risk Management"                => "Safety Risk Management",
      "Query Center"                          => "home",
    }.sort.to_h
  end



  def self.object_types
    {
      "Meetings"                              => "meetings",
      "Corrective Actions(ASAP)"              => "corrective_actions",
      "Audits"                                => "audits",
      "Inspections"                           => "inspections",
      "Evaluations"                           => "evaluations",
      "Investigations"                        => "investigations",
      "Findings"                              => "findings",
      "Corrective Actions(Safety Assurance)"  => "sms_actions",
      "Recommendations"                       => "recommendations",
      "SRAs"                                  => "sras",
      "Hazards"                               => "hazards",
      "Risk Controls"                         => "risk_controls",
      "Safety Plans"                          => "safety_plans",
    }.sort.to_h
  end


  def self.get_template_opts
    {
      "Notifier"=>"notifier",
      "Viewer"=>"viewer",
      "Submitter"=>"submitter",
      "Full"=>"full"
    }
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
      get_template_desc(self.entry, self.action)
    end
  end



  def get_template_desc(template_name, action)
    case action
    when "viewer"
      "This gives the user access to view #{template_name} Submissions/Reports when the viewer access is enabled. Please note that access to viewing Submissions/Report is also required."
    when "submitter"
      "This gives the user access to submit a new #{template_name}. Please note that access to creating new Submissions/Reports is also required."
    when "notifier"
      "Users with this access rule will receive an email notification when a new #{template_name} Submission is submitted."
    when "full"
      "This gives the user full access to #{template_name} and allows the user to create or edit Submissions/Reports. Please note that access to creating/editing Submissions/Reports is also required."
    else
      ""
    end
  end



  def self.get_headers
    [
      {:field => "find_entry",    :title => "Report Type"},
      {:field => "find_action",   :title => "Action"},
    ]
  end
end
