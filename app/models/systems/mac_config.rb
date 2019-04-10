class MAC_Config

	FAA_INFO = {
		"CHDO"=>"ACE-FSDO-09",
		"Region"=>"Central",
		"ASAP MOU Holder Name"=>"Boeing",
		"ASAP MOU Holder FAA Designator"=>"BASE"
	}



	MATRIX_INFO = {
		severity_table: {
			starting_space: true,
			column_header: ['4','3','2','1'],
			row_header: ['Accident or Incident', 'Injury /Illness /Fatigue', 'Operational Event', 'Airworthiness', 'System or Processes','Regulatory Procedural'],

			rows: [
				[
					'Accident with serious injuries or significant damage to aircraft, equipment or resources.', 
					'Serious incident with injuries and/or substantial damage to aircraft, equipment or resources.',
					'Incident with minor injury and/ or minor damage to aircraft, equipment or resources.',
					'Incident with less than minor injury and/ or less than minor system damage.',
				],
				[
					'Death, total disability of an employee. Extreme illness and/or hospitalization. Chronic Fatigue (6+ months).',
					'Partial disability, temporary disability > 3 mo. of an employee. Major illness, hospitalization. Prolonged fatigue (1-6 months).',
					'Lost workday(s) injury of an employee. Moderate illness. Moderate temporary fatigue (< 1 month).',
					'Any minor injury to employee. Minor illness. Minor temporary fatigue (< 1 week).',
				],
				[
					'State of emergency for an operational condition, impacting the immediate safe operation of an aircraft. (i.e. declared emergency, immediate air interrupt, high speed abort)',
					'Condition resulting in abnormal procedures, impacting the continued safe operation of an aircraft. (i.e. special handling without declared emergency, enroute diversion, low speed abort)',
					'Condition resulting in abnormal procedures with potential to impact safe operation of an aircraft. (i.e. battery charger failure, single source of electrical power, slat disagree)',
					'Condition resulting in normal procedures with potential to impact safe operation of an aircraft (i.e. false indications)',
				],
				[
					'Returning an aircraft to service and operating in it a non-standard, unairworthy, or unsafe condition.',
					'Returning an aircraft to service and operating it in a non-standard or unairworthy but not unsafe condition.',
					'Returning an aircraft to service in a non-standard unairworthy or unsafe condition, not operated.',
					'Affecting aircraft or systems reliability above established control limits but no effect on airworthiness or safety of operation of an aircraft.',
				],
				[
					'Loss or breakdown of entire system, subsystem or process.',
					'Partial breakdown of a system, subsystem, or process.',
					'System deficiencies leading to poor dependability or disruption.',
					'Slight effect on system, subsystem or process.',
				],
				[
					'Major regulatory deviation (intentional disregard).',
					'Moderate regulatory deviation (unintentional and/ or no procedures).',
					'Non-compliance w/ company procedures (intentional disregard).',
					'Non-compliance w/company procedures (unintentional).',
				]
			]
		},

		severity_table_dict: {
			0 => "4",
			1 => "3",
			2 => "2",
			3 => "1",
		},

		probability_table: {
			starting_space: true,
			row_header: ['A / Frequent', 'B / Probable', 'C / Occasional', 'D / Remote'],
			column_header: ['Specific or Individual', 'Fleet or System', 'Finding or Audit'],
			
			rows: [
				[
					'Likely to occur often in the life of an item, with a probability of occurrence 51-100% of the time',
					'Continuously experienced; likely to occur more than once a month.',
					'Will occur frequently in the life of a system, possible to occur monthly.',
				],
				[
					'Will occur several times in the life of an item, with a probability of occurrence 25-50% of the time.',
					'Will occur frequently in the life of a system, possible to occur monthly.',
					'Finding, without multiple occurrences during audit, and with repetitive finding on previous audit.',
				],
				[
					'Likely to occur sometime in the life of an item, with a probability of occurrence 11-25% of the time.',
					'Will occur several times in the life of a system, possible to occur two to four times a year.',
					'Finding, with multiple occurrences during audit, and without repetitive finding on previous audit, or no prior audit conducted.',
				],
				[
					'Unlikely but possible to occur in the life of an item, with a probability of occurrence up to 10% of the time.',
					'Unlikely, but can reasonably be expected to occur. Likely to occur once a year or less.',
					'Finding, without multiple occurrences during audit, and without repetitive finding on previous audit, or no prior audit conducted (i.e. one time occurrence).',
				],
			]
		},

		probability_table_dict: {
			0 => 'A/Frequent',
			1 => 'B/Probable',
			2 => 'C/Occasional',
			3 => 'D/Remote',
		},

		risk_table: {
			starting_space: true,
			row_header: ['4','3','2','1'],
			column_header: ['FREQUENT - A','PROBABLE - B','OCCASIONAL - C','REMOTE - D'],
			rows: [
				['crimson',     'crimson',      		'coral',   						'gold'							],
				['crimson',     'coral',   					'gold',   						'skyblue'						],
				['coral',  			'gold',   					'skyblue',     				'mediumseagreen'		],
				['gold',  			'skyblue',     			'mediumseagreen',    	'mediumseagreen'		],
			]
		},


		# TODO for TJ 5/5 - fill in descriptions
		risk_table_dict: {
			crimson: 				"Red (A4, A3, and B4) - High Risk Imminent Danger: Unacceptable, requires the highest priority for investigation, resources and corrective action.",
			coral: 					"Orange (A2, B3, and C4) - Serious Risk: Unacceptable, without immediate interim corrective action, requires investigation, resources and corrective action. There are no acceptable policies and procedures in place to manage the risk.",
			gold: 					"Yellow (A1, B2, C3, and D4) - Moderate Risk: May be acceptable with review by appropriate authority, requires tracking and probable action. There may be acceptable policies and procedures in place.",
			skyblue: 				"Blue (B1, C2, and D3) - Minor Risk: May be acceptable with review by appropriate authority. May require tracking and probable action. There may be acceptable policies and procedures in place.  ",
			mediumseagreen: "Green (C1, D2, and D1) - Low Risk: May be acceptable without further action."
		},

		risk_table_index: {
			crimson:        "HIGH",
			coral:     			"SERIOUS",
			gold:     			"MODERATE",
			skyblue: 				"MINOR",
			mediumseagreen: "LOW"
		},

		risk_definitions: {
			crimson: 					{rating: "HIGH", 			cells: "A4, A3, B4", 			description: "Unacceptable, requires the highest priority for investigation, resources and corrective action." },
			coral: 						{rating: "SERIOUS", 	cells: "A2, B2, C4", 			description: "Unacceptable, without immediate interim corrective action, requires investigation, resources and corrective action. There are no acceptable policies and procedures in place to manage the risk."},
			gold: 						{rating: "MODERATE", 	cells: "A1, B2, C3, D4", 	description: "May be acceptable with review by appropriate authority, requires tracking and probable action. There may be acceptable policies and procedures in place."},
			skyblue: 					{rating: "MINOR", 		cells: "B1, C2, D3", 			description: "May be acceptable with review by appropriate authority. May require tracking and probable action. There may be acceptable policies and procedures in place."},
			mediumseagreen: 	{rating: "LOW", 			cells: "C1, D2, D1", 			description: "May be acceptable without further action."}
		}
	}

	# Calculate the severity based on #{BaseConfig.airline[:code]}'s risk matrix
	def self.calculate_severity(list)
		if list.present?
			list.delete("undefined") # remove "undefined" element from javascript
			return list.map(&:to_i).min
		end
	end

	# Calculate the probability based on #{BaseConfig.airline[:code]}'s risk matrix
	def self.calculate_probability(list)
		if list.present?
			list.delete("undefined") # remove "undefined" element from javascript
			return list.map(&:to_i).min
		end
	end

	def self.print_severity(owner, severity_score)
		MATRIX_INFO[:severity_table_dict][severity_score] unless severity_score.nil?
	end

	def self.print_probability(owner, probability_score)
		MATRIX_INFO[:probability_table_dict][probability_score] unless probability_score.nil?
	end

	def self.print_risk(probability_score, severity_score) 
		if !probability_score.nil? && !severity_score.nil?
			lookup_table = MATRIX_INFO[:risk_table][:rows]
			return MATRIX_INFO[:risk_table_index][lookup_table[severity_score][probability_score].to_sym]
		end
	end

end