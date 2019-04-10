class User < ActiveRecord::Base
	has_many :templates,				foreign_key: 'users_id',	class_name: 'Template'
	has_many :submissions,			foreign_key: 'user_id',		class_name: 'Submission'
	has_many :notices, 					foreign_key: 'users_id',	class_name: 'Notice',				dependent: :destroy
	has_many :cc_messages, 			foreign_key: 'users_id',	class_name: 'CC',						dependent: :destroy
	has_many :inbox_messages, 	foreign_key: 'users_id',	class_name: 'SendTo',				dependent: :destroy
	has_many :sent_messages, 		foreign_key: 'users_id',	class_name: 'SendFrom',			dependent: :destroy
	has_many :invitations, 			foreign_key: 'users_id',	class_name: 'Invitation',		dependent: :destroy
	has_many :roles,						foreign_key: 'users_id',	class_name: 'Role', 				dependent: :destroy

	has_many :privileges, :through => :roles

	#Kaushik Mahorker OAuth
  has_many :client_applications
  has_many :tokens, :class_name	=> "Oauth2Token", :order => "authorized_at desc",	:include => [:client_application]



	has_many :access_levels
	accepts_nested_attributes_for :access_levels, reject_if: :all_blank, allow_destroy: true


	# new columns need to be added here to be writable through mass assignment
	attr_accessible :username, :email,
		:password,:password_salt, :password_confirmation,
		:first_name, :last_name, :level, :full_name, :airport,
		:module_access, :email_notification, :role, :airline,
		:job_title, :address, :city, :state, :zipcode, :mobile_number,
		:work_phone_number, :employee_number, :access_levels_attributes,
    :android_version



	attr_accessor :password, :reset_token
	before_save :prepare_password

	validates_presence_of :username, 		:message => " cannot be empty."
	validates_presence_of :first_name, 	:message => " cannot be empty."
	validates_presence_of :last_name, 	:message => " cannot be empty."
	validates_presence_of :email, 			:message => " cannot be empty."
	# validates_presence_of :password, :message => " cannot be empty."
	validates_uniqueness_of :username, :case_sensitive => false, :message => " has already been taken."
	validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
	validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
	#validates_uniqueness_of :email, :case_sensitive => false, :message => " has already been taken."
	# validates_presence_of :password, :on => :create
	validates_confirmation_of :password, :message => " must match."
	validates_length_of :password, :minimum => 4, :allow_blank => true, :message => " needs to be at least 4 characters long."



	def get_all_access
		result = []
		self.privileges.each do |p|
			result.concat(p.access_controls)
		end
		if !result.blank?
			result.uniq
		else
			[]
		end
	end

	def get_all_templates
		result = privileges
			.preload(:access_controls)
			.map(&:access_controls)
			.flatten
			.select{|x| x[:action] == "full" || x[:action] == "viewer"}
			.map{|x| x[:entry]}
			.uniq
	end

	def get_all_submitter_templates
		result = privileges.map(&:access_controls).flatten.select{|x| x[:action] == "full" || x[:action] == "submitter"}.map{|x| x[:entry]}.uniq
	end



	def has_template_access(template_name)
		all_access = self.get_all_access
		all_access = all_access.select{|x| x.entry==template_name}
		if all_access.present?
			all_access.map{|x| x.action}.join(';')
		else
			""
		end
	end


  def has_access(con_name, act_name)
		rule = AccessControl.where('action = ? AND entry = ?', act_name, con_name).first
		if rule.present? && privileges.present?
			(rule.privileges & privileges).size > 0
		else
			true
		end
		# if rule.present?
		# 	access = rule.first
		# 	self.get_all_access.include? access
		# else
		# 	true
		# end
	end


	def accessible_modules
		num = 0
		modules = AccessControl.where('action = ?', "module")
		all_access = get_all_access
		modules.each do |x|
			if all_access.include? x
				num = num + 1
			end
		end
		num
	end



	def privilege_ids
		if self.roles.present?
			self.roles.map{|x| x.privilege.id}
		else
			[]
		end
	end


	def self.authenticate(login, pass)
		user = find_by_username(login) || find_by_email(login)
		return user if user && user.matching_password?(pass) && !user.disable
	end


	def matching_password?(pass)
		self.password_hash == encrypt_password(pass)
	end


	def matching_email?(email_check)
		self.email == email_check
	end


	def get_invitation_status(meeting)
		inv=self.invitations.where("meetings_id = ?",meeting.id)
		if inv.present?
			inv.first.status
		else
			"Not Invited"
		end
	end


	def active_notices
		self.notices.select{|x| x.status == "Active"}
	end


	def get_access_level(report_type)
		self.access_levels.where(report_type: report_type).first.level
	end


	def self.get_headers_table
		headers_table = [
			{ field: "employee_number",				 					title: "Employee #"},
			{ field: "id", 															title: "ID"},
			{ field: "level" ,						size: "",			title: "Type"},
			{ field: "username",					size: "",			title: 'Username'},
			{ field: "full_name",					size: "",			title: 'Name'},
			{ field: "email",							size: "",			title: "Email"},
      { field: "account_status",		size: "",			title: "Account Status"}
		]
    if (BaseConfig.airline[:has_mobile_app])
      headers_table.push({ field: 'android_version', title: 'Android Version'})
    end
    headers_table
	end



	def self.get_account_details
		[
			{ field: :employee_number, 		title: "Employee #", 					required: false},
			{ field: :first_name, 				title: "First Name", 					required: true},
			{ field: :last_name, 					title: "Last Name", 					required: true},
			{ field: :email, 							title: "Email", 							required: true},
			{ field: :job_title, 					title: "Job Title", 					required: false},
			{ field: :address, 						title: "Address", 						required: false},
			{ field: :city, 							title: "City", 								required: false},
			{ field: :state, 							title: "State", 							required: false},
			{ field: :zipcode, 						title: "Zipcode", 						required: false},
			{ field: :mobile_number, 			title: "Mobile Number", 			required: false},
			{ field: :work_phone_number, 	title: "Work Phone Number", 	required: false},
		]
	end


	def self.get_headers
		{
			"ID"					=> "id",
			"Type"				=> "level",
			"Username"		=> "username",
			"Name"				=> "full_name",
			"Email"				=> "email"
		}
	end


	def account_status
		if self.disable?
			"Disabled"
		else
			"Active"
		end
	end


	def self.invite_headers
		[
			{ field: "full_name", 			title: "Name"},
			{ field: "email", 					title: "Email"},
		]
	end


	def has_access_to(message)
		!MessageAccess.where("users_id = ? AND messages_id = ?", self.id, message.id).empty?
	end


	def num_unread()
		self.cc_messages.select{|x| x.status == "Unread"}.length +
			self.inbox_messages.select{|x| x.status == "Unread"}.length
	end

	# def num_inprogress_submission()
	#   Submission.where("user_id = ?", self.id)
	# end

	#Returns a random token
	def self.new_token
		SecureRandom.urlsafe_base64
	end


	def self.digest(string)
		Digest::SHA1.hexdigest([string, self.password_salt].join)
	end


	#Sets the password reset attributes
	def create_reset_digest
		self.reset_token = User.new_token
		update_attribute(:reset_digest, encrypt_password(reset_token))
		update_attribute(:reset_sent_at, Time.zone.now)
	end


	#Sends password reset email
	def send_password_reset_email
		UserMailer.password_reset(self)
	end


	def password_reset_expired?
		reset_sent_at < 30.minutes.ago
	end


	def send_password_reset
		generate_token(:reset_digest)
		self.reset_sent_at = Time.zone.now
		save!
		UserMailer.password_reset(self).deliver
	end

	# This generates a random password reset token for the user
	def generate_token(column)
		begin
			self[column] = SecureRandom.urlsafe_base64
		end
	end

	def admin?
		self.level == "Admin"
	end


	private

	def prepare_password
		unless password.blank?
			self.password_salt = Digest::SHA1.hexdigest([Time.now, rand].join)
			self.password_hash = encrypt_password(password)
		end
	end


	def encrypt_password(pass)
		Digest::SHA1.hexdigest([pass, password_salt].join)
	end





	# determines if position needs to be
	# displayed in user grid, show and edit.
	def self.display
		{:position => false}
	end


	def self.get_levels
		['Admin','Staff','Pilot','Ground','Analyst']
	end


end
