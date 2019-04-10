class ExtensionRequest < ActiveRecord::Base

	belongs_to :requester, foreign_key: 'requester_id', class_name: 'User'
	belongs_to :approver, foreign_key: 'approver_id', class_name: 'User'


	def self.get_meta_fields(*args)
		visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
		[
			{field: 'request_date', 		title: 'Date Requested', 	num_cols: 6, 	type: 'date', 		visible: 'index,show', 					required: true},
			{field: 'requester_id', 		title: 'Requested By', 		num_cols: 6, 	type: 'user', 		visible: 'index,show', 					required: true},
			{field: 'detail', 					title: 'Request Detail', 	num_cols: 12, type: 'textarea', visible: 'index,form,show', 		required: true},
			{field: 'status', 					title: 'Status', 					num_cols: 6, 	type: 'select', 	visible: 'index,show,address', 	required: false, options: get_result_options},
			#{field: 'approver_id', 		title: 'Addressed By', 		num_cols: 6, 	type: 'user', 		visible: 'index,show', 					required: true},
			{field: 'address_date', 		title: 'Date Addressed', 	num_cols: 6, 	type: 'date', 		visible: 'index,show', 					required: false},
			{field: 'address_comment', 	title: 'Comment', 				num_cols: 12, type: 'textarea', visible: 'index,show,address', 	required: false},
		].select{|f| (f[:visible].split(',') & visible_fields).any?}
	end



	def self.get_result_options
		["New", "Approved", "Rejected"]
	end


end