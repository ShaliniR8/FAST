class Meeting < ProsafetBase

  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Reportable
  include Transactionable

#Associations List
  has_many :invitations,        foreign_key: "meetings_id",    class_name: "Invitation",         :dependent => :destroy
  has_many :agendas,            foreign_key: "owner_id",       class_name: "AsapAgenda",         :dependent=>:destroy

  has_one :host, foreign_key: "meetings_id", class_name: "Host"


  accepts_nested_attributes_for :invitations
  accepts_nested_attributes_for :host
  accepts_nested_attributes_for :agendas
  accepts_nested_attributes_for :reports

  before_create :init_status
  validates :review_start, presence: true
  validates :review_end, presence: true
  validates :meeting_start, presence: true
  validates :meeting_end, presence: true

  serialize :privileges
  before_create :set_privileges
  after_create -> { create_transaction('Create') }


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',               title: 'ID',                num_cols: 6,  type: 'text',       visible: 'index,show',      required: true},
      {field: 'status',           title: 'Status',            num_cols: 6,  type: 'text',       visible: 'index,show',      required: false},
      {field: 'get_host',         title: 'Host',              num_cols: 6,  type: 'text',       visible: 'index,show',      required: false},
      {field: 'title',            title: 'Title',             num_cols: 6,  type: 'datalist',   visible: 'index,show,form', required: false, options: get_custom_options('Meeting Titles')},
      {                                                                     type: 'newline',    visible: 'form,show'},
      {field: 'review_start',     title: 'Review Start',      num_cols: 6,  type: 'datetimez',  visible: 'index,form,show', required: true},
      {field: 'review_end',       title: 'Review End',        num_cols: 6,  type: 'datetimez',  visible: 'index,form,show', required: true},
      {field: 'meeting_start',    title: 'Meeting Start',     num_cols: 6,  type: 'datetimez',  visible: 'index,form,show', required: true},
      {field: 'meeting_end',      title: 'Meeting End',       num_cols: 6,  type: 'datetimez',  visible: 'index,form,show', required: true},
      {field: 'notes',            title: 'Notes',             num_cols: 12, type: 'textarea',   visible: 'form,show',       required: false},
      {field: 'final_comment',    title: 'Final Comment',     num_cols: 12, type: 'textarea',   visible: 'show',            required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.progress
    {
      "Open"        => { :score => 25,  :color => "default"},
      "Closed"    => { :score => 100, :color => "success"},
    }
  end


  def create_transaction(action)
    if !self.changes()['viewer_access'].present?
      Transaction.build_for(
        self,
        action,
        ((session[:simulated_id] || session[:user_id]) rescue nil)
      )
    end
  end


  def set_datetimez
    self.review_start = covert_time(self.review_start)
    self.review_end = covert_time(self.review_end)
    self.meeting_start = covert_time(self.meeting_start)
    self.meeting_end = covert_time(self.meeting_end)
    self.save
  end


  def covert_time(time)
    timezone = CONFIG::GENERAL[:time_zone]
    (time.in_time_zone(timezone) - time.in_time_zone(timezone).utc_offset).utc
  end


  def get_privileges
    self.privileges.present? ? self.privileges : []
  end


  def set_privileges
    self.privileges = []
  end


  def get_type
    self.type
  end


  def has_user(user)
    if self.host.present?
      self.host.users_id == user.id || self.invited?(user)
    else
      self.invited?(user)
    end
  end


  def invited?(user)
    result = false
    self.invitations.each do |f|
      result = result || (f.users_id==user.id && f.status == "Accepted")
    end
    result
  end


  def init_status
    self.status = "Open"
  end


  def get_tooltip
    "Review Period is " + self.get_time("review_start") + " to "+self.get_time("review_end")
  end


  def in_review
    self.status == "Open"
  end


  def in_meeting
    self.status == "Open"
  end


  def self.get_timezones
    ["Z","NZDT","IDLE","NZST","NZT","AESST","ACSST","CADT","SADT","AEST","CHST","EAST","GST",
     "LIGT","SAST","CAST","AWSST","JST","KST","MHT","WDT","MT","AWST","CCT","WADT","WST",
     "JT","ALMST","WAST","CXT","MMT","ALMT","MAWT","IOT","MVT","TFT","AFT","MUT","RET",
     "SCT","IRT","IT","EAT","BT","EETDST","HMT","BDST","CEST","CETDST","EET","FWT","IST",
     "MEST","METDST","SST","BST","CET","DNT","FST","MET","MEWT","MEZ","NOR","SET","SWT",
     "WETDST","GMT","UT","UTC","ZULU","WET","WAT","FNST","FNT","BRST","NDT","ADT","AWT",
     "BRT","NFT:NST","AST","ACST","EDT","ACT","CDT","EST","CST","MDT","MST","PDT","AKDT",
     "PST","YDT","AKST","HDT","YST","MART","AHST","HST","CAT","NT","IDLW"]
  end


  def self.get_headers
    [
      {:field=>"get_id",                                :title=>"ID"},
      {:field=>"get_time" ,:param=>"review_start",      :title=>"Review Start"},
      {:field=>"get_time" ,:param=>"review_end",        :title=>"Review End"},
      {:field=>"get_time" ,:param=>"meeting_start",     :title=>"Meeting Start"},
      {:field=>"get_time" ,:param=>"meeting_end",       :title=>"Meeting End"},
      {:field=>"get_events_count",                      :title=>"Included Events"},
      {:field=>"get_host" ,                             :title=>"Host"},
      {:field=>"status",                                :title=>"Status"}
    ]
  end


  def self.get_print_headers
    [
      {:field => :get_id,                                 :title => "Meeting ID"          },
      {:field => :status,                                 :title => "Status"              },
      {:field => :get_host,                               :title => "Host"                },
      {:field => :get_time,  :param => :review_start,     :title => "Review Start"        },
      {:field => :get_time,  :param => :review_end,       :title => "Review End"          },
      {:field => :get_time,  :param => :meeting_start,    :title => "Meeting Start"       },
      {:field => :get_time,  :param => :meeting_end,      :title => "Meeting End"         },
      {:field => :notes,                                  :title => "Notes"               },
    ]
  end


  def get_events_count
    reports.length
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def get_time(field)
    self.send(field).strftime("%Y-%m-%d %H:%M:%S") rescue ''
  end


  def get_host
    self.host.user.full_name rescue ''
  end


  def self.getMessageOptions
    {
      "All Invitees"=>"All",
      "All Participants (Exclude Rejected Invitations)"=>"Par",
      "Accepted Invitees"=>"Acp",
      "Pending Invitees"=>"Pen",
      "Rejected Invitees"=>"Rej"
    }
  end

end
