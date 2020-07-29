PrdgSession::Application.routes.draw do |map|

  #Kaushik Mahorker OAuth
  resources :oauth_clients

  #root :to => "oauth_clients#index"
  match '/oauth/test_request',    :to => 'oauth#test_request',          :as => :test_request
  match '/oauth/token',           :to => 'oauth#token',                 :as => :token
  match '/oauth/access_token',    :to => 'oauth#access_token',          :as => :access_token
  match '/oauth/request_token',   :to => 'oauth#request_token',         :as => :request_token
  match '/oauth/authorize',       :to => 'oauth#authorize',             :as => :authorize
  match '/oauth',                 :to => 'oauth#index',                 :as => :oauth
  match '/saml/consume',          :to => 'saml#consume',                :as => :consume
  match '/saml/metadata',         :to => 'saml#metadata',               :as => :metadata
  match '/saml/init',             :to => 'saml#init',                   :as => :init
  match '/sso',                   :to => 'saml#init',                   :as => :init
  match '/saml/logout',           :to => 'saml#logout',                 :as => :saml
  match '/mobile/initialize',     :to => 'sessions#mobile_initialize',  :as => :session
  match '/mobile/activate',       :to => 'sessions#mobile_activate',    :as => :session

  map.signup 'signup', :controller => 'users', :action => 'new'
  map.logout 'logout', :controller => 'sessions', :action => 'destroy'
  map.login 'login', :controller => 'sessions', :action => 'new'
  match 'direct_login', to: 'sessions#new', as: :new, direct: :true


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

  resources :errors do
    collection do
      post 'debug_report'
    end
  end

  # System Feature
  resources :sms_tasks
  resources :contacts
  resources :costs
  resources :viewer_comments

  resources :automated_notifications do
    collection do
      get 'retract_fields'
    end
  end
  resources :notifications
  resources :notices do
    member do
      get 'read_message'
    end
    collection do
      post 'mark_all_as_read'
    end
  end
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
  resources :modes do
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
      get 'reply'
      get 'foward'
      get 'inbox'
      get 'prev'
      put 'read'
    end
    collection do
      get 'sent'
      get 'message_submitter'
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
  resources :queries do
    member do
      get "clone"
      post "add_visualization"
      get "remove_visualization"
      post "generate_visualization"
    end
    collection do
      get 'load_conditions_block'
    end
  end


  # Configurations
  resources :canned_messages
  resources :distribution_lists
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
  resources :root_causes do
    collection do
      get 'new_root_cause'
      get 'retract_categories'
      post 'add'
      get 'reload'
    end
  end
  resources :occurrence_templates do
    collection do
      post 'new_root'
    end
    member do
      post 'archive'
    end
  end
  resources :occurrences do
    collection do
      post 'add'
    end
  end
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
      post 'add_template'
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
      get 'current_json'
      put 'mobile_months'
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
      get 'interpret'
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
      post 'load_records'
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
      post 'load_records'
      post "search"
      post "search_all"
      post "filter"
      get "advanced_search"
      get "detailed_search"
      get "custom_view"
      get "dynamic_categories"
      post "observation_phases_trend"
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
      post 'load_records'
      get "add"
      get "bind"
      get 'print'
      get "advanced_search"
      get "summary"
      get "tabulation"
      get 'load_records'
    end
    member do
      get 'launch'
      get 'launch_new_object'
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
      get "get_cisp_records"
      get "send_cisp_records"
      get 'override_status'
    end
    collection do
      post 'load_records'
      get 'advanced_search'
      get "send_success"
    end
  end
  resources :corrective_actions do
    collection do
      post 'load_records'
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
      get 'clone'
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
      get 'download_checklist'
      get 'interpret'
      get 'new_attachment'
      get 'new_checklist'
      get 'new_requirement'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
      get 'update_checklist'
      get 'update_checklist_records'
      get 'viewer_access'
      post 'upload_checklist'
    end
    collection do
      post 'load_records'
      get "advanced_search"
    end
  end
  resources :inspections do
    member do
      get 'download_checklist'
      get 'interpret'
      get 'new_attachment'
      get 'new_checklist'
      get 'new_requirement'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
      get 'update_checklist'
      get 'viewer_access'
      post 'upload_checklist'
    end
    collection do
      post 'load_records'
      get 'advanced_search'
    end
  end
  resources :evaluations do
    member do
      get 'interpret'
      get 'new_attachment'
      get 'new_checklist'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
      get 'update_checklist'
      get 'viewer_access'
      post 'upload_checklist'
    end
    collection do
      post 'load_records'
      get "advanced_search"
    end
  end
  resources :investigations do
    member do
      get 'baseline'
      get 'interpret'
      get 'mitigate'
      get 'new_cause'
      get 'new_desc'
      get 'new_attachment'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
      get 'viewer_access'
      post 'add_causes'
      post 'add_desc'
    end
    collection do
      get 'retract_cause_attributes'
      get 'retract_desc_attributes'
      post 'load_records'
      get "advanced_search"
    end
  end
  resources :findings do
    member do
      get 'baseline'
      get 'interpret'
      get 'reassign'
      get 'comment'
      get 'mitigate'
      get 'new_attachment'
      get 'print'
      get 'reopen'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
    end
    collection do
      post 'load_records'
      get 'advanced_search'
    end
  end
  resources :sms_actions do
    collection do
      post 'load_records'
      get 'advanced_search'
      get 'get_term'
    end
    member do
      get 'baseline'
      get 'interpret'
      get 'mitigate'
      get 'new_attachment'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
      get 'reassign'
    end
  end

  resources :recommendations do
    member do
      get 'interpret'
      get 'new_attachment'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'print'
    end
    collection do
      post 'load_records'
      get 'advanced_search'
    end
  end





  # SRA Module
  resources :sras do
    member do
      get 'interpret'
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
      get 'launch'
      get 'launch_new_object'
      get 'comment'
      get 'viewer_access'
    end
    collection do
      post 'load_records'
      get 'advanced_search'
      get "new_section"
      post "add_section"
      get 'edit_section'
      post 'update_section'
    end
  end
  resources :hazards do
    member do
      get 'interpret'
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
      get 'launch'
      get 'launch_new_object'
      get 'comment'
    end
    collection do
      post 'load_records'
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
      post 'load_records'
      get 'advanced_search'
    end
    member do
      get 'interpret'
      get "new_cost"
      get 'assign'
      get 'complete'
      get 'approve'
      get 'new_attachment'
      get 'print'
      get 'print_deidentified'
      get 'reopen'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'comment'
    end
  end
  resources :safety_plans do
    collection do
      post 'load_records'
      get 'advanced_search'
    end
    member do
      get 'interpret'
      get "new_attachment"
      get "print"
      get 'complete'
      get 'reopen'
      get 'override_status'
      get 'launch'
      get 'launch_new_object'
      get 'comment'
    end
  end
  resources :srm_meetings do
    member do
      get 'interpret'
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
