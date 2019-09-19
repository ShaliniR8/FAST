namespace :v1_0_3 do
  logger = Logger.new('log/patch.log', File::WRONLY | File::APPEND)
  logger.datetime_format = "%Y-%m-%d %H:%M:%S"
  logger.formatter = proc do |severity, datetime, progname, msg|
   "[#{datetime}]: #{msg}\n"
  end

  task :patch_all => :environment do
    desc 'Run all updates from v1.0.2 to v1.0.3'
    logger.info '###########################'
    logger.info '### VERSION 1.0.3 PATCH ###'
    logger.info '###########################'
    logger.info "Start Time: #{DateTime.now.strftime("%F %R")}"

    Rake::Task['v1_0_3:risk_matrix_transform'].invoke()
    Rake::Task['v1_0_3:add_access_controls'].invoke()
    Rake::Task['v1_0_3:populate_custom_options'].invoke()
    Rake::Task['v1_0_3:populate_created_by'].invoke()

    logger.info "Finish Time: #{DateTime.now.strftime("%F %R")}"
  end

  task :add_access_controls => :environment do
    desc 'Populates Access Controls with core rules'
    logger.info 'Executing Access Control Additions Patch'
    rules = AccessControl.get_meta
    rules.each do |rule, data|
      data.each do |key, val|
        new_rule = AccessControl.new(
          :list_type => 1,
          :action => val,
          :entry => rule) if AccessControl.where(action: val, entry: rule).empty?
        new_rule.save if !new_rule.nil?
      end
    end
  end

  task :add_common_privileges => :environment do
    desc 'Adds new, common privileges'
    logger.info 'Executing Common Privilege Additions Patch'
    OBSERVATION_SUBMITTER_ID = 127
    OBSERVATION_ANALYST_ID = 128
    CONCERN_SUBMITTER_ID = 129
    CONCERN_ANALYST_ID = 130

    BEGIN_SUB_PRIV = 100
    END_SUB_PRIV = 104
    BEGIN_ANALYST_PRIV = 105
    END_ANALYST_PRIV = 109

    #for each submitter privilege id
    for i in BEGIN_SUB_PRIV..END_SUB_PRIV
      #get every association of the privilege
      roles = Role.where :privileges_id => i
      roles.each do |r|
        user_id = r.users_id
        #if role does not already exist
        #add role for the user
        if Role.where(:users_id => user_id, :privileges_id => OBSERVATION_SUBMITTER_ID).empty?
          Role.create :users_id => user_id, :privileges_id => OBSERVATION_SUBMITTER_ID
        end
        if Role.where(:users_id => user_id, :privileges_id => CONCERN_SUBMITTER_ID).empty?
          Role.create :users_id => user_id, :privileges_id => CONCERN_SUBMITTER_ID
        end
      end
    end

    #for each analyst privilege id
    for i in BEGIN_ANALYST_PRIV..END_ANALYST_PRIV
      #get every association of the privilege
      roles = Role.where :privileges_id => i
      roles.each do |r|
        user_id = r.users_id
        #if role does not already exist
        #add role for the user
        if Role.where(:users_id => user_id, :privileges_id => OBSERVATION_ANALYST_ID).empty?
          Role.create :users_id => user_id, :privileges_id => OBSERVATION_ANALYST_ID
        end
        if Role.where(:users_id => user_id, :privileges_id => CONCERN_ANALYST_ID).empty?
          Role.create :users_id => user_id, :privileges_id => CONCERN_ANALYST_ID
        end
      end
    end
  end

  task :populate_created_by => :environment do
    desc 'Updates all transactions for polymorphism and populates created_by_id fields'
    logger.info 'Executing Transaction Updates and populating created_by_id Fields'
    transaction_types = [
      "CorrectiveActionTransaction",
      "SraTransaction",
      "HazardTransaction",
      "RiskControlTransaction",
      "AuditTransaction",
      "InspectionTransaction",
      "EvaluationTransaction",
      "InvestigationTransaction",
      "FindingTransaction",
      "RecommendationTransaction",
      "SmsActionTransaction"
    ]

    transactions = Transaction.where(:action => 'Create', :type => transaction_types)

    transactions.each do |x|
      t_type = x.type
      t_type.slice! "Transaction"
      owner = Object.const_get(t_type).find(x.owner_id)
      owner.created_by_id = x.users_id
      owner.save
    end

  end

  task :set_other_general_to_pilots => :environment do
    pilots = User.where(:level => "Pilot")
    pilots.each do |p|
      p.privileges << Privilege.find(10)
      p.save
    end
  end

  task :populate_custom_options => :environment do
    desc 'Redefines all custom_options fields'
    logger.info 'Executing Population of Custom Options'

    CustomOption.where(:title => "Risk Control Type").destroy_all
    CustomOption.where(:title => "System Task Analysis").destroy_all

    if CustomOption.where(:title => "Manuals").empty?
      CustomOption.create({
        :title => 'Manuals',
        :field_type => 'Checkbox',
        :options => "AMC;A28;AOM;CAM;CMP8;DSP;EMH;ERP;ETP;FAM;FCT;FOM;FOT;GHM;GMM;HAZ;LLM;MEL;OPS SPEC;ORG;QRH;RVS;SEC;SMS;WBM;FORMS",
        :description => "This manages all the Manual selections in the system.",
      })
    end
    if CustomOption.where(:title => "Programs").empty?
      CustomOption.create({
        :title => 'Programs',
        :field_type => 'Checkbox',
        :options => "Aircarft Ground Deicing/Anti-icing Program;Approved Training Manual;AQP FLight Training Master Plan;AQP Instructor/Evaluator Qualifications Standards;AQP Pliot Qualification Standards;Bonded Component Structural Repair Process/Procedure;Carry-on Baggage Program;Centralized Maintenance Control and Performance Monitoring;Electrical Wiring Interconnection Systems (EWIS);Engine and APU Oil Servicing;Engineering Specification Maintenance (ESM) Adjustment;ETOPS;Exit Seat Program;Fleet AOM;Fleet MEL/CDL;Fleet Performance Manual;Fleet Quick Ref Handbook;Flight Attendant's Training Program;Inflight Manual;LMP;Major Repair Tracking and Reporting;MEL General Section;Non-essential Equipment & Furnishings (NEF) Program;Operations Specifications;Organization Designation Authorization (ODA); Parts Pooling, Loans and Borrows;Powerplant Condition Monitored Maintenance (CMM) Program;Reduced Vertical Separation Minima (RVSM) ;Reliability/Performance Analysis;Repair Station Quality Control Manual - TUL/AFW ;Security Manual (SCR);Service Difficulty Report (SDR);Therapeutic Oxygen Program (PSM);Transport CAAC Maintenance Implementation Procedure Supplement;TUL European Aviation Safety Agency Supplement (EASA);Weight & Balance Control",
        :description => "This manages all the Programs selections in the system.",
      })
    end
    if CustomOption.where(:title => "Regulatory Compliances").empty?
      CustomOption.create({
        :title => 'Regulatory Compliances',
        :field_type => 'Checkbox',
        :options => "CFR;Additional Company Personnel;Vendors;Company Policies/Procedures;Training/Retraining;New/Updated Equipment;Office/Inflight/Ramp Environment",
        :description => "This manages all the Regulatory Compliances selections in the system.",
      })
    end
    if CustomOption.where(:title => "Departments").empty?
      CustomOption.create({
        :title => 'Departments',
        :field_type => 'Checkbox',
        :options => "Dispatch;FAA;Finance;Flight Crew;Flight Operations;Ground;Ground Operations;Human Resources;In-Flight;Maintenance;MIS;Quality;Safety;Security;Sales;Customer Service;Technical Publications",
        :description => "This manages all the Department selections in the system.",
      })
    end
    if CustomOption.where(:title => "Audit Types").empty?
      CustomOption.create({
        :title => 'Audit Types',
        :field_type => 'Checkbox',
        :options => "CASE;CASS;OpsCASS;IEP - DOD;IEP - SAS;IEP - ATOS;Follow-Up;External - DOD;External - FAA;External - Other;IOSA",
        :description => "This manages all the Audit Types in Safety Assurance.",
      })
    end
    if CustomOption.where(:title => "Classifications").empty?
      CustomOption.create({
        :title => 'Classifications',
        :field_type => 'Checkbox',
        :options => "Class I - Out of Compliance or Unsafe Condition;Class II - Out of Conformance;Class III - Concern (Deficiency);NCF - Nonconformance;QRC - Quality Related Concern",
        :description => "This manages all the Classifications in the system.",
      })
    end
    if CustomOption.where(:title => "Reason for change").empty?
      CustomOption.create({
        :title => 'Reason for change',
        :field_type => 'Checkbox',
        :options => "New Hazard;Operational Environment;Operational Procedure/Process;Organization;System",
        :description => "This manages all the Classifications in the system.",
      })
    end
    if CustomOption.where(:title => "SRA Type of Change").empty?
      CustomOption.create({
        :title => 'SRA Type of Change',
        :field_type => 'Checkbox',
        :options => "New;Revision to Existing",
        :description => "This manages options in \"Type of Change\" in SRA. ",
      })
    end
    if CustomOption.where(:title => "Risk Control Types").empty?
      CustomOption.create({
        :title => 'Risk Control Types',
        :field_type => 'Checkbox',
        :options => "Predictive;Proactive;Reactive",
        :description => "This manages options in \"Risk Control Type\" in Risk Control.",
      })
    end
    if CustomOption.where(:title => "Systems/Tasks").empty?
      CustomOption.create({
        :title => 'Systems/Tasks',
        :field_type => 'Checkbox',
        :options => "New Hazard;Operational Environment;Operational Procedure;Operational Process;Organization;System",
        :description => "This manages all the System Task selections in the system.",
      })
    end
    if CustomOption.where(:title => "Risk Factors").empty?
      CustomOption.create({
        :title => 'Risk Factors',
        :field_type => 'Checkbox',
        :options => "Green - ACCEPTABLE;Yellow - ACCEPTABLE WITH MITIGATION;Orange - UNACCEPTABLE",
        :description => "This manages all Risk Factors in the system",
      })
    end
    if CustomOption.where(:title => "Suppliers").empty?
      CustomOption.create({
        :title => 'Suppliers',
        :field_type => 'Checkbox',
        :options => "External;Internal;Supplier",
        :description => "This manages all Suppliers in the system.",
      })
    end
    if CustomOption.where(:title => "Station Codes").empty?
      CustomOption.create({
        :title => 'Station Codes',
        :field_type => 'Checkbox',
        :options => "Please go to Custom Options to add options.",
        :description => "This manages all Station Codes in the system.",
      })
    end
    if CustomOption.where(:title => "Results").empty?
      CustomOption.create({
        :title => 'Results',
        :field_type => 'Checkbox',
        :options => "Satisfactory;Unsatisfactory",
        :description => "This manages all the Results selections in the system.",
      })
    end
    if CustomOption.where(:title => "Evaluation Types").empty?
      CustomOption.create({
        :title => 'Evaluation Types',
        :field_type => 'Checkbox',
        :options => "ATOS;CASE;CASS;DOD;EPA;EPI;FAA;FOQA;GOE;INTERNAL MANUAL;IOSA;LOSA;OSHA;POLICY;PROCEDURE;QA;SAI;SOP",
        :description => " This manages all Evaluations Types in SA.",
      })
    end
    if CustomOption.where(:title => "Investigation Types").empty?
      CustomOption.create({
        :title => 'Investigation Types',
        :field_type => 'Checkbox',
        :options => "Accident;Concern;Incident;Significant Event",
        :description => "This manages all Investigation Types in SA.",
      })
    end
    if CustomOption.where(:title => "Sources").empty?
      CustomOption.create({
        :title => 'Sources',
        :field_type => 'Checkbox',
        :options => "ASAP Hotline;ASAP Report;FOOA;Fax;Legacy Data;Mobile;Pager;Paper Submission;SDR;Web Submission;Web Notification",
        :description => "This manages all Sources selections in the system.",
      })
    end
    if CustomOption.where(:title => "Actions Taken").empty?
      CustomOption.create({
        :title => 'Actions Taken',
        :field_type => 'Checkbox',
        :options => "Check Ride;Coaching;Employee Counseled;Employee Training;Letter of Warning;Manual Revision;Procedure Change",
        :description => "This manages all the Actions Taken selections in SA.",
      })
    end
    if CustomOption.where(:title => "System Task Analysis SHEL(L) Models").empty?
      CustomOption.create({
        :title => 'System Task Analysis SHEL(L) Models',
        :field_type => 'Checkbox',
        :options => "CFR;Additional Company Personnel;Vendors;Company Policies/Procedures;Training/Retraining;New/Updated Equipment;Office/Inflight/Ramp Environment",
        :description => "This manages all the System Task Analysis SHEL(L) Models in SRA.",
      })
    end
  end

  task :risk_matrix_transform => :environment do
    desc 'Reorganizes risk matrix order to proper form for each airline'
    logger.info 'Executing Risk Matrix Transform Patch'
    case BaseConfig.airline_code
    when "BOE"
      logger.info "BOE risk matrix transform"
      matrix_dic = BOE_Config::MATRIX_INFO[:risk_table][:rows]
      risk_dic = BOE_Config::MATRIX_INFO[:risk_table_index]
      [
        'Report',
        'Record',
        'Finding',
        'SmsAction',
        'Investigation',
        'Sra',
        'Hazard',
      ].each do |type|
        Object.const_get(type).all.each do |x|
          severity = x.severity.to_i if x.severity.present?
          likelihood = x.likelihood.to_i if x.likelihood.present?
          risk_factor = risk_dic[matrix_dic[severity][likelihood].to_sym] rescue nil
          x.risk_factor = risk_factor

          severity_after = x.severity_after.to_i if x.severity_after.present?
          likelihood_after = x.likelihood_after.to_i if x.likelihood_after.present?
          risk_factor_after = risk_dic[matrix_dic[severity_after][likelihood_after].to_sym] rescue nil
          x.risk_factor_after = risk_factor_after
          x.save
        end
      end
    when "SCX"
      logger.info "SCX risk matrix transform"
    when "NAMS"
      logger.info "NAMS risk matrix transform"
      matrix_dic = NAMS_Config::MATRIX_INFO[:risk_table][:rows]
      risk_dic = NAMS_Config::MATRIX_INFO[:risk_table_index]
      [
        'Report',
        'Record',
        'Finding',
        'SmsAction',
        'Investigation',
        'Sra',
        'Hazard',
      ].each do |type|
        Object.const_get(type).all.each do |x|
          severity = x.severity.to_i if x.severity.present?
          likelihood = x.likelihood.to_i if x.likelihood.present?
          risk_factor = risk_dic[matrix_dic[severity][likelihood].to_sym] rescue nil
          x.risk_factor = risk_factor

          severity_after = x.severity_after.to_i if x.severity_after.present?
          likelihood_after = x.likelihood_after.to_i if x.likelihood_after.present?
          risk_factor_after = risk_dic[matrix_dic[severity_after][likelihood_after].to_sym] rescue nil
          x.risk_factor_after = risk_factor_after
          x.save
        end
      end
    else
      logger.info "No airline specified risk matrix transform."
    end
  end

end

