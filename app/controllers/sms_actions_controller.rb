# Current version of Ruby (2.1.1p76) and Rails (3.0.5) defines send s.t. saving nested attributes does not work
# This method is a "monkey patch" that can fix the issue (tested for Rails 3.0.x)
# Source: https://github.com/rails/rails/issues/11026
if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
	module ActiveRecord
		module Associations
			class AssociationProxy
				def send(method, *args)
					if proxy_respond_to?(method, true)
						super
					else
						load_target
						@target.send(method, *args)
					end
				end
			end
		end
	end
end

class SmsActionsController < ApplicationController

	before_filter :load_options
  before_filter(only: [:show]) { check_group('sms_action') }


	def destroy
		corrective_action = SmsAction.find(params[:id])
		corrective_action.destroy
		redirect_to sms_actions_path,
			flash: {danger: "Corrective Action ##{params[:id]} deleted."}
	end



	def new
		@table = params[:owner_type].present? ? "#{params[:owner_type]}Action" : "SmsAction"
		@owner = Object.const_get(params[:owner_type])
			.find(params[:owner_id])
			.becomes(Object.const_get(params[:owner_type])) rescue nil
		@corrective_action = Object.const_get(@table).new
		@corrective_action.open_date = Time.now
		@users = User.where(:disable => 0)
		@headers = User.get_headers
		load_options
		@fields = SmsAction.get_meta_fields('form')
		form_special_matrix(
			@corrective_action,
			"sms_action",
			"severity_extra",
			"probability_extra")
	end



	def create
		@table = params[:owner_type].present? ? "#{params[:owner_type]}Action" : "SmsAction"
		corrective_action = Object.const_get(@table).create(params[:sms_action])
		redirect_to corrective_action.becomes(SmsAction), flash: {success: "Corrective Action created."}
	end


	def index
		@table = Object.const_get("SmsAction")
		@headers = @table.get_meta_fields('index')
		@terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
		handle_search

		if !current_user.admin?
			cars = SmsAction.where('status in (?) and responsible_user_id = ?',
				['Assigned', 'Pending Approval', 'Completed'], current_user.id)
			cars += SmsAction.where('approver_id = ?',  current_user.id)
			@records = @records & cars
		end
	end


	def show
		@corrective_action = SmsAction.find(params[:id])
		load_special_matrix(@corrective_action)
		load_options
		@fields = SmsAction.get_meta_fields('show')
		@type = get_car_owner(@corrective_action) || 'sms_actions'
	end



	def edit
		@corrective_action = SmsAction.find(params[:id])
		load_options
		@fields = SmsAction.get_meta_fields('form')
		form_special_matrix(@corrective_action, "sms_action", "severity_extra", "probability_extra")
		@type = get_car_owner(@corrective_action)
		@users.keep_if{|u| u.has_access(@type, 'edit')}
	end


	def load_options
		@privileges = Privilege.find(:all)
		@users = User.find(:all)
		@users.keep_if{|u| !u.disable}
		@headers = User.get_headers
		@frequency = (0..4).to_a.reverse
		@like = Finding.get_likelihood
		risk_matrix_initializer
	end
	helper_method :load_options


	def override_status
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		render :partial => '/forms/workflow_forms/override_status'
	end

	def assign
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
	end

	def reassign
		@corrective_action = SmsAction.find(params[:id])
		render :partial => "reassign"
	end

	def complete
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		status = @owner.approver.present? ? 'Pending Approval' : 'Completed'
		render :partial => 'forms/workflow_forms/process', locals: {status: status}
	end

	def approve
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		status = params[:commit] == "approve" ? "Completed" : "Assigned"
		render :partial => '/forms/workflow_forms/process', locals: {status: status}
	end



	def update
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		case params[:commit]
		when 'Reassign'
			notify(@owner.responsible_user,
				"Corrective Action ##{car.get_id} has been reassigned to you." + g_link(car),
				true, 'Corrective Action Reassigned')
		when 'Assign'
			notify(@owner.responsible_user,
				"Corrective Action ##{@owner.id} has been assigned to you." + g_link(@owner),
				true, 'Corrective Action Assigned')
		when 'Complete'
			if @owner.approver
				notify(@owner.approver,
					"Corrective Action ##{@owner.id} needs your Approval." + g_link(@owner),
					true, 'Corrective Action Pending Approval')
			else
				@owner.complete_date = Time.now
			end
		when 'Reject'
			notify(@owner.responsible_user,
				"Corrective Action ##{@owner.id} has been Rejected by the Final Approver." + g_link(@owner),
				true, 'Corrective Action Rejected')
		when 'Approve'
			@owner.complete_date = Time.now
			notify(@owner.responsible_user,
				"Corrective Action ##{@owner.id} has been Approved by the Final Approver." + g_link(@owner),
				true, 'Corrective Action Approved')
		when 'Override Status'
			transaction_content = "Status overriden from #{@owner.status} to #{params[:sms_action][:status]}"
		end
		@owner.update_attributes(params[:sms_action])
		SmsActionTransaction.create(
				users_id:   current_user.id,
				action:     params[:commit],
				owner_id:   @owner.id,
				content: 		transaction_content,
				stamp:      Time.now
			)
		@owner.save
		redirect_to sms_action_path(@owner)
	end



	def get_term
		all_terms = SmsAction.terms
		@item = all_terms[params[:term].to_sym]
		render :partial => "corrective_actions/term"
	end


	def new_cost
		@cost = ActionCost.new
		@corrective_action = SmsAction.find(params[:id]).becomes(SmsAction)
		render :partial => "new_cost"
	end


	def new_attachment
			@owner = SmsAction.find(params[:id]).becomes(SmsAction)
			@attachment = SmsActionAttachment.new
			render :partial => "shared/attachment_modal"
	end


	def print
		@deidentified = params[:deidentified]
		@corrective_action = SmsAction.find(params[:id])
		html = render_to_string(:template => "/sms_actions/print.html.erb")
		pdf = PDFKit.new(html)
		pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
		pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
		filename = "Corrective Action##{@corrective_action.get_id}" + (@deidentified ? '(de-identified)' : '')
		send_data pdf.to_pdf, :filename => "#{filename}.pdf"
	end


	def mitigate
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		load_options
		mitigate_special_matrix("sms_action", "mitigated_severity", "mitigated_probability")
		if BaseConfig.airline[:base_risk_matrix]
			render :partial => "shared/mitigate"
		else
			render :partial => "shared/#{BaseConfig.airline[:code]}/mitigate"
		end
	end


	def baseline
		@owner = SmsAction.find(params[:id]).becomes(SmsAction)
		load_options
		form_special_matrix(@owner, "sms_action", "severity_extra", "probability_extra")
		if BaseConfig.airline[:base_risk_matrix]
			render :partial => "shared/baseline"
		else
			render :partial => "shared/#{BaseConfig.airline[:code]}/baseline"
		end
	end


	def reopen
		@sms_action = SmsAction.find(params[:id]).becomes(SmsAction)
		reopen_report(@sms_action)
	end


end
