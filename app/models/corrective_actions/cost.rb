class Cost < ActiveRecord::Base

	def self.get_meta_fields(*args)
		visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
		return [
			{ field: "id", 							title: "ID", 														num_cols: 6, 	type: "text", 		visible: 'index', 				required: false},
			{ field: "cost_date", 			title: "Date",													num_cols: 6, 	type: "date",			visible: 'index,form,show', 	required: false},			
			{ field: "direct_cost", 		title: "Direct Cost",										num_cols: 6, 	type: "boolean", visible: 'form,show', 				required: false},
			{ field: "indirect_cost", 	title: "Indirect Cost",									num_cols: 6, 	type: "boolean", visible: 'form,show', 				required: false},
			{ field: "work_order", 			title: "Purchase or Work Order Number",	num_cols: 6, 	type: "text",			visible: 'index,form,show', 	required: false},
			{ field: "vendor",					title: "Vendor/Supplier",								num_cols: 6, 	type: "text", 		visible: 'form,show', 				required: false},
			{ field: "amount",					title: "Amount",												num_cols: 6, 	type: "text", 		visible: 'form,show', 				required: false},
			{ field: "description", 		title: "Description",										num_cols: 12, type: "textarea",			visible: 'index,form,show', 	required: false},
			{ field: "notes", 					title: "Notes",													num_cols: 12, type: "textarea", visible: 'form,show', 				required: false},
		].select{|f| (f[:visible].split(',') & visible_fields).any?}
	end

end
