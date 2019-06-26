# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20190627153741) do

  create_table "access_controls", :force => true do |t|
    t.boolean "list_type"
    t.string  "action"
    t.string  "entry"
    t.boolean "viewer_access"
  end

  create_table "access_levels", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "report_type"
    t.integer  "level",       :default => 0
    t.integer  "user_id"
  end

  create_table "activity_trackers", :force => true do |t|
    t.integer  "user_id"
    t.datetime "last_active"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "agendas", :force => true do |t|
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "event_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "status"
    t.boolean  "discussion"
    t.boolean  "accepted"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "obj_id"
    t.integer  "user_poc_id"
  end

  create_table "airports", :force => true do |t|
    t.string "arpt_ident"
    t.string "name"
    t.string "state_prov"
    t.string "icao"
    t.string "faa_host_id"
    t.string "loc_hdatum"
    t.string "wgs_datum"
    t.string "wgs_lat"
    t.string "wgs_dlat"
    t.string "wgs_long"
    t.string "wgs_dlong"
    t.string "elev"
    t.string "arpt_type"
    t.string "mag_var"
    t.string "wac"
    t.string "beacon"
    t.string "second_arpt"
    t.string "opr_agy"
    t.string "sec_name"
    t.string "sec_icao"
    t.string "sec_faa"
    t.string "sec_opr_agy"
    t.string "cycle_date"
    t.string "_id"
  end

  create_table "assignments", :force => true do |t|
    t.integer  "access_controls_id"
    t.integer  "privileges_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachments", :force => true do |t|
    t.string  "owner_type"
    t.string  "name"
    t.string  "caption"
    t.integer "owner_id"
    t.integer "obj_id"
    t.integer "attachment_id"
  end

  create_table "audits", :force => true do |t|
    t.string   "title"
    t.string   "department"
    t.integer  "responsible_user_id"
    t.date     "completion"
    t.string   "audit_type"
    t.string   "location"
    t.string   "station_code"
    t.string   "vendor"
    t.string   "audit_department"
    t.string   "process"
    t.boolean  "planned"
    t.string   "supplier"
    t.text     "objective"
    t.text     "reference"
    t.text     "instruction"
    t.integer  "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "auditor_1_id"
    t.integer  "auditor_2_id"
    t.integer  "auditor_3_id"
    t.integer  "auditor_4_id"
    t.integer  "auditor_5_id"
    t.string   "status",              :default => "New"
    t.boolean  "viewer_access",       :default => false
    t.text     "comment"
    t.date     "schedule_date"
    t.date     "open_date"
    t.date     "complete_date"
    t.text     "viewer_note"
    t.integer  "custom_id"
    t.integer  "obj_id"
    t.text     "auditor_comment"
    t.integer  "auditor_poc_id"
    t.integer  "approver_poc_id"
    t.text     "privileges"
    t.text     "final_comment"
    t.integer  "created_by_id"
    t.boolean  "template"
    t.integer  "recurrence_id"
  end

  create_table "automated_notifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "created_by"
    t.string   "object_type"
    t.string   "anchor_date_field"
    t.string   "audience_field"
    t.string   "anchor_status"
    t.integer  "interval"
    t.string   "subject"
    t.text     "content"
  end

  create_table "canned_messages", :force => true do |t|
    t.string   "name"
    t.text     "content"
    t.integer  "user_id"
    t.string   "module"
    t.string   "report_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "templates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "panel"
    t.boolean  "print"
    t.integer  "category_order"
    t.boolean  "deleted",        :default => false
  end

  create_table "cause_options", :force => true do |t|
    t.string  "name",                      :null => false
    t.integer "level"
    t.boolean "hidden", :default => false
  end

  create_table "cause_options_connections", :id => false, :force => true do |t|
    t.integer "cause_option_1_id", :null => false
    t.integer "cause_option_2_id", :null => false
  end

  create_table "causes", :force => true do |t|
    t.string   "category"
    t.text     "value"
    t.integer  "owner_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attr"
    t.integer  "obj_id"
  end

  create_table "checklist_cells", :force => true do |t|
    t.integer  "checklist_row_id"
    t.integer  "checklist_header_item_id"
    t.text     "value"
<<<<<<< HEAD
    t.text     "options"
