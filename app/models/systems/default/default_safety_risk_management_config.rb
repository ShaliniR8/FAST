class DefaultSafetyRiskManagementConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:

    # Airline-Specific Features:
  }

  def self.get_sra_meta_fields
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

  HIERARCHY = {
    display_name: 'Safety Risk Management',
    objects: {
      'Sra' => 'SRA',
      'Hazard' => 'Hazard',
      'RiskControl' => 'Risk Control',
      'SafetyPlan' => 'Safety Plan'
    }
  }

end
