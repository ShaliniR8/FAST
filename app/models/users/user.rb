class User < ActiveRecord::Base
  has_many :templates,        foreign_key: 'users_id',  class_name: 'Template'
  has_many :submissions,      foreign_key: 'user_id',   class_name: 'Submission'
  has_many :notices,          foreign_key: 'users_id',  class_name: 'Notice',       dependent: :destroy
  has_many :cc_messages,      foreign_key: 'users_id',  class_name: 'CC',           dependent: :destroy
  has_many :inbox_messages,   foreign_key: 'users_id',  class_name: 'SendTo',       dependent: :destroy
  has_many :sent_messages,    foreign_key: 'users_id',  class_name: 'SendFrom',     dependent: :destroy
  has_many :invitations,      foreign_key: 'users_id',  class_name: 'Invitation',   dependent: :destroy
  has_many :roles,            foreign_key: 'users_id',  class_name: 'Role',         dependent: :destroy

  has_many :privileges, :through => :roles

  #Kaushik Mahorker OAuth
  has_many :client_applications
  has_many :tokens, :class_name => "Oauth2Token", :order => "authorized_at desc", :include => [:client_application]



  has_many :access_levels
  accepts_nested_attributes_for :access_levels, reject_if: :all_blank, allow_destroy: true


  # new columns need to be added here to be writable through mass assignment
  attr_accessible :username, :email,
    :password,:password_salt, :password_confirmation,
    :first_name, :last_name, :level, :full_name, :airport,
    :module_access, :email_notification, :role, :airline,
    :job_title, :address, :city, :state, :zipcode, :mobile_number,
    :work_phone_number, :employee_number, :access_levels_attributes,
    :android_version, :disable, :updated_at



  attr_accessor :password, :reset_token
  before_save :prepare_password

  validates_presence_of :username,    :message => " cannot be empty."
  validates_presence_of :first_name,  :message => " cannot be empty."
  validates_presence_of :last_name,   :message => " cannot be empty."
  # validates_presence_of :password, :message => " cannot be empty."
  validates_uniqueness_of :username, :case_sensitive => false, :message => " has already been taken."
  validates_format_of :username, :with => /^[-\w\._@]+$/i, :allow_blank => true, :message => "should only contain letters, numbers, or .-_@"
  # validates_presence_of :password, :on => :create
  validates_confirmation_of :password, :message => " must match."
  validates_length_of :password, :minimum => 4, :allow_blank => true, :message => " needs to be at least 4 characters long."



  def get_all_access
    result = []
    self.privileges.each do |p|
      result.concat(p.access_controls)
    end
    result.uniq
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


  # admin: will return true if the user is a global admin, has the specific con_name's 'admin' action, or has the exact con_name act_name rule
  # strict: will return true ONLY IF the user has the EXACT rule; will return false even if the rule isn't defined in the system
  def has_access(con_name, act_name, strict:false, admin:false)
    return true if admin && self.admin?
    rules = Rails.application.config.restricting_rules
    if rules.key?(con_name) && rules[con_name].include?(act_name)
      begin
        permissions = JSON.parse(session[:permissions])
      rescue
        return false #rescue for if session has expired
      end
      return (admin && permissions.key?(con_name) && permissions[con_name].include?('admin')) ||
        (permissions.key?(con_name) && permissions[con_name].include?(act_name))
    end
    strict ? !(AccessControl.get_meta.key?(con_name) && AccessControl.get_meta[con_name][act_name].present?) : true
  end


  def accessible_modules
    modules = AccessControl.where(action: 'module')
    return modules.map{|rule| rule.entry} if self.admin?
    (modules & get_all_access).map{|rule| rule.entry}
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

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    headers_table = [
        { field: "employee_number",        title: "Employee #",       type: 'text',      visible: 'index', required: false},
        { field: "id",                     title: "ID",               type: 'text',      visible: 'index', required: false},
        { field: "level" ,                 title: "Type",             type: 'text',      visible: 'index', required: false},
        { field: "username",               title: 'Username',         type: 'text',      visible: 'index', required: false},
        { field: "full_name",              title: 'Name',             type: 'text',      visible: 'index', required: false},
        { field: "email",                  title: "Email",            type: 'text',      visible: 'index', required: false},
        { field: "account_status",         title: "Account Status",   type: 'text',      visible: 'index', required: false},
        { field: "get_last_seen_at",       title: "Last Seen At",     type: 'datetime',  visible: 'index', required: false},
      ].select{|f| (f[:visible].split(',') & visible_fields).any?}
    if (BaseConfig.airline[:has_mobile_app])
      headers_table.push({ field: 'android_version', title: 'Android Version', type: 'text', visible: 'index', required: false})
    end
    headers_table
  end


  def self.get_headers_table
    headers_table = [
      { field: "employee_number",        title: "Employee #"},
      { field: "id",                     title: "ID"},
      { field: "level" ,                 title: "Type"},
      { field: "username",               title: 'Username'},
      { field: "full_name",              title: 'Name'},
      { field: "email",                  title: "Email"},
      { field: "account_status",         title: "Account Status"},
      { field: "get_last_seen_at",       title: "Last Seen At",     :type => 'datetime'},
    ]
    if (BaseConfig.airline[:has_mobile_app])
      headers_table.push({ field: 'android_version', title: 'Android Version'})
    end
    headers_table
  end


  def self.get_account_details
    [
      { field: :employee_number,    title: "Employee #",          required: false},
      { field: :first_name,         title: "First Name",          required: true},
      { field: :last_name,          title: "Last Name",           required: true},
      { field: :email,              title: "Email",               required: true},
      { field: :job_title,          title: "Job Title",           required: false},
      { field: :address,            title: "Address",             required: false},
      { field: :city,               title: "City",                required: false},
      { field: :state,              title: "State",               required: false},
      { field: :zipcode,            title: "Zipcode",             required: false},
      { field: :mobile_number,      title: "Mobile Number",       required: false},
      { field: :work_phone_number,  title: "Work Phone Number",   required: false},
    ]
  end


  def self.get_headers
    {
      "ID"          => "id",
      "Type"        => "level",
      "Username"    => "username",
      "Name"        => "full_name",
      "Email"       => "email"
    }
  end


  def account_status
    if self.disable?
      "Disabled"
    else
      "Active"
    end
  end


  def get_last_seen_at
    last_seen_at.localtime rescue ''
  end


  def self.invite_headers
    [
      { field: "full_name",       title: "Name"},
      { field: "email",           title: "Email"},
    ]
  end


  def has_access_to(message)
    !MessageAccess.where("users_id = ? AND messages_id = ?", self.id, message.id).empty?
  end


  def num_unread()
    self.cc_messages.select{|x| x.status == "Unread"}.length +
      self.inbox_messages.select{|x| x.status == "Unread"}.length
  end


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
