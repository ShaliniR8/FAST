class RecordDetection < Cause
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

  # def get_attr
  #   Rails.logger.debug "self.category=#{self.category}"
  #   self.class.categories[self.category].each do |c|
  #     if c[:name]==self.send('attr')
  #       return c[:title].present? ? c[:title] : c[:name].titleize
  #     end
  #   end
  # end

  def self.categories
    ({
        "Aircraft Equipment" => [
          {name: "Action Taken",                          type: "check_box"},
          {name: "Aircraft Equipment",                          type: "check_box"},
          {name: "Aircraft Warning/Message System",             type: "check_box"},
          {name: "Altitude Alert",                              type: "check_box"},
          {name: "GPWS",                                        type: "check_box"},
          {name: "Other Aircraft Equipment",                    type: "text_field"},
          {name: "TCAS",                                        type: "check_box"},
          {name: "Other Aircraft Equipment Specifics",          type: "text_field"}
        ],
        "ATC Equipment" => [
          {name: "ATC Equipment",                               type: "check_box"},            
          {name: "Conflict Alert",                              type: "check_box"},
          {name: "MSAW",                                        type: "check_box"},
          {name: "Other ATC Equipment",                         type: "text_field"}
        ],
        "H When Event Detected" => [
          {name: "When Event Detected" ,                         type: "check_box"},                                     
          {name: "Aircraft Cleaning" ,                           type: "check_box"},               
          {name: "Aircraft De-Ice" ,                             type: "check_box"},
          {name: "At Receiving Facility" ,                       type: "check_box"},
          {name: "At Sending Facility" ,                         type: "check_box"},
          {name: "Departure" ,                                   type: "check_box"},
          {name: "During Inspection" ,                           type: "check_box"},
          {name: "During Transfer" ,                             type: "check_box"},
          {name: "Ground Delay" ,                                type: "check_box"},
          {name: "Hangar" ,                                      type: "check_box"},
          {name: "In Service Job Location" ,                     type: "check_box"},
          {name: "In-Flight" ,                                   type: "check_box"},
          {name: "Landing Zone" ,                                type: "check_box"},
          {name: "Line" ,                                        type: "check_box"},
          {name: "Non Flight" ,                                  type: "check_box"},
          {name: "On Scene" ,                                    type: "check_box"},
          {name: "Other " ,                                      type: "text_field"},
          {name: "Paperwork Audit" ,                             type: "check_box"},
          {name: "Patrol" ,                                      type: "check_box"},
          {name: "Platform/Linework" ,                           type: "check_box"},
          {name: "PostFlight" ,                                  type: "check_box"},
          {name: "PreFlight" ,                                   type: "check_box"},
          {name: "Pushback/Tow" ,                                type: "check_box"},
          {name: "Ramp" ,                                        type: "check_box"},
          {name: "Routine Inspection" ,                          type: "check_box"},
          {name: "Saw Operations" ,                              type: "check_box"},
          {name: "Shop" ,                                        type: "check_box"},
          {name: "Taxi" ,                                        type: "check_box"},
          {name: "Wire Pull" ,                                   type: "check_box"},
          {name: "Other When Event Detected",                    type: "text_field"}
        ],
        "How Event Detected" => [
          {name: "AMT", type: "check_box"},
          {name: "ATC", type: "check_box"},
          {name: "Air Medical Crew", type: "check_box"},
          {name: "Air Ops Safety", type: "check_box"},
          {name: "Aircraft Records", type: "check_box"},
          {name: "Another Company", type: "check_box"},
          {name: "Cabin Crew", type: "check_box"},
          {name: "Centralized Load Planning", type: "check_box"},
          {name: "Changeover Crew", type: "check_box"},
          {name: "Check Loadmaster", type: "check_box"},
          {name: "Chief Loadmaster Cargo", type: "check_box"},
          {name: "Company Self Disclosure", type: "check_box"},
          {name: "Customer Service Representatives", type: "check_box"},
          {name: "Departure Coordinator", type: "check_box"},
          {name: "Departure Station Personnel", type: "check_box"},
          {name: "Dispatch", type: "check_box"},
          {name: "Duty Officer", type: "check_box"},
          {name: "Emergency Personnel", type: "check_box"},
          {name: "Engineering", type: "check_box"},
          {name: "FAA", type: "check_box"},
          {name: "FAA LOI - Company", type: "check_box"},
          {name: "FAA LOI - Individual", type: "check_box"},
          {name: "FBO", type: "check_box"},
          {name: "Flight Crew", type: "check_box"},
          {name: "Flight Deck Observer", type: "check_box"},
          {name: "Foreman", type: "check_box"},
          {name: "GOC Duty Manager", type: "check_box"},
          {name: "Gate/Ground Personnel", type: "check_box"},
          {name: "Ground Service Technicians", type: "check_box"},
          {name: "Lead", type: "check_box"},
          {name: "Lineman", type: "check_box"},
          {name: "Loadmaster", type: "check_box"},
          {name: "Maintenance Personnel", type: "check_box"},
          {name: "Maintenance Vendor", type: "check_box"},
          {name: "Manager", type: "check_box"},
          {name: "Operations Center/Maintenance Operations Center", type: "check_box"},
          {name: "Other Aircraft/Pilot", type: "check_box"},
          {name: "Passenger", type: "check_box"},
          {name: "Quality Assurance", type: "check_box"},
          {name: "Quality Control", type: "check_box"},
          {name: "Regulatory Agency ", :type=>"select",:options=>['']},
          {name: "Regulatory Compliance", type: "check_box"},
          {name: "Safety", type: "check_box"},
          {name: "Self Awareness/Scan", type: "check_box"},
          {name: "Sole Source/Individual", type: "check_box"},
          {name: "Supervisor", type: "check_box"},
          {name: "TSA", type: "check_box"},
          {name: "Training/Standards", type: "check_box"},
          {name: "Unknown", type: "check_box"},
          {name: "Other (Detector)", type: "text_field"},
          {name: "Other Identification", type: "text_field"}
        ],
        "Narrative" => [
          {name: "Narrative", type: 'text_area'}
        ],
        "When Event Detected" => [
          {name: 'When Event Detected', type: 'check_box'},
          {name: 'Aircraft Cleaning', type: 'check_box'},
          {name: 'Aircraft De-Ice', type: 'check_box'},
          {name: 'At Receiving Facility', type: 'check_box'},
          {name: 'At Sending Facility', type: 'check_box'},
          {name: 'Boarding', type: 'check_box'},
          {name: 'Cabin Phases  ', type: 'select', options: ['boarding', 'departure', 'gate arrival', 'deplanning', 'pre-flight', 'non-flight', 'in-flight']},
          {name: 'Departure', type: 'check_box'},
          {name: 'Deplaning', type: 'check_box'},
          {name: 'During Transfer', type: 'check_box'},
          {name: 'Gate Arrival', type: 'check_box'},
          {name: 'Ground Delay', type: 'check_box'},
          {name: 'Hangar', type: 'check_box'},
          {name: 'In-Flight', type: 'check_box'},
          {name: 'Landing Zone', type: 'check_box'},
          {name: 'Line', type: 'check_box'},
          {name: 'Non Flight', type: 'check_box'},
          {name: 'On Scene', type: 'check_box'},
          {name: 'Other', type: 'text_field'},
          {name: 'Paperwork Audit', type: 'check_box'},
          {name: 'PostFlight', type: 'check_box'},
          {name: 'Pre-Departure', type: 'check_box'},
          {name: 'PreFlight', type: 'check_box'},
          {name: 'Pushback/Tow', type: 'check_box'},
          {name: 'Ramp', type: 'check_box'},
          {name: 'Routine Inspection', type: 'check_box'},
          {name: 'Shop', type: 'check_box'},
          {name: 'Taxi', type: 'check_box'},
          {name: 'Taxi in', type: 'check_box'},
          {name: 'Taxi out', type: 'check_box'},
          {name: 'While Aircraft was in Service at Gate', type: 'check_box'},
          {name: 'Other When Event Detected', type: 'text_field'}
        ]
    }).sort.to_h
  end
end