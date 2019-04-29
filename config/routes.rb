PrdgSession::Application.routes.draw do |map|

  #Kaushik Mahorker OAuth
  resources :oauth_clients

  #root :to => "oauth_clients#index"
  match '/oauth/test_request',  :to => 'oauth#test_request',  :as => :test_request
  match '/oauth/token',         :to => 'oauth#token',         :as => :token
  match '/oauth/access_token',  :to => 'oauth#access_token',  :as => :access_token
  match '/oauth/request_token', :to => 'oauth#request_token', :as => :request_token
  match '/oauth/authorize',     :to => 'oauth#authorize',     :as => :authorize
  match '/oauth',               :to => 'oauth#index',         :as => :oauth
  match '/saml/consume',        :to => 'saml#consume',        :as => :consume
  match '/saml/metadata',       :to => 'saml#metadata',       :as => :metadata
  match '/saml/init',           :to => 'saml#init',           :as => :init

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  map.resources :sessions


# PROSAFET APP
  #Kaushik Mahorker OAuth API
  namespace :api do
    namespace :v1 do
      match "data" => "data#show"
    end
  end

  resources :sessions do
     get 'get_user_json'
  end

  resources :signatures, only:[:show]

  # System Feature
  resources :automated_notifications do
    collection do
      get 'retract_fields'
    end
  end
  resources :notifications
  resources :notices
  resources :private_links
  resources :verifications do
    member do
      get 'address'
    end
  end
  resources :extension_requests do
    member do
      get 'address'
    end
  end
  resources :errors do
    collection do
      get 'switch'
    end
  end
  resources :tax_attributes
  resources :documents do
    member do
      get 'download'
    end

    collection do
      get "revision_history"
      get "user_guides"
      get "load_content"
    end
  end
  resources :messages do
    member do
      get "reply"
      get "foward"
      get "inbox"
      get "prev"
    end
    collection do
      get "sent"
    end
  end
  resources :time do
    collection do
      get 'now'
    end
  end
  resources :trackings
  resources :invitations
  resources :causes do
    member do
    end
    collection do
      get 'new_causes'
      post 'create_causes'
      get 'retract_attributes'
    end
  end
  resources :home do
    collection do
      get 'choose_module'
      get 'update_analytics_timerange'
      get 'query_all'
      post 'search_all'
      get 'draw_chart'
      get 'advanced_search'
    end
  end
  resources :recurrences


  # Configurations
  resources :canned_messages
  resources :custom_options
  resources :cause_options do
    member do
      get "download"
    end
  end
  resources :risk_matrix_groups
  resources :risk_matrix_tables do
    member do
      get "add_row"
      get "add_column"
      get "remove_row"
      get "remove_column"
    end
  end
  resources :sections
  resources :root_causes
  resources :checklist_templates do
    member do

    end
    collection do
      get 'download_questions'
      get 'download_records'
      get 'select_checklist'
      post 'create_checklist_record'
    end
  end
  resources :checklist_headers do
    member do
      get 'export'
      get 'clone'
    end
  end
  resources :checklists do
    member do
      get 'start'
      get 'export'
    end
    collection do
      get 'retract_form_upload'
      get 'retract_form_template'
    end
  end
  resources :checklist_rows
  resources :responsible_users


  # User and Access Control
  resources :users do
    member do
      get "self_edit"
      get "change_password"
      get "edit_privilege"
      post "update_privilege"
      get "disable"
      get "password_resets"
      get "simulate"
      get "stop_simulation"
      get 'access_level'
      #resources :password_resets, only: [:new, :create, :edit, :update]
    end
    collection do
      get "users_index"
      get 'get_user'
      get 'get_json'   #Added by BP July 14 2017
      get 'submission_json'
      get "notices_json"    #added by BL OCT 10 2018
    end
  end
  resources :password_resets
  resources :privileges do
    member do
      get "users"
      get "rules"
    end
  end
  resources :access_controls do
    member do
      get "new_assignment"
      post "assign"
      get "delete_assignment"
      get "list_privileges"
    end
    collection do
      get "assignments"
      get "get_options"
      get "module_index"
    end
  end
  resources :groups do
    member do
      get "view_user"
      post "update_access"
    end
  end



  # Safety Reporting Module
  resources :submissions do
    member do
      get 'print'
      get 'export'
      get 'continue'
      get 'get_json'
      get 'fsap'
      get 'msap'
      get 'csap'
      get 'dsap'
      get 'comment'
    end
    collection do
      get 'query'
      get 'advanced_search'
      get "detailed_search"
      get "custom_view"
      get 'dynamic_categories'
      get 'incomplete'
      get 'export_all'
      get 'airport_data'
      get "fsap_all"
      post 'search'
      get "template_json" #Added by BP Aug 8 render the json of templates accessible to current user
      get "user_submission_json" #Added by BP Aug 15 render the json of submissions of current user
    end
  end
  resources :records do
    member do
      get "close"
      get 'convert'
      get 'mitigate'
      get 'baseline'
      get 'print'
      get 'enable'
      get 'comment'
      get 'new_attachment'
      get "reopen"
      get "display"
      get 'open'
      get 'override_status'
    end
    collection do
      post "search"
      post "search_all"
      post "filter"
      get "advanced_search"
      get "detailed_search"
      get "custom_view"
      get "dynamic_categories"
      get "observation_phases_trend"
      get "query"
      get "query_all"
      get "update_listing_table"
      get "update_threat"
      get "update_subthreat"
      get "update_err"
      get "update_suberr"
      get "update_hfactor"
      get "airport_data"
      get "draw_chart"
    end
  end
  resources :reports do
    collection do
      get "add"
      get "bind"
      get 'print'
      get "advanced_search"
      get "summary"
      get "tabulation"
    end
    member do
      get 'mitigate'
      get 'baseline'
      get "print"
      get "close"
      get "add_meeting"
      get "carryover"
      get "meeting_ready"
      get "get_agenda"
      get "new_attachment"
      get "new_minutes"
      get 'show_narrative'
      get "reopen"
      get 'override_status'
      get 'comment'
    end
  end
  resources :meetings do
    member do
      get "message"
      post "send_message"
      get "close"
      get "new_attachment"
      get "comment"
      get 'print'
      get "reopen"
      get "get_reports"
      get 'override_status'
    end
    collection do
      get "send_success"
    end
  end
  resources :corrective_actions do
    collection do
      get 'advanced_search'
      get 'get_term'
    end
    member do
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'override_status'
      get 'assign'
      get 'complete'
      get 'approve'
      get 'comment'
    end
  end
  resources :query_statements do
    member do
      get 'copy'
      get 'analytic_data'
      get "analytic_data_all"
      get "visualization_table"
      get "visualization_table_all"
    end
    collection do
      get 'detailed_values'

    end
  end
  resources :templates do
    member do
      get 'get_json'
      get "archive"
    end
    collection do
      get "show_nested"
      post "edit_nested_fields"
    end
  end
  resources :fields
  resources :orm_templates
  resources :orm_fields
  resources :orm_submissions
  resources :faa_reports do
    member do
      get "enhance"
      get "reports_table"
      get "print"
      get "export_word"
      get "edit_enhancement"
    end
    collection do
      get "current"
    end
  end



  # Safety Assurance Module
  resources :audits do
    member do
      get 'reoccur'
      get 'download_checklist'
      get 'new_task'
      get 'new_contact'
      get 'new_cost'
      get 'new_requirement'
      get 'new_signature'
      get 'new_checklist'
      post 'upload_checklist'
      get 'update_checklist'
      get 'assign'
      get 'complete'
      get 'approve'
      get 'viewer_access'
      get 'comment'
      get 'print'
      get 'print_deidentified'
      get 'new_attachment'
      get 'reopen'
      get 'update_checklist_records'
      get 'override_status'
    end
    collection do
      get "advanced_search"
    end
  end
  resources :inspections do
    member do
      get 'new_task'
      get 'new_contact'
      get 'new_cost'
      get 'new_requirement'
      get 'new_signature'
      get 'new_finding'
      get 'new_checklist'
      post 'upload_checklist'
      get 'open'
      get 'update_checklist'
      get 'assign'
      get 'complete'
      get 'approve'
      get 'viewer_access'
      get 'comment'
      get 'print'
      get 'print_deidentified'
      get 'new_attachment'
      get 'download_checklist'
      get 'reopen'
      get 'override_status'
    end
    collection do
      get "advanced_search"
    end
  end
  resources :evaluations do
    member do
      get 'new_task'
      get 'new_contact'
      get 'new_cost'
      get 'new_requirement'
      get 'new_signature'
      get 'new_finding'
      get 'new_checklist'
      post 'upload_checklist'
      get 'open'
      get 'update_checklist'
      get 'assign'
      get 'complete'
      get 'approve'
      get 'viewer_access'
      get 'comment'
      get 'print'
      get 'print_deidentified'
      get 'new_attachment'
      get 'download_checklist'
      get 'reopen'
      get 'override_status'
    end
    collection do
      get "advanced_search"
    end
  end
  resources :investigations do
    member do
      get 'mitigate'
      get 'baseline'
      get 'new_recommendation'
      get 'new_signature'
      get 'new_contact'
      get 'new_finding'
      get 'new_action'
      get 'new_task'
      get 'new_cost'
      get 'assign'
      get 'approve'
      get 'complete'
      get 'print'
      get 'print_deidentified'
      get 'viewer_access'
      get "new_cause"
      post 'add_causes'
      get 'new_desc'
      post 'add_desc'
      get 'new_attachment'
      get 'download_checklist'
      get 'reopen'
      get 'override_status'
      get 'comment'
    end
    collection do
      get 'retract_cause_attributes'
      get 'retract_desc_attributes'
      get "advanced_search"
    end
  end
  resources :findings do
    member do
      get 'mitigate'
      get 'baseline'
      get "open"
      get 'assign'
      get "reassign"
      get 'new_action'
      get 'complete'
      get 'approve'
      get 'new_recommendation'
      get 'comment'
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'release_finding_transaction'
      get 'release_with_user'
      get 'reopen'
      get 'override_status'
    end
    collection do
      get "advanced_search"
    end
  end
  resources :sms_actions do
    collection do
      get 'advanced_search'
      get 'get_term'
    end
    member do
      get 'assign'
      get 'reassign'
      get 'new_cost'
      get 'complete'
      get 'approve'
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'mitigate'
      get 'baseline'
      get 'reopen'
      get 'override_status'
      get 'comment'
    end
  end
  resources :finding_action, :controller => 'sms_actions'

  resources :recommendations do
    member do
      get 'assign'
      get 'complete'
      get 'approve'
      get 'release'
      get 'new_attachment'
      get 'print'
      get 'reopen'
      get 'override_status'
      get 'comment'
    end
    collection do
      get 'advanced_search'
    end
  end





  # SRA Module
  resources :sras do
    member do
      get 'enable'
      get 'mitigate'
      get 'baseline'
      get 'carryover'
      get "new_minutes"
      get 'reopen'
      get 'new_hazard'
      get 'new_attachment'
      get 'close'
      get 'assign'
      get 'complete'
      get 'approve'
      get 'print'
      get 'print_deidentified'
      get 'get_agenda'
      get 'override_status'
      get 'comment'
    end
    collection do
      get 'advanced_search'
      get "new_section"
      post "add_section"
      get 'edit_section'
      post 'update_section'
    end
  end
  resources :hazards do
    member do
      get 'mitigate'
      get 'baseline'
      get 'new_risk_control'
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'complete'
      get 'reopen'
      get "new_root_cause"
      get "reload_root_causes"
      get 'override_status'
      get 'comment'
    end
    collection do
      get 'advanced_search'
      get "retract_root_cause_categories"
      get "root_cause_trend"
      post "filter"
      get "update_listing_table"
      post "add_root_cause"
      get "new_root_cause2"
    end
  end
  resources :risk_controls do
    collection do
      get 'advanced_search'
    end
    member do
      get "new_cost"
      get 'assign'
      get 'complete'
      get 'approve'
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'reopen'
      get 'override_status'
      get 'comment'
    end
  end
  resources :safety_plans do
    collection do
      get 'advanced_search'
    end
    member do
      get "new_attachment"
      get "print"
      get 'complete'
      get 'reopen'
      get 'override_status'
      get 'comment'
    end
  end
  resources :srm_meetings do
    member do
      get "message"
      post "send_message"
      get "close"
      get "new_attachment"
      get "comment"
      get 'print'
      get 'add_sras'
      post 'sras'
      get "reopen"
    end
    collection do
    end
  end






  # SMS IM Module
  resources :ims do
    member do
      get 'schedule'
      get 'new_task'
      get 'new_contact'
      get 'new_expectation'
      get 'reoccur'
      get 'transit'
      get 'new_checklist'
      post 'upload_checklist'
      get 'download_checklist'
      get 'update_checklist'
      get 'new_attachment'
      get 'new_package'
      get 'show_package'
      get 'complete'
      get 'approve'
      get 'print'
      get 'enable'
    end
    collection do
      get "advanced_search"
    end
  end
  resources :packages do
    member do
      get "new_attachment"
      get 'get_agenda'
      get 'carryover'
      get 'print'
      get 'close'
      get "new_minutes"
    end
    collection do
      get "advanced_search"
    end
  end
  resources :sms_meetings do
    member do
      get "message"
      post "send_message"
      get "close"
      get "new_attachment"
      get "comment"
      get 'print'
      get 'add_packages'
      post 'packages'
    end
    collection do
    end
  end




  map.resources :gateway

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"
  map.root :controller=>'gateway', :action=>'index'

  # See how all your routes lay out with "rake routes"


  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
