class ChecklistRecord < ActiveRecord::Base

	def self.get_meta_fields(*args)
		visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
		return [
			{ field: "header", 				 			title: "Header?", 					num_cols: 12, type: "checkbox", 		visible: 'form', 							required: false		},
			{ field: "number", 			 				title: "Number",						num_cols: 12, type: "text", 				visible: 'index,form,show', 	required: false		},
			{ field: "question", 			 			title: "Question",					num_cols: 12, type: "textarea", 		visible: 'index,form,show', 	required: false, width: "60%"	},
			{ field: "assessment", 					title: "Assessment", 				num_cols: 12, type: "select", 			visible: 'index,form,show', 	required: false, options: get_assessment_options },
			{ field: "faa_reference", 			title: "FAA Reference", 		num_cols: 12, type: "text", 				visible: 'index,form,show', 	required: false		},
			{ field: "airline_reference", 	title: "Airline Reference", num_cols: 12, type: "text", 				visible: 'index,form,show', 	required: false		},
			{ field: "notes", 							title: "Notes", 						num_cols: 12, type: "textarea", 		visible: 'index,form,show', 	required: false		},
		].select{|f| (f[:visible].split(',') & visible_fields).any?}
	end

	def self.get_assessment_options
		["Yes", "No", "N/A"]
	end

end