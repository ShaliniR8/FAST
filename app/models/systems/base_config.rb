class BaseConfig

  #########################
  # GLOBAL CONFIGURATIONS #
  #########################


  RISK_MATRIX = {
    :likelihood       => ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"],
    :severity         => (0..4).to_a.reverse,
    :risk_factor      => {"Green - Acceptable" => "lime", "Yellow - Acceptable with mitigation" => "yellow", "Orange - Unacceptable" => "orange"},
  }


  MODULES =
  {
    "ASAP" => {
      :display_name => "ASAP",
      :objects => {
        "Submission" => "Submission",
        "Record" => "Report",
        "Report" => "Event",
        "CorrectiveAction" => "Corrective Action",
      }},

    "SMS IM" => {
      :display_name => "SMS IM",
      :objects => {}},

    "SMS" => {
      :display_name => "Safety Assurance",
      :objects => {
        "Audit" => "Audit",
        "Inspection" => "Inspection",
        "Evaluation" => "Evaluation",
        "Investigation" => "Investigation",
        "Finding" => "Finding",
        "SmsAction" => "Corrective Action",
      }},

    "SRM" => {
      :display_name => "Safety Risk Management",
      :objects => {
        "Sra" => "SRA",
        "Hazard" => "Hazard",
        "RiskControl" => "Risk Control",
        "SafetyPlan" => "Safety Plan",
      }}
  }

  def self.get_sra_meta_fields
    airline_class = Object.const_get("#{BaseConfig.airline_code}_Config")
    if airline_class.respond_to? :get_sra_meta_fields
      airline_class.get_sra_meta_fields
    else
      [
        { field: "get_id",                    title: "ID",                                       num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
        { field: "status",                    title: "Status",                                   num_cols: 6,   type: "text",        visible: 'index,show',        required: false},
        { field: 'get_source',                title: 'Source of Input',                           num_cols: 6,   type: 'text',         visible: 'index,show',      required: false},
        {                                                                                                       type: "newline",     visible: 'form,show'},
        { field: "title",                     title: "SRA Title",                                num_cols: 6,   type: "text",        visible: 'index,form,show',   required: false},
        { field: "type_of_change",            title: "Type of Change",                           num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: Sra.get_custom_options('SRA Type of Change')},
        { field: "system_task",               title: "System/Task",                              num_cols: 6,   type: "datalist",    visible: 'index,form,show',   required: false, options: Sra.get_custom_options('Systems/Tasks')},
        { field: "responsible_user_id",       title: "Responsible User",                         num_cols: 6,   type: "user",        visible: 'index,form,show',  required: false},
        { field: "reviewer_id",               title: "Quality Reviewer",                         num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
        { field: "approver_id",               title: "Final Approver",                           num_cols: 6,   type: "user",        visible: 'form,show',         required: false},
        { field: "scheduled_completion_date", title: "Scheduled Completion Date",                num_cols: 6,   type: "date",        visible: 'index,form,show',   required: false},
        { field: "current_description",       title: "Describe the Current System",              num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
        { field: "plan_description",          title: "Describe Proposed Plan",                   num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
        {                                     title: "Affected Department",                      num_cols: 12,  type: "panel_start", visible: 'form,show'},
        { field: "departments",               title: "Affected Departments",                     num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Departments')},
        { field: "other_department",          title: "Other Affected Departments",               num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
        { field: "departments_comment",       title: "Affected Departments Comments",            num_cols: 12,  type: "textarea",    visible: 'form,show',        required: false},
        {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

        {                                     title: "Affected Programs",                        num_cols: 12,  type: "panel_start", visible: 'form,show'},
        { field: "programs",                  title: "Affected Programs",                        num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Programs')},
        { field: "other_program",             title: "Other Affected Programs",                  num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
        { field: "programs_comment",          title: "Affected Programs Comments",               num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
        {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

        {                                     title: "Affected Manuals",                         num_cols: 12,  type: "panel_start", visible: 'form,show'},
        { field: "manuals",                   title: "Affected Manuals",                         num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options('Manuals')},
        { field: "other_manual",              title: "Other Affected Manuals",                   num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
        { field: "manuals_comment",           title: "Affected Manuals Comments",                num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
        {                                                                                        num_cols: 12,  type: "panel_end",   visible: 'form,show'},

        {                                     title: "Affected Regulatory Compliances",           num_cols: 12,  type: "panel_start", visible: 'form,show',},
        { field: "compliances",               title: "Affected Regulatory Compliances",           num_cols: 12,  type: "checkbox",    visible: 'form,show',         required: false, options: Sra.get_custom_options("Regulatory Compliances")},
        { field: "other_compliance",          title: "Other Affected Regulatory Compliances",     num_cols: 6,   type: "text",        visible: 'form,show',         required: false},
        { field: "compliances_comment",       title: "Affected Regulatory Compliances Comments",  num_cols: 12,  type: "textarea",    visible: 'form,show',         required: false},
        {                                                                                       num_cols: 12,  type: "panel_end",   visible: 'form,show'},

        { field: "closing_comment",           title: "Responsible User's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
        { field: "reviewer_comment",          title: "Quality Reviewer's Closing Comments",      num_cols: 12,  type: "text",        visible: 'show'},
        { field: "approver_comment",          title: "Final Approver's Closing Comments",        num_cols: 12,  type: "text",        visible: 'show'},
      ]
    end
  end

  def self.airline_code
    Object.const_get('AIRLINE_CODE')
  end

  def self.airline
    Object.const_get(BaseConfig.airline_code + "_Config").airline_config
  end


  def self.faa_info
    Object.const_get(BaseConfig.airline[:code] + "_Config")::FAA_INFO
  end

  def self.observation_phases
    Object.const_get(BaseConfig.airline[:code] + "_Config")::OBSERVATION_PHASES rescue []
  end


  def self.getTimeFormat
    {
      :timepicker       => "H:i",
      :datepicker       => "Y-m-d",
      :datetimepicker   => "Y-m-d H:i",
      :dateformat       => "%Y-%m-%d",
      :datetimeformat   => "%Y-%m-%d %H:%M",
    }
  end


end
