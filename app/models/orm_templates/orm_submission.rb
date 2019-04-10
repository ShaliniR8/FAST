class OrmSubmission < ActiveRecord::Base
	belongs_to 	:orm_template, 						:foreign_key => "orm_template_id", 		:class_name => "OrmTemplate"
	belongs_to 	:user, 										:foreign_key => "user_id",						:class_name => "User"
	has_many 		:orm_submission_fields, 	:foreign_key => "orm_submission_id",	:class_name => "OrmSubmissionField", :dependent => :destroy

	accepts_nested_attributes_for :orm_submission_fields

	def self.get_headers
		[
			{:field => "id",									:title => "ID"},
			{:field => "total_score",					:title => "Total Score"},
			{:field => "template_name",				:title => "ORM Type"},
			{:field => "tail_number",					:title => "Tail Number"},
			{:field => "submitted_by", 				:title => "Submitted By"},
			{:field => "submitted_at", 				:title => "Submitted At"},
		]
	end

	def template_name
		orm_template.name
	end

	def submitted_by
		user.full_name
	end

	def submitted_at
		created_at.strftime("%Y-%m-%d")
	end

	def self.build(orm_template)
		record = self.new
		record.orm_template_id = orm_template.id
		record
	end


end