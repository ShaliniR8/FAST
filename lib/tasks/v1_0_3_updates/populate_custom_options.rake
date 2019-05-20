namespace :version_1_0_3 do

  task :populate_custom_options => :environment do

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


end

