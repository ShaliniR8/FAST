class RecordReaction < Cause
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
      "Action Taken" => [
        {name: "Action Taken",                          type: "check_box"},
        {name: "AOC Notified",                          type: "check_box"},
        {name: "Accepted",                              type: "check_box"},
        {name: "Administered Oxygen",                   type: "check_box"},
        {name: "After-the-Fact",                        type: "check_box"},
        {name: "Clinical Manager Notified",             type: "check_box"},
        {name: "Company Report Filed",                  type: "check_box"},
        {name: "Corrected at Time of Discovery",        type: "check_box"},
        {name: "Executed Rejected Takeoff",             type: "check_box"},
        {name: "Inflight Route Deviation",              type: "check_box"},
        {name: "Insufficient Time to Take Action",      type: "check_box"},
        {name: "MEL/CDL Addition/Modification",         type: "check_box"},
        {name: "Medaire-Form-Completed",                type: "check_box"},
        {name: "Medical Director Notified",             type: "check_box"},
        {name: "Medical Treatment",                     type: "check_box"},
        {name: "No Action Taken",                       type: "check_box"},
        {name: "Notified AOSC",                         type: "check_box"},
        {name: "Notified CBP",                          type: "check_box"},
        {name: "Notified Crew",                         type: "check_box"},
        {name: "Notified Director",                     type: "check_box"},
        {name: "Notified Dispatch",                     type: "check_box"},
        {name: "Notified Duty Officer",                 type: "check_box"},
        {name: "Notified GSC",                          type: "check_box"},
        {name: "Notified LEO",                          type: "check_box"},
        {name: "Notified Manager",                      type: "check_box"},
        {name: "Notified OCC",                          type: "check_box"},
        {name: "Notified Safety Department",            type: "check_box"},
        {name: "Notified Security Department",          type: "check_box"},
        {name: "Notified Supervisor",                   type: "check_box"},
        {name: "Notified TSA",                          type: "check_box"},
        {name: "Notified/Contacted ATC",                type: "check_box"},
        {name: "Obtained Loaner Tablet/Mini Manual",    type: "check_box"},
        {name: "Release Ammendment",                    type: "check_box"},
        {name: "Unable to Take Action",                 type: "check_box"},
        {name: "Management First Name",                  type: "text_field"},
        {name: "Management Last Name",                  type: "text_field"},
        {name: "Management Phone Number",                type: "text_field"},
        {name: "Other Action Taken",                    type: "text_field"},
      ],

      "Aircraft Handling/Configuration/Performance Control" => [
        {name: "Aircraft Handling/Configuration/Performance Control",                            type: "check_box"},
        {name: "Automation",                                                                     type: "check_box"},
        {name: "Automation Overrode Flight Crew",                                                type: "check_box"},
        {name: "Configuration Warning",                                                          type: "check_box"},
        {name: "Flap Altitude Exceedence",                                                       type: "check_box"},
        {name: "Flap Setting",                                                                   type: "check_box"},
        {name: "Loss of Aircraft Control",                                                       type: "check_box"},
        {name: "Power Settings/Speed Control-Thrust Reversers, Auto-Throttle",                   type: "check_box"},
        {name: "Speed Brake/Spoilers",                                                           type: "check_box"},
        {name: "Trim",                                                                           type: "check_box"},
        {name: "Use of Flight Controls (On Ground)",                                             type: "check_box"},
        {name: "Use of Primary/Manual Flight Controls (Airborne)-Aileron, Rudder, or Elevator",  type: "check_box"},
        {name: "Other Aircraft Handling/Configuration/Performance Control ",                     type: "text_field"},
      ],

      "Aircraft System/Equipment Malfunction" => [
        {name: "Aircraft System/Equipment Malfunction",          type: "check_box"},
        {name: "ADS-B",                                          type: "check_box"},
        {name: "APU Operations",                                 type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Abnormal Engine Indications",                    type: "check_box"},
        {name: "Air Conditioning/Pressurization",                type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Aircraft Lighting",                              type: "check_box"},
        {name: "Aircraft Vibration",                             type: "check_box"},
        {name: "Brakes and Steering",                            type: "check_box"},
        {name: "Communication Equipment",                        type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Compressor Stall",                               type: "check_box"},
        {name: "Configuration Warning",                          type: "check_box"},
        {name: "Deferred Items-MEL/CDL",                         type: "check_box"},
        {name: "Doors/Windows",                                  type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "EFIS/EICAS Failure",                             type: "check_box"},
        {name: "Electrical System Failure",                      type: "check_box"},
        {name: "Engine Anomaly",                                 type: "check_box"},
        {name: "Engine EGT",                                     type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine EPR/N1/N2",                               type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine Failure/Flameout",                        type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine Fire/Overheat",                           type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine Oil/Pressure/Temperature/Quantity",       type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine Shutdown",                                type: "select", options: ["In Flight", "On Ground"]},
        {name: "Engine Vibration",                               type: "select", options: ["In Flight", "On Ground"]},
        {name: "Equipment Malfunction",                          type: "text_field"},
        {name: "Equipment Malfunction Type",                     type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Equipment Problem Dissipated",                   type: "check_box"},
        {name: "Fire Warning System Alert/Malfunction",          type: "check_box"},
        {name: "First Time or Repeated",                         type: "select", options: ["First Time", "Repeated"]},
        {name: "Flap Malfunction",                               type: "check_box"},
        {name: "Flight Controls/Computers",                      type: "select", options: ["Ailerons", "Elevator", "Flaps Leading Edge", "Flaps Trailing Edge", "Other", "Rudder"]},
        {name: "Flight Instruments-AS/ADI/HIS",                  type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Fuel System Malfuntion",                         type: "check_box"},
        {name: "Hydraulic Fluid-Quantity/PSI",                   type: "check_box"},
        {name: "Hydraulic System",                               type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "In-flight Hoist Malfunction",                    type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Landing Gear/Tires/Brakes",                      type: "check_box"},
        {name: "Loss of Braking",                                type: "check_box"},
        {name: "Loss of Power/Thrust",                           type: "check_box"},
        {name: "Navigation Equipment/Radar",                     type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Oxygen/Safety Equipment",                        type: "select", options: ["Failure","False Indication","Inaccurate","Indication","Jammed","Leak","Malfunction","Other","Overheat","Shutdown","Type of Event","Unsecured"]},
        {name: "Pitch Instability",                              type: "check_box"},
        {name: "Stall Warning/Stick Shaker",                     type: "check_box"},
        {name: "System Misinterpretation",                       type: "check_box"},
        {name: "Uncommanded Control Inputs",                     type: "check_box"},
        {name: "Unresponsive Controls",                          type: "check_box"},
        {name: "Windshield",                                     type: "select", options: ["Cracked", "Crazed", "Failure", "Hazed", "Heat Damage", "Leak", "Scratched", "Shattered"]},
        {name: "Other Aircraft System/Equipment Malfunction",    type: "text_field"},
      ],

      "Controller" => [
        {name: "Controller", type: "check_box"},
        {name: "ATC Issued New Clearance", type: "check_box"},
        {name: "Issued Advisory", type: "check_box"},
        {name: "Issued Alert", type: "check_box"},
        {name: "Provided Flight Assist", type: "check_box"},
        {name: "Separated Traffic", type: "check_box"},
        {name: "Other Controller", type: "text_field"},
      ],

      "Flight Crew" => [
        { name: "Aircraft Maintenance Logbook Write UP", type: "check_box"},
        { name: "Alternate Gear Extension", type: "check_box"},
        { name: "Autorotation", type: "check_box"},
        { name: "Operational Control Issues", type: "check_box"},
        { name: "Post Event Debrief Conducted", type: "check_box"},
        { name: "Requested Priority with ATC", type: "check_box"},
        { name: "Required Inspection Performed", type: "check_box"},
        { name: "Through Flight Not Completed", type: "check_box"},
        { name: "Wrong Taxiway", type: "check_box"},
        { name: "Exercised Captain Emergency Authority", type: "check_box"},
        { name: "Declared Emergency with ATC ", type: "select", options: ['Yes', 'No']},
        { name: "Precautionary Landing", type: "check_box"},
        { name: "Landed in Emergency Condition", type: "check_box"},
        { name: "Became Reoriented", type: "check_box"},
        { name: "Changed Configuration-Flaps/Trim", type: "check_box"},
        { name: "Contacted ATC", type: "check_box"},
        { name: "Contacted Company", type: "check_box"},
        { name: "Contacted Maintenance", type: "check_box"},
        { name: "Contacted Operations", type: "check_box"},
        { name: "Corrected Pitch/Power", type: "check_box"},
        { name: "Declared Critically Low Fuel", type: "check_box"},
        { name: "Engine Shutdown", type: "check_box"},
        { name: "Executed Emergency Descent", type: "check_box"},
        { name: "Executed Go Around", type: "check_box"},
        { name: "Executed Missed Approach", type: "check_box"},
        { name: "Exited Adverse Environment", type: "check_box"},
        { name: "Exited Penetrated Airspace", type: "check_box"},
        { name: "Flight Crew Response", type: "check_box"},
        { name: "Flight Crew Response: Other ", type: "text_field"},
        { name: "Operated in Degraded Conditions", type: "check_box"},
        { name: "Overcame Equipment Problem", type: "check_box"},
        { name: "Overrode Automation", type: "check_box"},
        { name: "Regained Aircraft Control", type: "check_box"},
        { name: "Rejected Landing (Less than 50 ft. AGL)", type: "check_box"},
        { name: "Requested Emergency Equipment", type: "check_box"},
        { name: "Reset Circuit Breakers  ", type: "select", options: ['In Flight', 'On Ground']},
        { name: "Returned to Assigned Airspace", type: "check_box"},
        { name: "Returned to Assigned Altitude", type: "check_box"},
        { name: "Returned to Assigned Course/Heading", type: "check_box"},
        { name: "Returned to Assigned Speed", type: "check_box"},
        { name: "Returned to Departure Airport", type: "check_box"},
        { name: "Returned to Original Clearance", type: "check_box"},
        { name: "Took Evasive Action", type: "check_box"},
        { name: "Took Precautionary Avoidance Action", type: "check_box"},
      ],

      "Flight Status after Event" => [
        {name: "Flight Interruption", type: "check_box"},
        {name: "Aircraft Grounded", type: "check_box"},
        {name: "Delay Code   ", type: "text_field"},
        {name: "Diversion Type  ", type: "select", options: ['Cargo Related', 'Maintenance', 'Operational', 'Weather']},
        {name: "Flight Denial", type: "check_box"},
        {name: "Flight Partially Completed", type: "check_box"},
        {name: "Maintenance Check", type: "check_box"},
        {name: "No Disruption", type: "check_box"},
        {name: "Precautionary Landing", type: "check_box"},
        {name: "Reason for Diversion  ", type: "select", options: ['Cargo Related', 'Maintenance', 'Operational', 'Weather']},
        {name: "Rerouted", type: "check_box"},
        {name: "Tow to Gate", type: "check_box"},
        {name: "Unplanned Emergency Landing", type: "check_box"},
        {name: "Diversion-Filed Alternate", type: "check_box"},
        {name: "Diversion-Other Alternate", type: "check_box"},
        {name: "Air Turnback", type: "check_box"},
        {name: "Diversion", type: "check_box"},
        {name: "Evacuation", type: "check_box"},
        {name: "Executed Go Around", type: "check_box"},
        {name: "Flight Cancellation", type: "check_box"},
        {name: "Flight Delay", type: "check_box"},
        {name: "Flight Delay Duration (Hrs) ", type: "text_field"},
        {name: "Flight Delay Duration (Min) ", type: "text_field"},
        {name: "Gate Turnback", type: "check_box"},
        {name: "In-Flight Shutdown", type: "check_box"},
        {name: "Planned Emergency Landing", type: "check_box"},
        {name: "Rejected Takeoff", type: "check_box"},
        {name: "Rejected Takeoff: High Speed", type: "check_box"},
        {name: "Rejected Takeoff: Initiation Speed (KIAS) ", type: "text_field"},
        {name: "Rejected Takeoff: Low Speed", type: "check_box"},
        {name: "Other Flight Diversion/Air-Ground Return  ", type: "text_field"},

      ],

      "Illness/Injury Event" => [
        {name: "Emergency/Life Support Issues", type: 'check_box'},
        {name: "Illness/Injury Event", type: 'check_box'},
        {name: "AED", type: 'check_box'},
        {name: "AMC Injury Location ", type: 'select', options: ['Base','At Aircraft','On Scene','At Hospital']},
        {name: "Advised Captain of injury/Illness", type: 'check_box', options: []},
        {name: "Air Medical Crew  ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Airport Medical Response", type: 'check_box', options: []},
        {name: "Bites ", type: 'select', options: ['Insect', 'Pet']},
        {name: "Cabin Crew  ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Degree of Injury  ", type: 'select', options: ['none','minor','serious','fatal','unknown','Requires hospitilazation >48 hours','Fractures of any bone except simple fractures of fingers, toes, nose','Severe hemorages, nerve, muscle or tendon damage','Involves internal organ','Involves second or third degree burns or burns affecting >5% of body']},
        {name: "Dispatch Personnel  ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Emergency Personnel", type: 'check_box', options: []},
        {name: "Flight Deck Crew  ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Ground Crew ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Ground Medical Service Communication  ", type: 'select', options: ['Communication Link', 'Dispatch', 'Other']},
        {name: "Injury/Illness Other Employee ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Location Where Injury Occurred  ", type: 'select', options: ['Aisle','Boarding Area','Cabin','Galley','Jetbridge','Lavatory','Layover','Ramp','Seat','Stairs','Terminal','Ticket Counter']},
        {name: "Maintenance ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Medical Assistance Provider ", type: 'select', options: ['Airport Medical Response', 'Ground Medical Service', 'Onboard Medical Professional']},
        {name: "Medical Emergency", type: 'check_box', options: []},
        {name: "Medical Onboard", type: 'check_box', options: []},
        {name: "Other Authorized Passenger  ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Passenger ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Patient Family Member ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Specialty Team Member ", type: 'select', options: ['Bite','Fatality','Incapacitation','Illness','Injury','Communicable Disease Exposure']},
        {name: "Type of Injury  ", type: 'select', options: ['Bite','Burn','Contusion','Fracture','Laceration','Other','Sprain/Strain']},
        {name: "Type of Injury/Illness  ", type: 'select', options: ['Adverse Reaction','Allergy','Amputation','Avulsion','Bruise','Burn','Cancer','Concussion','Contagious/Infectious Disease','Contusion','Crush','Cumulative Trauma','Death','Dehydration','Dermatitis','Diabetes','Dislocation','Emotional/Mental Symptoms','Exposure','Foreign Body','Fracture','Frostbite','Hearing Loss','Heart Attack','Heart-Related Illness','Hernia','High Blood Pressure','Infection','Inflammation','Laceration','Pain','Poisoning','Pressure Change Symptoms','Puncture','Psychological','Repetitive Motions','Respiratory Disorders','Scrape','Seizure','Shock','Sprain','Strain','Stroke']},
        {name: "Did this occur on aircraft  ", type: 'select', options: ['Yes', 'No']},
        {name: "Location Where Injury Occurred  ", type: 'select', options: ['Aisle','Boarding Area','Cabin','Galley','Hangar','Jetbridge','Lavatory','Layover','Maintenance Shop','Office Environment','Ramp','Seat','Stairs','Terminal','Ticket Counter']},
        {name: "Number of Lost Work Days  ", type: 'text_field', options: []},
        {name: "Illness/Injury Event: Other ", type: 'text_field', options: []},
        {name: "Name of Injured Person  ", type: 'text_field', options: []},
        {name: "Contacted Ground Medical Service", type: 'select', options: ['No','No Contact','Poor Reception','Yes']},
      ],

      "Landing Event" => [
        {name: "Landing Event", type: 'check_box'},
        {name: "Confined Area Landing", type: 'check_box'},
        {name: "Gear Up Landing", type: 'check_box'},
        {name: "Hard Landing", type: 'check_box'},
        {name: "LAHSO Issue", type: 'check_box'},
        {name: "Landing Long", type: 'check_box'},
        {name: "Landing Short", type: 'check_box'},
        {name: "Misconfiguration", type: 'check_box'},
        {name: "Nose First Landing", type: 'check_box'},
        {name: "Overweight Landing", type: 'check_box'},
        {name: "Tailstrike", type: 'check_box'},
        {name: "Taxiway Landing", type: 'check_box'},
        {name: "Without Clearance", type: 'check_box'},
        {name: "Wrong Airport", type: 'check_box'},
        {name: "Wrong Runway", type: 'check_box'},
        {name: "Other Landing Event", type: 'text_field'},
      ],

      "Narrative" => [
        {name: "Narrative", type: "text_area"}
      ],

      "Operations" => [
          {name: "Operations", type: "check_box"},
          {name: "CSM Met Aircraft", type: "check_box"},
          {name: "Cabin Contacted Pilot", type: "check_box"},
          {name: "Denied Boarding", type: "check_box"},
          {name: "Dispatcher Action", type: "check_box"},
          {name: "FAA Met Aircraft", type: "check_box"},
          {name: "Facility Evacuation", type: "check_box"},
          {name: "Minimum FA Crew Not on Board", type: "check_box"},
          {name: "PAIP", type: "check_box"},
          {name: "Paramedics Met Aircraft", type: "check_box"},
          {name: "Removed Passenger", type: "check_box"},
          {name: "Security Met Aircraft", type: "check_box"},
          {name: "Other Operations", type: "text_field"},
      ]

    }).sort.to_h
  end
end
