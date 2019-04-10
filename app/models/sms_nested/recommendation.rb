class Recommendation < ActiveRecord::Base

	belongs_to :responsible_user,    foreign_key: 'responsible_user_id', class_name: 'User'
	belongs_to :approver,            foreign_key: 'approver_id',         class_name: 'User'
  belongs_to :created_by,          foreign_key: 'created_by_id',       class_name: 'User'

	has_many :transactions, foreign_key: 'owner_id', class_name: 'RecommendationTransaction', dependent: :destroy
	has_many :attachments, 	foreign_key: 'owner_id', class_name: 'RecommendationAttachment', 	dependent: :destroy
	has_many :descriptions, foreign_key: 'owner_id', class_name: 'RecommendationDescription', dependent: :destroy
	has_many :notices, 			foreign_key: 'owner_id', class_name: 'RecommendationNotice', 			dependent: :destroy

	accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank? && attachment[:_destroy].blank?)}

	after_create :create_recommendation_transaction
	before_create :set_priveleges

	serialize :privileges

	extend AnalyticsFilters

	def self.get_meta_fields(*args)
		visible_fields = (args.empty? ? ['index', 'form',	'show'] : args)
		[
			{ field: 'id', 							        			title: 'ID', 													 		 	num_cols: 6, 	type: 'text', 				visible: 'index,show', 			required: false},
			{ field: 'status', 												title: 'Status',														num_cols: 6, 	type: 'text',					visible: 'index,show',			required: false},
			{ field: 'title', 						        		title: 'Title', 											 		 	num_cols: 6, 	type: 'text', 				visible: 'index,form,show', required: true},
			{ field: 'get_source',										title: 'Source of Input',										num_cols: 6,	type: 'text',					visible: 'index,show',			required: false},
			{ type: 'newline', 			visible: 'show'},
			{ field: 'response_date',									title: 'Scheduled Response Date',						num_cols: 6,	type: 'date',					visible: 'index,form,show',	required: true},
			{ type: 'newline', 			visible: 'show'},
			{ field: 'responsible_user_id',						title: 'Responsible User',									num_cols: 6,	type: 'user',					visible: 'index,form,show',	required: false},
			{ field: 'approver_id',										title: 'Final Approver',										num_cols: 6,	type: 'user',					visible: 'form,show',				required: false},
			{ type: 'newline', 			visible: 'form,show'},
			{ field: 'department',										title: 'Responsible Department',						num_cols: 6,	type: 'select',				visible: 'index,form,show',	required: false,  options: get_custom_options('Departments')},
			{ type: 'newline', 			visible: 'form,show'},
			{ field: 'immediate_action',							title: 'Immediate Action Required',					num_cols: 6,	type: 'boolean_box',	visible: 'form,show',				required: false},
			{ type: 'newline', 			visible: 'form'},
			{ field: 'recommended_action',						title: 'Action',														num_cols: 6,	type: 'datalist',			visible: 'index,form,show',	required: false,  options: get_custom_options('Actions Taken')},
			{ field: 'description',										title: 'Description of Recommendation',			num_cols: 12, type: 'textarea',			visible: 'form,show',				required: false},
			{ field: 'recommendations_comment',				title: 'Recommendation Comment',						num_cols: 12, type: 'textarea',			visible: 'form,show',				required: false},
			{ field: 'final_comment',									title: 'Final Comment',											num_cols: 12, type: 'textarea',			visible: 'show',						required: false},
		].select{|f| (f[:visible].split(',') & visible_fields).any?}
	end



	def get_source
		"<b style='color:grey'>N/A</b>".html_safe
	end


	def self.progress
		{
			"New"								=> { :score => 25, 	:color => "default"},
			"Assigned"					=> { :score => 50,	:color => "warning"},
			"Pending Approval"	=> { :score => 75,	:color => "warning"},
			"Completed"					=> { :score => 100,	:color => "success"},
		}
	end


	def get_privileges
		self.privileges || [] rescue []
	end



	def self.get_custom_options(title)
		CustomOption
			.where(:title => title)
			.first
			.options
			.split(';') rescue ['Please go to Custom Options to add options.']
	end


	def set_priveleges
		if self.privileges.blank?
			self.privileges = []
		end
	end


	def create_transaction(action)
		RecommendationTransaction.create(
			:users_id => session[:user_id],
			:action => action,
			:owner_id => self.id,
			:stamp => Time.now
		)
	end


	def create_recommendation_transaction
		RecommendationTransaction.create(
			:users_id => session[:user_id],
			:action => "Create",
			:owner_id => self.id,
			:stamp => Time.now
		)
		if self.type == "FindingRecommendation"
			FindingTransaction.create(
				:users_id => session[:user_id],
				:action => "Add Recommendation",
				:content => "##{self.get_id} #{self.title}",
				:owner_id => self.finding.id,
				:stamp => Time.now
			)
		else
			InvestigationTransaction.create(
				:users_id => session[:user_id],
				:action => "Add Recommendation",
				:content => "##{self.get_id} #{self.title}",
				:owner_id => self.investigation.id,
				:stamp => Time.now
			)
		end
	end



	def get_id
		if self.custom_id.present?
			self.custom_id
		else
			self.id
		end
	end



	def can_assign?
		self.immediate_action || self.owner.status == 'Completed'
	end

	def can_complete?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
		(current_user_id == self.responsible_user.id rescue false) ||
      current_user.admin? ||
      current_user.has_access('recommendations','admin')
	end

	def can_approve?(current_user)
    current_user_id = session[:simulated_id] || session[:user_id]
		(current_user_id == self.approver rescue true) ||
      current_user.admin? ||
      current_user.has_access('recommendations','admin')
	end

  def can_reopen?(current_user)
    BaseConfig.airline[:allow_reopen_report] && (
      current_user.admin? ||
      current_user.has_access('recommendations','admin'))
  end

	def get_responsible_user_name
		self.responsible_user.full_name rescue ''
	end

	def get_response_date
		self.response_date.strftime("%Y-%m-%d") rescue ''
	end


	def self.get_terms
		{
			"Title" => "title",
			"Status" => "status",
			"Responsible User" => "get_responsible_user_name",
			"Scheduled Response Date" => "get_response_date",
			"Description of Recommendation" => "description",
			"Responsible Department" => "department",
			"Immediate Action (Yes/No)" => "get_immediate_action",
			"Action" => "recommended_action"
		}.sort.to_h
	end


	def get_immediate_action
		immediate_action ? "Yes" : "No"
	end


	def overdue
		self.response_date < Time.now.to_date && self.status != "Completed" rescue false
	end


	def self.get_avg_complete
		candidates = self.where("status = ? and complete_date is not ? and open_date is not ? ", "Completed", nil, nil)
		if candidates.present?
			sum = 0
			candidates.map{|x| sum += (x.complete_date - x.open_date).to_i}
			result = (sum.to_f / candidates.length.to_f).round(1)
			result
		else
			"N/A"
		end
	end
end