=======
>>>>>>> 561259f... Adds configurable risk matrices and JUS configurations
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "options"
  end

  create_table "checklist_header_items", :force => true do |t|
    t.integer  "display_order"
    t.integer  "checklist_header_id"
    t.string   "title"
    t.string   "data_type"
    t.text     "options"
    t.boolean  "editable",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "size"
  end

  create_table "checklist_headers", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.string   "status"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_items", :force => true do |t|
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "sort_id"
    t.string   "title"
    t.string   "revision_level"
    t.date     "revision_date"
    t.string   "department"
    t.text     "requirement"
    t.string   "reference_number"
    t.text     "reference"
    t.text     "instructions"
    t.string   "created_by"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",              :default => "New"
    t.string   "level_of_compliance"
    t.text     "comment"
    t.integer  "custom_id"
    t.integer  "obj_id"
    t.integer  "owner_obj_id"
  end

  create_table "checklist_questions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "number"
    t.string   "question"
    t.string   "faa_reference"
    t.string   "airline_reference"
    t.boolean  "header",            :default => false
    t.boolean  "archive",           :default => false
  end

  create_table "checklist_records", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "owner_id"
    t.string   "number"
    t.string   "question"
    t.string   "assessment"
    t.string   "faa_reference"
    t.string   "airline_reference"
    t.text     "notes"
    t.boolean  "header",            :default => false
  end

  create_table "checklist_rows", :force => true do |t|
    t.integer  "checklist_id"
    t.integer  "created_by_id"
    t.boolean  "is_header",     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checklist_templates", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.boolean  "archive",    :default => false
    t.text     "notes"
    t.integer  "created_by"
  end

  create_table "checklists", :force => true do |t|
    t.string   "title"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.integer  "created_by_id"
    t.integer  "checklist_header_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_applications", :id => false, :force => true do |t|
    t.integer  "id",                         :default => 0, :null => false
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 40
    t.string   "secret",       :limit => 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.integer  "owner_id"
    t.string   "location"
    t.string   "reference_number"
    t.string   "contact_name"
    t.string   "email"
    t.string   "work_phone"
    t.string   "mobile_phone"
    t.string   "add_1"
    t.string   "add_2"
    t.string   "city"
    t.string   "state"
    t.integer  "zip"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type"
    t.integer  "obj_id"
  end

  create_table "corrective_actions", :force => true do |t|
    t.integer  "reports_id"
    t.integer  "records_id"
    t.string   "status"
    t.boolean  "recommendation"
    t.date     "opened_date"
    t.date     "assigned_date"
    t.date     "decision_date"
    t.date     "due_date"
    t.date     "revised_due_date"
    t.boolean  "company"
    t.boolean  "employee"
    t.string   "department"
    t.integer  "responsible_user_id"
    t.boolean  "bimmediate_action"
    t.text     "immediate_action"
    t.boolean  "bcomprehensive_action"
    t.text     "comprehensive_action"
    t.string   "action"
    t.text     "description"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "designee"
    t.integer  "custom_id"
    t.integer  "user_poc_id"
    t.integer  "obj_id"
    t.date     "close_date"
    t.text     "privileges"
    t.integer  "approver_id"
    t.text     "final_comment"
    t.integer  "created_by_id"
  end

  create_table "costs", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.text     "description"
    t.date     "cost_date"
    t.boolean  "direct_cost"
    t.boolean  "indirect_cost"
    t.string   "work_order"
    t.string   "vendor"
    t.string   "amount"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "custom_options", :force => true do |t|
    t.string   "title"
    t.string   "field_type"
    t.text     "options"
    t.integer  "display_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "description"
  end

  create_table "documents", :force => true do |t|
    t.string   "category"
    t.string   "link"
    t.string   "title"
    t.integer  "users_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.string   "tracking_identifier"
  end

  create_table "evaluations", :force => true do |t|
    t.string   "title"
    t.string   "department"
    t.integer  "responsible_user_id"
    t.date     "completion"
    t.string   "evaluation_type"
    t.string   "location"
    t.string   "station_code"
    t.string   "vendor"
    t.string   "evaluation_department"
    t.string   "process"
    t.boolean  "planned"
    t.string   "supplier"
    t.text     "objective"
    t.text     "reference"
    t.text     "instruction"
    t.integer  "approver_id"
    t.string   "status",                :default => "New"
    t.boolean  "viewer_access",         :default => false
    t.date     "open_date"
    t.date     "complete_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "custom_id"
    t.integer  "approver_poc_id"
    t.integer  "evaluator_poc_id"
    t.text     "privileges"
    t.text     "evaluator_comment"
    t.text     "final_comment"
    t.integer  "created_by_id"
    t.boolean  "template"
    t.integer  "recurrence_id"
  end

  create_table "expectations", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "revision_level"
    t.date     "revision_date"
    t.string   "department"
    t.string   "reference_number"
    t.text     "reference"
    t.text     "expectation"
    t.text     "instruction"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "analyst_id"
    t.string   "type"
  end

  create_table "extension_requests", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "requester_id"
    t.date     "request_date"
    t.integer  "approver_id"
    t.string   "detail"
    t.string   "status"
    t.date     "address_date"
    t.string   "address_comment"
  end

  create_table "faa_reports", :force => true do |t|
    t.integer  "year"
    t.integer  "quarter"
    t.string   "faa"
    t.string   "company"
    t.string   "labor"
    t.string   "asap"
    t.integer  "asap_submit"
    t.integer  "asap_accept"
    t.integer  "sole"
    t.integer  "asap_close"
    t.integer  "asap_emp"
    t.integer  "asap_com"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "employee_group"
  end

  create_table "fields", :force => true do |t|
    t.string   "data_type"
    t.string   "display_type"
    t.text     "label"
    t.text     "options"
    t.integer  "display_size"
    t.integer  "priority"
    t.integer  "categories_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_label"
    t.boolean  "print"
    t.integer  "convert_id"
    t.integer  "map_id"
    t.string   "element_id",         :default => ""
    t.string   "element_class",      :default => ""
    t.integer  "field_order"
    t.boolean  "required",           :default => false
    t.boolean  "deleted",            :default => false
    t.integer  "nested_field_id"
    t.string   "nested_field_value"
  end

  create_table "findings", :force => true do |t|
    t.integer  "owner_id"
    t.string   "title"
    t.integer  "responsible_user_id"
    t.date     "completion_date"
    t.text     "reference"
    t.string   "regulatory_violation"
    t.string   "policy_violation"
    t.boolean  "safety"
    t.string   "classification"
    t.boolean  "repeat"
    t.boolean  "immediate_action"
    t.text     "action_taken"
    t.string   "department"
    t.integer  "approver_id"
    t.text     "description"
    t.boolean  "authority"
    t.boolean  "controls"
    t.boolean  "interfaces"
    t.boolean  "policy"
    t.boolean  "procedures"
    t.boolean  "process_measures"
    t.boolean  "responsibility"
    t.string   "other"
    t.string   "severity"
    t.string   "likelihood"
    t.string   "risk_factor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "statement"
    t.string   "status",                  :default => "New"
    t.date     "schedule_date"
    t.date     "open_date"
    t.date     "complete_date"
    t.text     "narrative"
    t.string   "owner_type"
    t.text     "analysis_result"
    t.integer  "custom_id"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.integer  "obj_id"
    t.integer  "audit_obj_id"
    t.integer  "responsible_user_poc_id"
    t.integer  "approver_poc_id"
    t.text     "privileges"
    t.text     "findings_comment"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.string   "extra_risk"
    t.string   "mitigated_risk"
    t.text     "final_comment"
    t.integer  "created_by_id"
  end

  create_table "hazards", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "sra_id"
    t.text     "description"
    t.integer  "severity"
    t.string   "likelihood"
    t.string   "risk_factor"
    t.text     "statement"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                :default => "Open"
    t.integer  "custom_id"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.date     "close_date"
    t.integer  "respnsible_user_id"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.integer  "created_by_id"
  end

  create_table "ims", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "lead_evaluator"
    t.date     "completion_date"
    t.string   "location"
    t.string   "apply_to"
    t.string   "org_type"
    t.text     "obj_scope"
    t.text     "ref_req"
    t.text     "instruction"
    t.integer  "pre_reviewer"
    t.string   "job_aid"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                :default => "New"
    t.date     "date_complete"
    t.text     "comment"
    t.date     "date_open"
    t.integer  "custom_id"
    t.integer  "lead_evaluator_poc_id"
    t.integer  "pre_reviewer_poc_id"
    t.integer  "obj_id"
    t.boolean  "viewer_access",         :default => false
  end

  create_table "inspections", :force => true do |t|
    t.string   "title"
    t.string   "department"
    t.integer  "responsible_user_id"
    t.date     "completion"
    t.string   "inspection_type"
    t.string   "location"
    t.string   "station_code"
    t.string   "vendor"
    t.string   "inspection_department"
    t.string   "process"
    t.boolean  "planned"
    t.string   "supplier"
    t.text     "objective"
    t.text     "reference"
    t.text     "instruction"
    t.integer  "approver_id"
    t.string   "status",                :default => "New"
    t.boolean  "viewer_access",         :default => false
    t.date     "open_date"
    t.date     "complete_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
    t.integer  "custom_id"
    t.integer  "approver_poc_id"
    t.text     "privileges"
    t.text     "inspector_comment"
    t.text     "final_comment"
    t.integer  "created_by_id"
    t.boolean  "template"
    t.integer  "recurrence_id"
  end

  create_table "investigations", :force => true do |t|
    t.string   "title"
    t.integer  "responsible_user_id"
    t.date     "completion"
    t.date     "open_date"
    t.date     "complete_date"
    t.string   "inv_type"
    t.boolean  "ntsb"
    t.boolean  "safety_hazard"
    t.string   "source"
    t.datetime "event_occured"
    t.integer  "approver_id"
    t.text     "approver_comment"
    t.text     "notes"
    t.string   "likelihood"
    t.string   "severity"
    t.string   "risk_factor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "local_event_occured"
    t.text     "containment"
    t.text     "description"
    t.text     "statement"
    t.string   "status",                :default => "New"
    t.boolean  "viewer_access",         :default => false
    t.integer  "custom_id"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.integer  "obj_id"
    t.integer  "approver_poc_id"
    t.integer  "investigator_poc_id"
    t.integer  "record_id"
    t.text     "privileges"
    t.text     "investigator_comment"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.text     "final_comment"
    t.integer  "created_by_id"
    t.boolean  "template"
    t.integer  "recurrence_id"
  end

  create_table "issues", :force => true do |t|
    t.integer  "faa_report_id"
    t.date     "issue_date"
    t.string   "title"
    t.text     "safety_issue"
    t.text     "corrective_action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.date     "start_date"
    t.date     "end_date"
  end

  create_table "matrix_connections", :force => true do |t|
    t.integer "matrix_id"
    t.integer "owner_id"
    t.string  "type"
  end

  create_table "meetings", :force => true do |t|
    t.string   "type"
    t.datetime "review_start"
    t.datetime "review_end"
    t.datetime "meeting_start"
    t.datetime "meeting_end"
    t.string   "review_timezone"
    t.string   "meeting_timezone"
    t.text     "notes"
    t.string   "status"
    t.string   "imp"
    t.datetime "closing_date"
    t.integer  "custom_id"
    t.integer  "obj_id"
    t.text     "privileges"
    t.text     "final_comment"
  end

  create_table "message_accesses", :force => true do |t|
    t.integer "messages_id"
    t.integer "users_id"
    t.string  "status"
    t.string  "type"
    t.boolean "visible"
    t.integer "message_outbox_id"
    t.integer "user_poc_id"
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "content"
    t.datetime "due"
    t.integer  "response_id"
    t.integer  "response_outbox_id"
    t.integer  "outbox_id"
    t.datetime "time"
    t.string   "link"
    t.string   "link_type"
    t.integer  "link_id"
  end

  create_table "notices", :force => true do |t|
    t.integer  "users_id"
    t.string   "content"
    t.string   "status"
    t.datetime "expire_date"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "action"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "start_date"
    t.boolean  "create_email", :default => false
  end

  create_table "notifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "owner_id"
    t.string   "users_id"
    t.string   "message"
    t.date     "notify_date"
  end

  create_table "oauth_nonces", :id => false, :force => true do |t|
    t.integer  "id",         :default => 0, :null => false
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_tokens", :id => false, :force => true do |t|
    t.integer  "id",                                  :default => 0, :null => false
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 40
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "occurrence_templates", :force => true do |t|
    t.integer  "parent_id"
    t.string   "title"
    t.string   "format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "options"
  end

  create_table "occurrences", :force => true do |t|
    t.integer  "template_id"
    t.string   "owner_type"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "value"
  end

  create_table "orm_fields", :force => true do |t|
    t.string   "name"
    t.string   "low"
    t.integer  "low_pt"
    t.string   "moderate"
    t.integer  "moderate_pt"
    t.string   "high"
    t.string   "high_pt"
    t.integer  "orm_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orm_submission_fields", :force => true do |t|
    t.integer "orm_submission_id"
    t.integer "orm_field_id"
    t.string  "selected"
  end

  create_table "orm_submissions", :force => true do |t|
    t.string   "tail_number"
    t.integer  "user_id"
    t.integer  "total_score"
    t.integer  "orm_template_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "extra_low",       :default => 0
    t.integer  "extra_moderate",  :default => 0
    t.integer  "extra_high",      :default => 0
  end

  create_table "orm_templates", :force => true do |t|
    t.string   "name"
    t.integer  "created_by"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.integer  "owner_id"
    t.string   "level_of_compliance"
    t.text     "statement"
    t.text     "description"
    t.text     "plan"
    t.text     "responsibility"
    t.date     "plan_due_date"
    t.text     "comment"
    t.string   "status",              :default => "Open"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "meeting_id"
    t.integer  "reviewer_id"
    t.date     "date_complete"
    t.integer  "custom_id"
    t.integer  "owner_obj_id"
    t.integer  "obj_id"
    t.integer  "meeting_obj_id"
    t.text     "minutes"
  end

  create_table "participations", :force => true do |t|
    t.string  "type"
    t.integer "meetings_id"
    t.integer "users_id"
    t.string  "status"
    t.string  "comment"
    t.integer "obj_id"
    t.integer "poc_id"
  end

  create_table "private_links", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "digest"
    t.date     "expire_date"
    t.string   "access_level"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "privileges", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "example"
  end

  create_table "query_conditions", :force => true do |t|
    t.integer  "query_statement_id"
    t.string   "condition_type"
    t.string   "condition_value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "template_id"
    t.string   "classname"
    t.integer  "field_id"
    t.string   "fieldname"
    t.integer  "category_id"
    t.string   "category_name"
    t.text     "value"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  create_table "query_statements", :force => true do |t|
    t.string   "title"
    t.boolean  "visualize"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "privileges"
    t.string   "target_class"
  end

  create_table "recommendations", :force => true do |t|
    t.integer  "owner_id"
    t.string   "status",                  :default => "New"
    t.string   "owner_type"
    t.string   "title"
    t.string   "department"
    t.integer  "responsible_user_id"
    t.date     "response_date"
    t.boolean  "immediate_action"
    t.string   "recommended_action"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "open_date"
    t.date     "complete_date"
    t.integer  "custom_id"
    t.integer  "obj_id"
    t.integer  "owner_obj_id"
    t.integer  "user_poc_id"
    t.text     "privileges"
    t.text     "recommendations_comment"
    t.integer  "approver_id"
    t.text     "final_comment"
    t.integer  "created_by_id"
  end

  create_table "record_fields", :force => true do |t|
    t.text     "value"
    t.integer  "records_id"
    t.integer  "fields_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "object_id"
  end

  create_table "records", :force => true do |t|
    t.string   "status"
    t.integer  "templates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.integer  "users_id"
    t.datetime "event_date"
    t.integer  "reports_id"
    t.boolean  "viewer_access",         :default => false
    t.integer  "obj_id"
    t.string   "severity"
    t.string   "likelihood"
    t.string   "risk_factor"
    t.text     "statement"
    t.integer  "custom_id"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.date     "close_date"
    t.integer  "investigation_id"
    t.boolean  "anonymous"
    t.integer  "sra_id"
    t.string   "event_time_zone"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.text     "final_comment"
  end

  add_index "records", ["templates_id"], :name => "fk_record_template"

  create_table "recurrences", :force => true do |t|
    t.string   "title"
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
    t.string   "form_type"
    t.integer  "template_id"
    t.string   "frequency"
    t.integer  "newest_id"
    t.date     "next_date"
    t.date     "end_date"
  end

  create_table "report_meetings", :force => true do |t|
    t.integer  "report_id"
    t.integer  "meeting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.string   "status"
    t.string   "description"
    t.integer  "templates_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "eir"
    t.string   "disposition"
    t.string   "company_disposition"
    t.boolean  "scoreboard"
    t.boolean  "asap"
    t.boolean  "sole"
    t.text     "narrative"
    t.text     "regulation"
    t.text     "notes"
    t.string   "severity"
    t.string   "likelihood"
    t.string   "risk_factor"
    t.text     "statement"
    t.integer  "custom_id"
    t.integer  "obj_id"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.text     "minutes"
    t.date     "close_date"
    t.text     "privileges"
    t.string   "venue"
    t.string   "crew"
    t.string   "icao"
    t.string   "event_label"
    t.datetime "event_date"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
  end

  add_index "reports", ["templates_id"], :name => "fk_report_template"

  create_table "responsible_users", :force => true do |t|
    t.integer  "owner_id"
    t.string   "type"
    t.integer  "user_id"
    t.string   "status"
    t.text     "comments"
    t.text     "instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "risk_controls", :force => true do |t|
    t.string   "title"
    t.integer  "hazard_id"
    t.string   "status",                    :default => "New"
    t.integer  "responsible_user_id"
    t.integer  "approver_id"
    t.date     "scheduled_completion_date"
    t.string   "control_type"
    t.text     "description"
    t.text     "monitoring"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "approver_comment"
    t.text     "follow_up"
    t.text     "notes"
    t.boolean  "action_implemented"
    t.date     "date_complete"
    t.date     "date_open"
    t.integer  "custom_id"
    t.date     "follow_up_date"
    t.text     "final_comment"
    t.integer  "created_by_id"
  end

  create_table "risk_matrix_cells", :force => true do |t|
    t.integer  "table_row"
    t.integer  "table_column"
    t.string   "value"
    t.string   "color"
    t.integer  "table_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "risk_matrix_groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "risk_matrix_tables", :force => true do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_count"
    t.integer  "column_count"
  end

  create_table "roles", :force => true do |t|
    t.integer  "users_id"
    t.integer  "privileges_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "poc_id"
  end

  create_table "root_causes", :force => true do |t|
    t.integer  "owner_id"
    t.string   "type"
    t.integer  "cause_option_id"
    t.string   "cause_option_value"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "safety_plans", :force => true do |t|
    t.string   "title"
    t.string   "risk_factor"
    t.text     "concern"
    t.text     "objective"
    t.text     "background"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time_period"
    t.integer  "monitor_interval"
    t.text     "evaluation_items"
    t.date     "date_started"
    t.date     "date_completed"
    t.string   "result"
    t.string   "risk_factor_after"
    t.string   "status",            :default => "New"
    t.text     "follow_up"
    t.integer  "custom_id"
    t.integer  "created_by_id"
  end

  create_table "section_fields", :force => true do |t|
    t.string  "value"
    t.integer "section_id"
    t.integer "field_id"
  end

  create_table "sections", :force => true do |t|
    t.string   "type"
    t.integer  "owner_id"
    t.integer  "template_id"
    t.string   "status"
    t.string   "title"
    t.integer  "assignee_id"
    t.integer  "approver_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "signatures", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "signee_name"
    t.integer  "user_id"
    t.string   "owner_id"
    t.string   "owner_type"
    t.string   "path"
  end

  create_table "sms_actions", :force => true do |t|
    t.string   "title"
    t.string   "responsible_department"
    t.date     "schedule_completion_date"
    t.boolean  "immediate_action"
    t.string   "immediate_action_comment"
    t.boolean  "comprehensive_action"
    t.string   "comprehensive_action_comment"
    t.integer  "approver_id"
    t.string   "action_taken"
    t.text     "description"
    t.integer  "owner_id"
    t.string   "status",                       :default => "New"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "responsible_user_id"
    t.boolean  "emp"
    t.boolean  "dep"
    t.string   "owner_type"
    t.text     "comment"
    t.date     "open_date"
    t.date     "complete_date"
    t.integer  "custom_id"
    t.integer  "owner_obj_id"
    t.integer  "obj_id"
    t.integer  "user_poc_id"
    t.integer  "approver_poc_id"
    t.text     "privileges"
    t.text     "sms_actions_comment"
    t.string   "severity"
    t.string   "likelihood"
    t.string   "risk_factor"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.string   "extra_risk"
    t.string   "mitigated_risk"
    t.text     "statement"
    t.text     "final_comment"
    t.integer  "created_by_id"
  end

  create_table "sms_tasks", :force => true do |t|
    t.integer  "owner_id"
    t.string   "title"
    t.string   "department"
    t.integer  "res"
    t.date     "completion"
    t.integer  "app_id"
    t.string   "action"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "owner_type"
    t.integer  "owner_obj_id"
  end

  create_table "sras", :force => true do |t|
    t.string   "title"
    t.string   "type_of_change"
    t.text     "current_description"
    t.text     "plan_description"
    t.text     "departments"
    t.text     "departments_comment"
    t.text     "manuals"
    t.text     "manuals_comment"
    t.text     "programs"
    t.text     "programs_comment"
    t.date     "scheduled_completion_date"
    t.integer  "approver_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "other_department"
    t.string   "other_manual"
    t.string   "other_program"
    t.string   "status",                    :default => "Open"
    t.integer  "reviewer_id"
    t.string   "system_task"
    t.text     "compliances"
    t.text     "compliances_comment"
    t.string   "other_compliance"
    t.text     "closing_comment"
    t.text     "reviewer_comment"
    t.text     "approver_comment"
    t.integer  "responsible_user_id"
    t.date     "date_complete"
    t.integer  "meeting_id"
    t.integer  "custom_id"
    t.string   "likelihood"
    t.string   "severity"
    t.string   "risk_factor"
    t.string   "likelihood_after"
    t.string   "severity_after"
    t.string   "risk_factor_after"
    t.text     "statement"
    t.boolean  "viewer_access",             :default => false
    t.text     "minutes"
    t.integer  "record_id"
    t.string   "severity_extra"
    t.string   "probability_extra"
    t.string   "mitigated_severity"
    t.string   "mitigated_probability"
    t.datetime "followup_date"
    t.integer  "created_by_id"
  end

  create_table "submission_fields", :force => true do |t|
    t.text     "value"
    t.integer  "submissions_id"
    t.integer  "fields_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "object_id"
  end

  add_index "submission_fields", ["object_id"], :name => "mg2"
  add_index "submission_fields", ["submissions_id"], :name => "mg3"

  create_table "submissions", :force => true do |t|
    t.integer  "records_id"
    t.integer  "templates_id"
    t.text     "description"
    t.datetime "event_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "obj_id"
    t.boolean  "completed"
    t.integer  "custom_id"
    t.boolean  "anonymous"
    t.string   "event_time_zone"
    t.integer  "owner_id"
    t.string   "type"
  end

  add_index "submissions", ["obj_id"], :name => "mg1"
  add_index "submissions", ["templates_id"], :name => "fk_submission_template"

  create_table "tax_attributes", :force => true do |t|
    t.string "category"
    t.string "label"
    t.string "url_reference"
    t.text   "definition"
    t.string "control_class"
    t.string "source"
  end

  create_table "templates", :force => true do |t|
    t.integer  "access"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_id"
    t.string   "emp_group"
    t.string   "report_type"
    t.integer  "map_template_id"
    t.string   "js_link"
    t.boolean  "archive",         :default => false
    t.boolean  "allow_anonymous", :default => false
    t.string   "description"
  end

  create_table "trackings", :force => true do |t|
    t.string   "title"
    t.string   "priority"
    t.string   "category"
    t.string   "description"
    t.date     "start_date"
    t.date     "due_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "complete_date"
    t.string   "status"
  end

  create_table "transactions", :force => true do |t|
    t.integer  "users_id"
    t.integer  "owner_id"
    t.datetime "stamp"
    t.text     "content"
    t.string   "action"
    t.string   "owner_type"
    t.integer  "user_poc_id"
    t.integer  "owner_obj_id"
    t.string   "poc_first_name"
    t.string   "poc_last_name"
    t.string   "alt_user"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "level"
    t.string   "full_name"
    t.string   "airport"
    t.string   "module_access"
    t.string   "email_notifications"
    t.string   "role"
    t.string   "unique_id"
    t.string   "airline",                 :limit => 3
    t.string   "job_title"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.integer  "poc_id"
    t.string   "mobile_number"
    t.string   "work_phone_number"
    t.string   "employee_number"
    t.boolean  "disable"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "android_version"
    t.datetime "last_seen_at"
    t.string   "sso_id"
    t.datetime "privileges_last_updated"
  end

  create_table "verifications", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "owner_id"
    t.string   "users_id"
    t.string   "detail"
    t.string   "status"
    t.date     "verify_date"
    t.date     "address_date"
    t.string   "address_comment"
  end

  create_table "viewer_comments", :force => true do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "alt_user"
  end

end
