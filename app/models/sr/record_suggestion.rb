class RecordSuggestion < Cause
  belongs_to :record,foreign_key:"owner_id",class_name:"Record"

  def self.get_headers
    [
      {:title=>"Category",:field=>"category"},
      {:title=>"Attribute",:field=>"get_attr"},
      {:title=>"Value",:field=>"get_value"}
    ]
  end

  def get_value
    if self.value=="true"
      "Yes"
    else
      self.value
    end
  end


  def self.categories
    ({
      'ATC Complications/Errors' => [
        {name: "ATC_Complications_Errors",             type: "check_box"},
        {name: "ATC Unprofessionalism",                type: "check_box"},
        {name: "Air Traffic Congestion",               type: "check_box"},
        {name: "Conflicting ATC Clearance",            type: "check_box"},
        {name: "Expected vs. Assigned ATC Clearance",  type: "check_box"},
        {name: "Frequency Change",                     type: "check_box"},
        {name: "Frequency Congestion",                 type: "check_box"},
        {name: "Handling Error",                       type: "check_box"},
        {name: "Incorrect ATC Clearance",              type: "check_box"},
        {name: "Late ATC Clearance",                   type: "check_box"},
        {name: "Lost Communication",                   type: "check_box"},
        {name: "Pre-Departure Clearance",              type: "check_box"},
        {name: "Radio Congestion",                     type: "check_box"},
        {name: "Shift Change",                         type: "check_box"},
        {name: "Similar Call Signs",                   type: "check_box"},
        {name: "TCAS RA/TA",                           type: "check_box"},
        {name: "Unclear ATC Clearance",                type: "check_box"},
        {name: "Unpublished Restriction",              type: "check_box"},
        {name: "Wake Turbulence",                      type: "check_box"},
        {name: "Other ATC Complications/Errors",       type: "text_field"}
      ],

      "Airline Operations Complications" => [
        {name: "Airline Operations Factors",                                   type: "check_box"},
        {name: "Crew Notification",                                            type: "check_box"},
        {name: "Crew Scheduling Event-Late Arriving Crew or Aircraft",         type: "check_box"},
        {name: "Inaccurate, Confusing or New Flight Plan, NOTAMs or Logbook",  type: "check_box"},
        {name: "Inaccurate, Confusing or New MEL Procedure",                   type: "check_box"},
        {name: "Inaccurate, Confusing or New Manuals/Procedure/SOP",           type: "check_box"},
        {name: "New or Unfamiliar Airport",                                    type: "check_box"},
        {name: "Other Airline Operations Factors",                             type: "text_field"}

      ],

      "Airport Facility Issues" => [
        {name: "Airport Facility Issues",                             type: "check_box"},
        {name: "Airport Complexity",                                  type: "check_box"},
        {name: "Airport/NAVAID Equipment Failure",                    type: "check_box"},
        {name: "Approach/Landing System",                             type: "check_box"},
        {name: "Automatic Terminal Information System",               type: "check_box"},
        {name: "Building/Structures/Surfaces Conditions",             type: "check_box"},
        {name: "Call for Release",                                    type: "check_box"},
        {name: "Close Proximity of Multiple Runway Thresholds",       type: "check_box"},
        {name: "Construction",                                        type: "check_box"},
        {name: "Design",                                              type: "check_box"},
        {name: "Emergency Services",                                  type: "check_box"},
        {name: "Gate Layout",                                         type: "check_box"},
        {name: "Ground/Satellite Malfunction",                        type: "check_box"},
        {name: "Groundskeeping",                                      type: "check_box"},
        {name: "High Terrain in Proximity to Airport",                type: "check_box"},
        {name: "Inaccurate/Confusing Airport Diagram",                type: "check_box"},
        {name: "Inaccurate/Confusing Approach Plate",                 type: "check_box"},
        {name: "Inaccurate/Confusing Enroute Charts",                 type: "check_box"},
        {name: "Joint Use Runway/Taxiway",                            type: "check_box"},
        {name: "Lighting/Illumination",                               type: "check_box"},
        {name: "Markings/Signage",                                    type: "check_box"},
        {name: "More than 2 Taxiways Intersecting in One Area",       type: "check_box"},
        {name: "NOTAMs",                                              type: "check_box"},
        {name: "Noise Abatement Issues",                              type: "check_box"},
        {name: "One Taxiway Leading to Multiple Runway Thresholds",   type: "check_box"},
        {name: "Runway/Taxiway",                                      type: "select", options: ["Closure", "Congestion"]},
        {name: "Short Runway (< 5,000 feet)",                         type: "check_box"},
        {name: "Short Taxi Distance",                                 type: "check_box"},
        {name: "Single Runway",                                       type: "check_box"},
        {name: "Snow Removal",                                        type: "check_box"},
        {name: "Special Airport Procedures",                          type: "check_box"},
        {name: "Visual Illusions at Takeoff or Landing",              type: "check_box"},
        {name: "Airport Facility Issue Notes",                        type: "text_field"},
        {name: "Other Airport Facility Issues ",                      type: "text_field"}
      ],

      "Error Prevention Strategies: Policies/Procedures" => [
        {name: "Polices/Procedures",                  type: "check_box"},
        {name: "Polices/Procedures Specifics  ",      type: "text_field"},
        {name: "Ramp Polices/Procedures",             type: "check_box"},
        {name: "Ramp Polices/Procedures Specifics ",  type: "text_field"},
        {name: "Other Polices/Procedures",            type: "text_field"}
      ],

      "Jepp Chart" => [
        {name: "Jepp Chart",                      type: "check_box"},
        {name: "AWA Chart",                       type: "check_box"},
        {name: "Airfield Pages (10-x, 20-7) ",    type: "text_field"},
        {name: "Airport Diagram",                 type: "check_box"},
        {name: "Airport/Approach Restriction",    type: "check_box"},
        {name: "Airspace",                        type: "check_box"},
        {name: "Airway",                          type: "check_box"},
        {name: "Chart High Altitude",             type: "check_box"},
        {name: "Chart Low Altitude",              type: "check_box"},
        {name: "Frequency ATC/AWA",               type: "check_box"},
        {name: "IAP",                             type: "check_box"},
        {name: "SID",                             type: "check_box"},
        {name: "STAR",                            type: "check_box"},
        {name: "Terminal Area",                   type: "check_box"},
        {name: "WAC",                             type: "check_box"},
        {name: "Other Jepp Chart",                type: "text_field"}
      ],

      "Narrative" => [
        {name: "Narrative", type: "text_area"}
      ],

      "Organization Factors" => [
        {name: "Organizational Factors",                           type: "check_box"},
        {name: "Airline's Safety Culture",                         type: "check_box"},
        {name: "Company Policies",                                 type: "check_box"},
        {name: "Corporate Change/Restructuring",                   type: "check_box"},
        {name: "Crew Selection",                                   type: "check_box"},
        {name: "Employee Staffing",                                type: "check_box"},
        {name: "Failure to Follow Airport Authority Guidance",     type: "check_box"},
        {name: "Failure to Follow Ground Guidance",                type: "check_box"},
        {name: "Flight Safety Standardization",                    type: "check_box"},
        {name: "Improper Record Keeping Procedures",               type: "check_box"},
        {name: "Inadequate Flight Management",                     type: "check_box"},
        {name: "Inadequate Ground Management",                     type: "check_box"},
        {name: "Inadequate Training",                              type: "check_box"},
        {name: "Labor Agreement",                                  type: "check_box"},
        {name: "Lack of Accountability",                           type: "check_box"},
        {name: "Lack of Teamwork",                                 type: "check_box"},
        {name: "Mismanagement of Assets",                          type: "check_box"},
        {name: "Not Enough Resources",                             type: "check_box"},
        {name: "Not Enough Staff",                                 type: "check_box"},
        {name: "On Time Pressure",                                 type: "check_box"},
        {name: "Quality of Support from Airport Organizations",    type: "check_box"},
        {name: "Quality of Support from Airport Vendors",          type: "check_box"},
        {name: "Quality of Support from Management",               type: "check_box"},
        {name: "Reduced Safety Standards",                         type: "check_box"},
        {name: "Rest/Duty/Flight Time",                            type: "check_box"},
        {name: "Work Group Normal Practice (Norm)",                type: "check_box"},
        {name: "Work Process/Procedure",                           type: "check_box"},
        {name: "Work Process/Procedure not Documented",            type: "check_box"},
        {name: "Work Process/Procedure not Followed",              type: "check_box"},
        {name: "Other Organizational Factors  ",                   type: "text_field"}
      ],

      "Policies/Procedures Issues" => [
        {name: "CFRs, Polices, and Procedures",        type: "check_box"},
        {name: "ATC Polices/Procedures",               type: "check_box"},
        {name: "Briefings",                            type: "check_box"},
        {name: "CFRs",                                 type: "check_box"},
        {name: "Callout",                              type: "check_box"},
        {name: "Checklists/Flows/Crosschecking",       type: "check_box"},
        {name: "Conflicting",                          type: "check_box"},
        {name: "Confusing",                            type: "check_box"},
        {name: "Currency",                             type: "check_box"},
        {name: "Emergency/Safety Equipment",           type: "check_box"},
        {name: "Equipment Usage",                      type: "check_box"},
        {name: "Failure to Respond to or Set Alerts",  type: "check_box"},
        {name: "Inaccurate Polices/Procedures",        type: "check_box"},
        {name: "Inadequate Polices/Procedures",        type: "check_box"},
        {name: "International Polices/Procedures",     type: "check_box"},
        {name: "Merger Related Issue",                 type: "check_box"},
        {name: "Nonstandard Operations",               type: "check_box"},
        {name: "Not Available",                        type: "check_box"},
        {name: "Pilot vs Maintenance Interactions",    type: "check_box"},
        {name: "Preflight Inspection",                 type: "check_box"},
        {name: "RVSM Procedure",                       type: "check_box"},
        {name: "Unfamiliar",                           type: "check_box"},
        {name: "Version Conflict",                     type: "check_box"},
        {name: "Other Polices/Procedures Issues ",     type: "text_field"}
      ],

      "Training: Customer Service Representatives" => [
        {name: "Customer Service Representatives Training"          ,type: "check_box"},
        {name: "Documentation"                                      ,type: "check_box"},
        {name: "Passenger Carry Ons"                                ,type: "check_box"},
        {name: "Policies/Procedures"                                ,type: "check_box"},
        {name: "Security"                                           ,type: "check_box"},
        {name: "Special Handling Passengers"                        ,type: "check_box"},
        {name: "Other Customer Service Representatives Training"    ,type: "text_field"}
      ],

      "Training: Dispatchers" => [
        {name: "Dispatcher Training"            ,type: "check_box"},
        {name: "Cockpit Jump Seat Observation"  ,type: "check_box"},
        {name: "Communications"                 ,type: "check_box"},
        {name: "DRM Training"                   ,type: "check_box"},
        {name: "Decisionmaking"                 ,type: "check_box"},
        {name: "Deferred Items-MEL/CDL"         ,type: "check_box"},
        {name: "Field Conditions"               ,type: "check_box"},
        {name: "Flight Planning-Initial"        ,type: "check_box"},
        {name: "Flight Releases"                ,type: "check_box"},
        {name: "Initial"                        ,type: "check_box"},
        {name: "NOTAMs"                         ,type: "check_box"},
        {name: "Operational Control"            ,type: "check_box"},
        {name: "Policies/Procedures"            ,type: "check_box"},
        {name: "Recurrent"                      ,type: "check_box"},
        {name: "Other Dispatcher Training"      ,type: "text_field"}
      ],

      "Training: Flight Attendants" => [
        {name: "Flight Attendants Training",        type: "check_box"},
        {name: "Cabin Maintenance Log",             type: "check_box"},
        {name: "Computer Based Training",           type: "check_box"},
        {name: "Drills",                            type: "check_box"},
        {name: "Emergency Equipment",               type: "check_box"},
        {name: "Initial",                           type: "check_box"},
        {name: "Life Support",                      type: "check_box"},
        {name: "Overwater",                         type: "check_box"},
        {name: "Policies/Procedures",               type: "check_box"},
        {name: "Recurrent",                         type: "check_box"},
        {name: "Reports",                           type: "check_box"},
        {name: "Security",                          type: "check_box"},
        {name: "Other Flight Attendants Training",  type: "text_field"}
      ],

      "Ground Service Technicians" => [
        {name: "Ground Service Technicians Training",        type: "check_box"},
        {name: "HAZMAT",                                     type: "check_box"},
        {name: "Marshalling",                                type: "check_box"},
        {name: "Policies/Procedures",                        type: "check_box"},
        {name: "Pushback",                                   type: "check_box"},
        {name: "Safety Zone",                                type: "check_box"},
        {name: "Security",                                   type: "check_box"},
        {name: "Other Ground Service Technicians Training",  type: "text_field"}
      ],

      "Training: Maintenance Technicians" => [
        {name: "Maintenance Technicians Training",       type: "check_box"},
        {name: "APU Operations",                         type: "check_box"},
        {name: "Air Start",                              type: "check_box"},
        {name: "Policies/Procedures",                    type: "check_box"},
        {name: "Taxi/Tow Operations",                    type: "check_box"},
        {name: "Other Maintenance Technicians Training", type: "text_field"}
      ],

      "Training: Organization" => [
        {name: "Organization Training",        type: "check_box"},
        {name: "Publish Article",              type: "check_box"},
        {name: "Standardization",              type: "check_box"},
        {name: "Supplement",                   type: "check_box"},
        {name: "Other Organization Training",  type: "check_box"}
      ],

      "Training: Pilots" => [
        {name: "CRM",                               type: "check_box"},
        {name: "Computer Based Training",           type: "check_box"},
        {name: "Emergency Equipment",               type: "check_box"},
        {name: "Flight Deck Procedures",            type: "check_box"},
        {name: "General Operating Systems",         type: "check_box"},
        {name: "Home Study",                        type: "check_box"},
        {name: "Initial Indoctrination/Awareness",  type: "check_box"},
        {name: "MEL",                               type: "check_box"},
        {name: "Overwater",                         type: "check_box"},
        {name: "Pilot Training",                    type: "check_box"},
        {name: "Policies/Procedures",               type: "check_box"},
        {name: "Recurrent",                         type: "check_box"},
        {name: "SPT",                               type: "check_box"},
        {name: "Simulator PC",                      type: "check_box"},
        {name: "Simulator PT",                      type: "check_box"},
        {name: "Standardization",                   type: "check_box"},
        {name: "Systems Airbus",                    type: "select", options: ["A300", "A310", "A319", "A320", "A321", "A330", "Other"]},
        {name: "Systems Boeing  ",                  type: "select", options: ["B717","B727","B737-100/200","B737-300/400/500","B737-NG","B747","B757","B767","B777","Other",]},
        {name: "Systems Embraer ",                  type: "select", options: ["EMB-120", "EMB-135", "EMB-140", "EMB-145", "EMB-XRJ", "Other"]},
        {name: "Transition",                        type: "check_box"},
        {name: "Upgrade",                           type: "check_box"},
        {name: "Other Pilot Training",              type: "text_field"}
      ]
    }).sort.to_h
    # ({
    #   'ATOS Elementssssssss' => [
    #     {:name=>"authority",:type=>"check_box"},
    #     {:name=>"controls",:type=>"check_box"},
    #     {:name=>"interfaces",:type=>"check_box"},
    #     {:name=>"policy",:type=>"check_box"},
    #     {:name=>"procedures",:type=>"check_box"},
    #     {:name=>"process_measures",:type=>"check_box"},
    #     {:name=>"responsibility",:type=>"check_box"},
    #     {:name=>"other",:type=>"text_field"}
    #   ],
    #   'Cabin Equipment'=> [
    #     {:name=>"cabin_equipment",:type=>"check_box"},
    #     {:name=>"66n_o2",:title=>"66N O2",:type=>"check_box"},
    #     {:name=>"aed",:title=>"AED",:type=>"check_box"},
    #     {:name=>"aed_serial_no",:title=>"AED Serial No",:type=>"text_field"},
    #     {:name=>"blood_pressure_cuff",:type=>"check_box"},
    #     {:name=>"briefing_cards",:type=>"check_box"},
    #     {:name=>"cd_player",:title=>"CD Player",:type=>"select",:options=>['Failure','Other','Overheat','Smoke/Fumes']},
    #     {:name=>"cart_repair_tag_no",:type=>"text_field"},
    #     {:name=>"ceiling_panel",:type=>"select",:options=>['Other','Unsecured']},
    #     {:name=>"circuit_breakers_pulled",:type=>"check_box"},
    #     {:name=>"closet",:type=>"select",:options=>["Failure","Jammed","Other","Smoke/Fumes","Unsecured"]},
    #     {:name=>"coffee_maker",:type=>"select",:options=>["Failure","Other","Smoke/Fumes","Unsecured","Foreign Material Inside","Foreign Material On/Under"]},
    #     {:name=>"communication_system",:type=>"select",:options=>["Failure","Other"]},
    #     {:name=>"crash_ax",:type=>"check_box"},
    #     {:name=>"crew_oxygen_system",:type=>"check_box"},
    #     {:name=>"demo_equipment_pouches",:type=>"check_box"},
    #     {:name=>"elts",:type=>"check_box",:title=>"ELTs"},
    #     {:name=>"emk_eemk",:type=>"check_box",:title=>"EMK/EEMK"},
    #     {:name=>"emergency_safety_equipment",:type=>"check_box",:title=>"Emergency/Safety Equipment"},
    #     {:name=>"entertainment_system",:type=>"select",:options=>['Failure','Other','Overheat','Smoke/Fumes']},
    #     {:name=>"fa_breakaway_flashlight",:type=>"check_box",:title=>"F/A Breakaway Flashlight"},
    #     {:name=>"first_aid_kit",:type=>"check_box"},
    #     {:name=>"gallery_cart",:type=>"select",:options=>['Availability','Brake/Wheels','Drawers','Locks','Other','Sharp Edges','Smoke/Fumes','Unsecured']},
    #     {:name=>"gallarty_cart_equipment_repair_tag_no",:title=>"Gallarty Cart-Equipment Repair Tag No",:type=>"text_field"},
    #     {:name=>"gallery_storage_bins",:type=>"select",:options=>['Jammed','Other','Unsecured']},
    #     {:name=>"halon_fire_extinguisher",:type=>"check_box"},
    #     {:name=>"ice_bucket",:type=>"check_box"},
    #     {:name=>"jumpseat",:type=>"select",:options=>['Authorization','Broken','Cushion','Harness','Seat Belt','Stowage','Other']},
    #     {:name=>"lavatory",:type=>"select",:options=>['Failure','Other','Sink','Smoke/Fumes','Toilet','Water Overflow']},
    #     {:name=>"life_jackets",:type=>"check_box"},
    #     {:name=>"life_raft",:type=>"check_box"},
    #     {:name=>"lithium_ion_battery",:type=>"check_box"},
    #     {:name=>"megaphone",:type=>"check_box"},
    #     {:name=>"onboard_wheelchair",:type=>"check_box"},
    #     {:name=>"other_emergency_equipment",:type=>"text_field"},
    #     {:name=>"other_gallery_equipement",:type=>"check_box"},
    #     {:name=>"other_gallery_equipement-compartment_number",:type=>"text_field"},
    #     {:name=>"oven",:type=>'select',:options=>["Failure","Other","Smoke/Fumes","Unsecured","Foreign Material Inside","Foreign Material On/Under"]},
    #     {:name=>"overhead_bin",:type=>"select",:options=>['Bag Shift','Failure','Jammed','Smoke/Fumes','Other','Unsecured']},
    #     {:name=>"oxygen_box_tool",:type=>"check_box"},
    #     {:name=>"pbe",:type=>"check_box",:title=>"PBE"},
    #     {:name=>"passenger_oxygen_system",:type=>"check_box"},
    #     {:name=>"passenger_seat",:type=>"select",:options=>['Cushion','Harness','Recline','Seat Belt','Track','Tray Table','Other']},
    #     {:name=>"portable_oxygen_bottle",:type=>"check_box"},
    #     {:name=>"portable_oxygen_concentrator",:type=>"check_box"},
    #     {:name=>"smoke_detectors",:type=>"select",:options=>['Activated','Failure','Vandalized','Other']},
    #     {:name=>"smoke_goggles",:type=>"check_box"},
    #     {:name=>"solid_state_o2",:type=>"check_box"},
    #     {:name=>"supplemental_oxygen",:type=>"check_box"},
    #     {:name=>"trash_containers",:type=>"select",:options=>['Other','Smoke/Fumes']},
    #     {:name=>"wall_panel",:type=>"select",:options=>["Other","Unsecured"]},
    #     {:name=>"water_fire_extinguisher",:type=>"check_box"},
    #     {:name=>"door_indication",:type=>"text_field"},
    #     {:name=>"other_cabin_equipment",:type=>"text_field"},
    #     {:name=>"serial_number",:type=>"text_field"}
    #   ]
    # }).sort.to_h
  end
end
