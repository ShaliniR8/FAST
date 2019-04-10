class Notification < ActiveRecord::Base

	after_create :create_transaction

	def self.get_meta_fields(*args)
		visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
		[
			{field: 'notify_date', 	title: 'Notify Date', 					num_cols: 6, 	type: 'date', visible: 'index,form,show', required: true},
			{field: 'message', 			title: 'Notification Message', 	num_cols: 12, type: 'text', visible: 'index,form,show', required: true},
		].select{|f| (f[:visible].split(',') & visible_fields).any?}
	end




end