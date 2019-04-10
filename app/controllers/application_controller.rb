# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base

	include ControllerAuthentication
	include ApplicationHelper

	before_filter :access_validation
	before_filter :send_session
	before_filter :adjust_session
	skip_before_filter :authenticate_user! #Kaushik Mahorker OAuth


	helper :all # include all helpers, all the time
	protect_from_forgery # See ActionController::RequestForgeryProtection for details

	# Scrub sensitive parameters from your log
	# filter_parameter_logging :password
	def access_validation
		Rails.logger.debug("Action #{action_name}, Controller #{controller_name}")

		if !session[:last_active].present?
			session[:last_active] = Time.now
		elsif (Time.now - session[:last_active])/60 > 100
			 redirect_to logout_path
		else
			session[:last_active] = Time.now
		end

		if current_user.blank?
		else
			if !current_user.has_access(controller_name,action_name)
				redirect_to errors_path
			elsif current_user.disable
				redirect_to logout_path
			end
		end
	end




	def get_message_link(link_type, link_id)
		if link_type.present?
			@items = Object.const_get(link_type)
			@item = @items.find(:all).select{|x| x.id == link_id}
			if @item.present?
			case link_type
			when "Audit"
				audit_path(link_id)
			when "CorrectiveAction"
				corrective_action_path(link_id)
			when "Evaluation"
				evaluation_path(link_id)
			when "Finding"
				finding_path(link_id)
			when "Hazard"
				hazard_path(link_id)
			when "Im"
				im_path(link_id)
			when "Inspection"
				inspection_path(link_id)
			when "Investigation"
				investigation_path(link_id)
			when "Package"
				package_path(link_id)
			when "Recommendation"
				recommendation_path(link_id)
			when "Record"
				record_path(link_id)
			when "Report"
				report_path(link_id)
			when "RiskControl"
				risk_control_path(link_id)
			when "SafetyPlan"
				safety_plan_path(link_id)
			when "SmsAction"
				sms_action_path(link_id)
			when "Sra"
				sra_path(link_id)
			when "Submission"
				submission_path(link_id)
			else
				nil
			end

			else
				nil
			end
		end
	end



	# def display_in_table(report)
	#   if report.privileges.present?
	#     current_user.privileges.each do |p|
	#       if report.get_privileges.include? p.id.to_s
	#         return true
	#       end
	#     end
	#     return false
	#   else
	#     return true
	#   end
	# end

	def keep_privileges(privilege, type)
		rule = AccessControl.where("action=? and entry=?", 'index', type)
		if rule.present?
			access = rule.first
			all_access = privilege.access_controls
			(access.list_type && (all_access.include? access))||(!access.list_type && !(all_access.include? access))
		else
			true
		end
	end



	def display_asapcar(car)
		if car.report.present?
			return display_in_table(car.report)
		else
			return true
		end
	end



	def display_in_table(report)
		if current_user.level == "Admin"
			return true
		elsif report.privileges.present?
			current_user.privileges.each do |p|
				if report.get_privileges.include? p.id.to_s
					return true
				end
			end
			return false
		else
			return true
		end
	end

	def get_finding_owner(finding)
		if finding.type == "AuditFinding"
			return 'audits'
		elsif finding.type == "InspectionFinding"
			return 'inspections'
		elsif finding.type == "EvaluationFinding"
			return 'evaluations'
		elsif finding.type == "InvestigationFinding"
			return 'investigations'
		end
	end

	def get_car_owner(car)
		if car.type == "FindingAction"
			return get_finding_owner(car.finding)
		elsif car.type == "InvestigationAction"
			return 'investigations'
		end
	end

	def get_recommendation_owner(rec)
		if rec.type == "FindingRecommendation"
			return get_finding_owner(rec.finding)
		elsif rec.type == "InvestigationRecommendation"
			return 'investigations'
		end
	end

	def display_finding(finding)
		if finding.type == "AuditFinding"
			return current_user.has_access("audits", "index")
		elsif finding.type == "InspectionFinding"
			return current_user.has_access("inspections", "index")
		elsif finding.type == "EvaluationFinding"
			return current_user.has_access("evaluations", "index")
		elsif finding.type == "InvestigationFinding"
			return current_user.has_access("investigations", "index")
		else
			return true
		end
	end

	def display_car(car)
		if car.type == "FindingAction"
			return display_finding(car.finding)
		elsif car.type == "InvestigationAction"
			return current_user.has_access("investigations", "index")
		else
			return true
		end
	end

	def display_recommendation(rec)
		if rec.type == "FindingRecommendation"
			return display_finding(rec.finding)
		elsif rec.type == "InvestigationRecommendation"
			return current_user.has_access("investigations", "index")
		else
			return true
		end
	end


	def submission_display(report)
		true
		# if (current_user.has_template_access(report.template.name).include? "full") || (current_user == report.created_by) || (current_user.has_template_access(report.template.name).include? "viewer")
		# 	return true
		# else
		# 	return false
		# end
	end

	def record_display(report)
		true
		# if (current_user.has_template_access(report.template.name).include? "full") || (current_user == report.created_by) || ((current_user.has_template_access(report.template.name).include? "viewer") && report.viewer_access)
		# 	return true
		# else
		# 	return false
		# end
	end

	def adjust_session
		load_controller_list


		if @sms_list.include? controller_name
			session[:mode]='SMS'
		elsif @sms_im_list.include? controller_name
			session[:mode]='SMS IM'
		elsif @asap_list.include? controller_name
			session[:mode]='ASAP'
		elsif @srm_list.include? controller_name
			session[:mode]='SRM'
		end
		true
	end
	def get_classes_by_module
		case session[:mode]
		when 'SMS'
			['Audit','Evaluation','Inspection','Investigation','Finding','Recommendation']
		when 'ASAP'
			{'Submission'=>"Submission",'Report'=>"Record"}
		when 'SRM'
			{'SRM/SRA'=>"Sra",'Hazard'=>'Hazard'}
		else
			[]
		end
	end


	def get_fields_by_class
		case session[:mode]
		when 'SMS'
			{
				'Audit'=>{
					"Department"=>"department",
					"Audit Type"=>"audit_type",
					'Location'=>"location",
					'Vendor'=>'vendor',
					'Audit Department'=>'audit_department',
					'Process'=>'process',
					'Supplier'=>'supplier',
					'Status'=>'status'
				},
				'Evaluation'=>{
					"Department"=>"department",
					"Audit Type"=>"evaluation_type",
					'Location'=>"location",
					'Vendor'=>'vendor',
					'Evaluation Department'=>'evaluation_department',
					'Process'=>'process',
					'Supplier'=>'supplier',
					'Status'=>'status'
				},
				'Inspection'=>{
					"Department"=>"department",
					"Inspection Type"=>"inspection_type",
					'Location'=>"location",
					'Vendor'=>'vendor',
					'Inspection Department'=>'inspection_department',
					'Process'=>'process',
					'Supplier'=>'supplier',
					'Status'=>'status'
				},
				'Investigation'=>{
					'Investigation Type'=>"inv_type",
					'Source'=>'source',
					'NTSB'=>'ntsb',
					'Safety Hazard'=>'safety_hazard',
					'Likelihood(Baseline)'=>"likelihood",
					'Severity(Baseline)'=>"severity",
					'Risk Factor(Baseline)'=>"risk_factor",
					"Likelihood(Mitigated)"=>"likelihood_after",
					"Severity(Mitigated)"=>"severity_after",
					"Risk Factor(Mitigated)"=>"risk_factor_after",
					'Status'=>'status'
				},
				'Finding'=>{
					'Regulatory Violation'=>"regulatory_violation",
					'Policy Violation'=>"policy_violation",
					'Safety'=>"safety",
					'Classification'=>"classification",
					'Repeat'=>'repeat',
					"Immediate Action"=>"immediate_action",
					"Department"=>'department',
					"Authority"=>'authority',
					"Controls"=>"controls",
					"Interfaces"=>'interfaces',
					"Policy"=>"policy",
					"Procedures"=>"procedures",
					"Process Measures"=>"process_measures",
					"Responsibility"=>"responsibility",
					'Likelihood(Baseline)'=>"likelihood",
					'Severity(Baseline)'=>"severity",
					'Risk Factor(Baseline)'=>"risk_factor",
					"Likelihood(Mitigated)"=>"likelihood_after",
					"Severity(Mitigated)"=>"severity_after",
					"Risk Factor(Mitigated)"=>"risk_factor_after",
					"Status"=>"status"
				},
				'Recommendation'=>{
					'Status'=>"status",
					'Department'=>'department',
					"Immediate Action"=>'immediate_action',
					"Recommended Action"=>"recommended_action"
				}
			}
		when 'SRM'
			{
				'Sra'=>{
					'Type of Change'=>"type_of_change",
					'Likelihood(Baseline)'=>"likelihood",
					'Severity(Baseline)'=>"severity",
					'Risk Factor(Baseline)'=>"risk_factor",
					"Likelihood(Mitigated)"=>"likelihood_after",
					"Severity(Mitigated)"=>"severity_after",
					"Risk Factor(Mitigated)"=>"risk_factor_after"
				},
				'Hazard'=>{
					'Likelihood(Baseline)'=>"likelihood",
					'Severity(Baseline)'=>"severity",
					'Risk Factor(Baseline)'=>"risk_factor",
					"Likelihood(Mitigated)"=>"likelihood_after",
					"Severity(Mitigated)"=>"severity_after",
					"Risk Factor(Mitigated)"=>"risk_factor_after",
					"Status"=>"status"
				}
			}
		else
			[]
		end


	end



	# Deals with Advanced Search for different types of reports, such as Events, Corrective Actions, Audits, SRAs, etc
	def handle_search

		@records = @table.within_timerange(params[:start_date], params[:end_date])
		if params[:type].present?
			@records = @records.select{|x| x.type == params[:type]}
		end
		if params[:status].present?
			if params[:status] == "Overdue"
				@records = @records.select{|x| x.overdue}
			else
				@records = @records.select{|x| x.status == params[:status]}
			end
		end

		if params[:advance_search].present?
			if params[:searchterm_1].present?
				if params[:field_1].present?
					field = @terms.select{|header| header[:field] == params[:searchterm_1]}.first
					if field[:type] == 'user'
						params[:field_1] = User.where('full_name LIKE ?', '%' + params[:field_1] + '%').map{|x| x.id}
						@records.keep_if{|r| params[:field_1].include? r.send(params[:searchterm_1])}
					elsif field[:type] == 'boolean_box'
						@records.keep_if{|r| (r.send(params[:searchterm_1]) ? 'yes' : 'no') == params[:field_1].downcase}
					else
						@records.keep_if{|r| r.send(params[:searchterm_1]).to_s.downcase.include? params[:field_1].downcase}
					end
				elsif params[:start_date_1].present? && params[:end_date_1].present?
					start_date = params[:start_date_1].to_date
					end_date = params[:end_date_1].to_date
					@records.keep_if {|r| r.send(params[:searchterm_1]).between?(start_date, end_date) rescue false}
				end
			end
			if params[:searchterm_2].present?
				if params[:field_2].present?
					field = @terms.select{|header| header[:field] == params[:searchterm_2]}.first
					if field[:type] == 'user'
						params[:field_2] = User.where('full_name LIKE ?', '%' + params[:field_2] + '%').map{|x| x.id}
						@records.keep_if{|r| params[:field_2].include? r.send(params[:searchterm_2])}
					else
						@records.keep_if{|r| r.send(params[:searchterm_2]).to_s.downcase.include? params[:field_2].downcase}
					end
				elsif params[:start_date_2].present? && params[:end_date_2].present?
					start_date = params[:start_date_2].to_date
					end_date = params[:end_date_2].to_date
					@records.keep_if {|r| r.send(params[:searchterm_2]).between?(start_date, end_date) rescue false}
				end
			end

			if params[:searchterm_3].present?
				if params[:field_3].present?
					field = @terms.select{|header| header[:field] == params[:searchterm_3]}.first
					if field[:type] == 'user'
						params[:field_3] = User.where('full_name LIKE ?', '%' + params[:field_3] + '%').map{|x| x.id}
						@records.keep_if{|r| params[:field_3].include? r.send(params[:searchterm_3])}
					else
						@records.keep_if{|r| r.send(params[:searchterm_3]).to_s.downcase.include? params[:field_3].downcase}
					end
				elsif params[:start_date_3].present? && params[:end_date_3].present?
					start_date = params[:start_date_3].to_date
					end_date = params[:end_date_3].to_date
					@records.keep_if {|r| r.send(params[:searchterm_3]).between?(start_date, end_date) rescue false}
				end
			end

			if params[:searchterm_4].present?
				if params[:field_4].present?
					field = @terms.select{|header| header[:field] == params[:searchterm_4]}.first
					if field[:type] == 'user'
						params[:field_4] = User.where('full_name LIKE ?', '%' + params[:field_4] + '%').map{|x| x.id}
						@records.keep_if{|r| params[:field_4].include? r.send(params[:searchterm_4])}
					else
						@records.keep_if{|r| r.send(params[:searchterm_4]).to_s.downcase.include? params[:field_4].downcase}
					end
				elsif params[:start_date_4].present? && params[:end_date_4].present?
					start_date = params[:start_date_4].to_date
					end_date = params[:end_date_4].to_date
					@records.keep_if {|r| r.send(params[:searchterm_4]).between?(start_date, end_date) rescue false}
				end
			end
		end
	end




	def load_controller_list
		@sms_list=['sms_actions','findings','audits','inspections','recommendations','investigations','evaluations']
		@sms_im_list=['ims']
		@asap_list=['reports','records','corrective_actions','trackings','faa_reports','templates','fields']
		@srm_list=['sras','hazards','risk_controls','safety_plans']
	end

	def send_session
		accessor = instance_variable_get(:@_request)
		ActiveRecord::Base.send(:define_method, "session", proc {accessor.session})
	end
	# Find the admin user for an airport using its code (case insensitive)
	#
	# Ex: airport_admin("SMX") => #<User username: "prodigiq_smx_admin", module_access: "...">
	def airport_admin(code)
		User.find_by_username("prodigiq_#{code.downcase}_admin")
	end
	# Boolean indicating whether or not an airport can access a specific module
	#
	# Ex: airport_has_access?("SMX", "maint") => true
	# def airport_has_access?(code, module_name)
	#   airport_admin(code).module_access.include?(module_name)
	# end

	# Find the admin user for the current user's airport
	def current_airport_admin
		@current_admin ||= airport_admin(current_user.airport)
	end



	# Reopen a report (applicable to Audits, Inspections, Evaluation, Investigations, Findings, Sms_actions, Recommendations )
	def reopen_report(owner)
		owner_class = owner.class.name
		owner.status = "New"
		owner.save
		case owner_class
		when "Audit"
			AuditTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to audit_path(owner)
		when "Inspection"
			InspectionTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to inspection_path(owner)
		when "Evaluation"
			EvaluationTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to evaluation_path(owner)
		when "Investigation"
			InvestigationTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to investigation_path(owner)
		when "Finding"
			FindingTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to finding_path(owner)
		when "SmsAction"
			SmsActionTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to sms_action_path(owner)
		when "Recommendation"
			RecommendationTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to recommendation_path(owner)
		when "Sra"
			SraTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to sra_path(owner)
		when "Hazard"
			HazardTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to hazard_path(owner)
		when "RiskControl"
			RiskControlTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to risk_control_path(owner)
		when "SafetyPlan"
			SafetyPlanTransaction.create(:users_id=>current_user.id, :action=>"Reopen", :owner_id=>owner.id, :stamp=>Time.now)
			redirect_to safety_plan_path(owner)
		else
			return
		end
	end




	def notify(user, message, mailer=false, subject=nil)
		if user.present?
			notice = Notice.create({
				:user => user,
				:content => message})
			if mailer
				NotifyMailer.notify(user, message, subject)
			end
		end
	end








	def denotify(user,owner,action)
		if user.present?
			owner.notices.where('users_id = ? and action = ?', user.id, action).each(&:destroy)
		end
	end
	helper_method :airport_admin, :airport_has_access?, :current_airport_admin




	private


end
