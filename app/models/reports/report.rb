class Report < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Commentable
  include Investigationable
  include Sraable
  include Transactionable
  include RootCausable

  has_many :records,            foreign_key: 'reports_id',  class_name: 'Record'
  has_many :corrective_actions, foreign_key: 'reports_id',  class_name: 'CorrectiveAction',   dependent: :destroy
  has_many :agendas,            foreign_key: 'event_id',    class_name: 'AsapAgenda',         dependent: :destroy
  has_many :suggestions,        foreign_key: 'owner_id',    class_name: 'ReportSuggestion',   dependent: :destroy
  has_many :descriptions,       foreign_key: 'owner_id',    class_name: 'ReportDescription',  dependent: :destroy
  has_many :causes,             foreign_key: 'owner_id',    class_name: 'ReportCause',        dependent: :destroy
  has_many :detections,         foreign_key: 'owner_id',    class_name: 'ReportDetection',    dependent: :destroy
  has_many :reactions,          foreign_key: 'owner_id',    class_name: 'ReportReaction',     dependent: :destroy

  serialize :privileges
  serialize :severity_extra
  serialize :probability_extra
  serialize :mitigated_severity
  serialize :mitigated_probability

  before_create :set_priveleges
  before_create :set_extra
  after_create :set_name

  extend AnalyticsFilters

  ### NOTE: Add these lines to the inheritance tree when added, then remove these statements in this tagged area
    has_many :child_connections, as: :child, class_name: 'Connection', dependent: :destroy
    has_many :meetings, through: :child_connections, source: :owner, source_type: 'Meeting'

    # def all_connections
    #   owner_connections + child_connections
    # end
    before_destroy :delete_connections
    # private
      def delete_connections
        self.connections.delete_all
      end
  ### END TAGGED AREA
    has_many :active_meetings, through: :child_connections, source: :owner, source_type: 'Meeting', conditions: "connections.complete = 0 AND connections.archive = 0"

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    [
      {field: 'id',                   title: 'ID',                        num_cols: 6,    type: 'text',     visible: 'index,show',          required: false },
      {field: 'status',               title: 'Status',                    num_cols: 6,    type: 'text',     visible: 'index,show',          required: false },
      {                                                                                   type: 'newline',  visible: 'show'                        },
      {field: 'name',                 title: 'Event Title',               num_cols: 6,    type: 'text',     visible: 'index,form,show',     required: true  },
      {field: 'event_date',           title: 'Event Date',                num_cols: 6,    type: 'date',     visible: 'index,form,show',     required: true  },
      {                                                                                   type: 'newline',  visible: 'show'                        },
      {field: 'included_reports',     title: 'Included Reports',          num_cols: 6,    type: 'text',     visible: 'index',               required: false },

      {field: "get_root_causes_full",   title: "#{I18n.t("sr.event.root_cause.title")}",    type: "list",     visible: 'invisible'},
      {field: "get_root_causes",        title: "#{I18n.t("sr.event.root_cause.title")}",    type: "list",     visible: 'index'},

      {field: 'event_label',          title: 'Event Type',                num_cols: 6,    type: 'select',   visible: 'event_summary',       required: false, options: get_label_options },
      {field: 'venue',                title: 'Venue',                     num_cols: 6,    type: 'select',   visible: 'event_summary',       required: false, options: get_venue_options },
      {field: 'icao',                 title: 'ICAO',                      num_cols: 6,    type: 'text',     visible: 'event_summary',       required: false },
      {field: 'narrative',            title: 'Event Description',         num_cols: 12,   type: 'textarea', visible: 'index,form,show',     required: true  },
      {field: 'minutes',              title: 'Meeting Minutes',           num_cols: 12,   type: 'textarea', visible: 'show',                required: false },

      {field: 'eir',                  title: 'EIR Number',                num_cols: 6,    type: 'text',     visible: 'close',           required: false },
      {field: 'scoreboard',           title: 'Exclude from Scoreboard',   num_cols: 6,    type: 'boolean',  visible: 'close',           required: true  },
      {field: 'asap',                 title: 'Accepted Into ASAP',        num_cols: 6,    type: 'boolean',  visible: 'close',           required: true  },
      {field: 'sole',                 title: 'Sole Source',               num_cols: 6,    type: 'boolean',  visible: 'close',           required: true  },
      {field: 'disposition',          title: 'Disposition',               num_cols: 6,    type: 'select',   visible: 'close',           required: false, options: dispositions  },
      {field: 'company_disposition',  title: 'Company Disposition',       num_cols: 6,    type: 'select',   visible: 'close',           required: false, options: company_dis },
      {field: 'narrative',            title: 'Narrative',                 num_cols: 12,   type: 'textarea', visible: 'close',           required: false },
      {field: 'regulation',           title: 'Regulation',                num_cols: 12,   type: 'textarea', visible: 'close',           required: false },
      {field: 'notes',                title: 'Closing Notes',             num_cols: 12,   type: 'textarea', visible: 'close',           required: false },

      {field: 'likelihood',           title: 'Baseline Likelihood',       num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',             title: 'Baseline Severity',         num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',          title: 'Baseline Risk',             num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',     title: 'Mitigated Likelihood',      num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',       title: 'Mitigated Severity',        num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',    title: 'Mitigated Risk',            num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},
      {field: 'get_minutes_agenda',   title: 'Meeting Minutes & Agendas', num_cols: 12,   type: 'text',     visible: 'meeting',             required: false }, #Gets overridden in view- see included_events.html.erb

      {field: 'additional_info',      title: 'Has Attachments',           num_cols: 12,   type: 'text',     visible: 'meeting',         required: false},


    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.progress
    {
      "New"             => { :score => 25,  :color => "default"},
      "Meeting Ready"   => { :score => 50,  :color => "warning"},
      "Under Review"    => { :score => 75,  :color => "warning"},
      "Closed"          => { :score => 100, :color => "success"},
    }
  end


  def get_minutes_agenda(meeting_id)
    agenda = "<b>Agendas:</b><br>#{agendas.where(owner_id: meeting_id).map(&:get_content).join('<br>')}" if agendas.length > 0
    meeting_minutes = "<hr><b>Minutes:</b> <br>#{minutes}" if !minutes.blank?
    "#{agenda || ''} #{meeting_minutes || ''}".html_safe
  end


  def is_asap
    result = false
    records.each do |x|
      result = result || x.template.report_type == "asap"
    end
    return result
  end


  def additional_info
    if attachments.length > 0 || records.map(&:attachments).flatten.length > 0
      "<i class='fa fa-paperclip view_attachments'></i>".html_safe
    end
  end


  def included_reports
    result = ""
    self.records.each do |record|
      result += "
        <a style='font-weight:bold' href='/records/#{record.id}'>
          ##{record.id} -
          #{record.created_by.disable ?
          '<font color="red">Inactive User</font>' :
          '<font color="green">Active User</font>'}
        </a><br>"
    end
    result.html_safe
  end


  def reopen(new_status)
    self.status = new_status
    self.records.each{|x| x.reopen("Linked");}
    Transaction.build_for(
      self,
      'Reopen',
      (session[:simulated_id] || session[:user_id])
    )
    self.save
  end




  def set_extra
    if self.severity_extra.blank?
      self.severity_extra=[]
    end
    if self.severity_extra.blank?
      self.probability_extra=[]
    end
    if self.mitigated_severity.blank?
      self.mitigated_severity=[]
    end
    if self.mitigated_probability.blank?
      self.mitigated_probability=[]
    end
  end




  def get_extra_severity
    self.severity_extra.present? ?  self.severity_extra : []
  end

  def get_extra_probability
    self.probability_extra.present? ?  self.probability_extra : []
  end

  def get_mitigated_probability
    self.mitigated_probability.present? ?  self.mitigated_probability : []
  end

  def get_mitigated_severity
    self.mitigated_severity.present? ?  self.mitigated_severity : []
  end

  def set_priveleges
    if self.privileges.blank?
      self.privileges=[]
    end
  end


  def set_name
    if self.name.blank?
      self.name="Unamed Report"
    end
  end

  def self.getStatus
    ["New","Under Investigation","Closed"]
  end


  def has_emp
    self.corrective_actions.each do |c|
      if c.employee
        return true
      end
    end
    false
  end

  def has_com
    self.corrective_actions.each do |c|
      if c.company && c.recommendation
        return true
      end
    end
    false
  end

  def self.get_headers
    [
      {:field => :get_id,                             :title => "ID"                                                                      },
      {:field => :name,                               :title => "Title"                                                                   },
      {:field => :num_records,                        :title => "Reports Included"                                                        },
      {:field => :get_event_date,                     :title => "Event Date"                                                              },
      {:field => :display_before_risk_factor,         :title => "Baseline Risk",                    :html_class => :get_before_risk_color },
      {:field => :display_after_risk_factor,          :title => "Mitigated Risk",                   :html_class => :get_after_risk_color  },
      {:field => :status,                             :title => "Status"                                                                  },
    ]
  end

  def get_before_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_before_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_before_risk_factor)
    end
  end

  def get_after_risk_color
    if BaseConfig.airline[:base_risk_matrix]
      BaseConfig::RISK_MATRIX[:risk_factor][display_after_risk_factor]
    else
      Object.const_get("#{BaseConfig.airline[:code]}_Config")::MATRIX_INFO[:risk_table_index].index(display_after_risk_factor)
    end
  end

  def display_before_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity
    else
      get_risk_values[:severity_1].present? ? get_risk_values[:severity_1] : "N/A"
    end
  end

  def display_before_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood
    else
      get_risk_values[:probability_1].present? ? get_risk_values[:probability_1] : "N/A"
    end
  end

  def display_before_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor.present? ? risk_factor : "N/A"
    else
      get_risk_values[:risk_1].present? ? get_risk_values[:risk_1] : "N/A"
    end
  end

  def display_after_severity
    if BaseConfig.airline[:base_risk_matrix]
      severity_after
    else
      get_risk_values[:severity_2].present? ? get_risk_values[:severity_2] : "N/A"
    end
  end

  def display_after_likelihood
    if BaseConfig.airline[:base_risk_matrix]
      likelihood_after
    else
      get_risk_values[:probability_2].present? ? get_risk_values[:probability_2] : "N/A"
    end
  end

  def display_after_risk_factor
    if BaseConfig.airline[:base_risk_matrix]
      risk_factor_after.present? ? risk_factor_after : "N/A"
    else
      get_risk_values[:risk_2].present? ? get_risk_values[:risk_2] : "N/A"
    end
  end

  def get_risk_values
    airport_config = Object.const_get("#{BaseConfig.airline[:code]}_Config")
    matrix_config = airport_config::MATRIX_INFO
    @severity_table = matrix_config[:severity_table]
    @probability_table = matrix_config[:probability_table]
    @risk_table = matrix_config[:risk_table]

    @severity_score = airport_config.calculate_severity(severity_extra)
    @sub_severity_score = airport_config.calculate_severity(mitigated_severity)
    @probability_score = airport_config.calculate_severity(probability_extra)
    @sub_probability_score = airport_config.calculate_severity(mitigated_probability)

    @print_severity = airport_config.print_severity(self, @severity_score)
    @print_probability = airport_config.print_probability(self, @probability_score)
    @print_risk = airport_config.print_risk(@probability_score, @severity_score)

    @print_sub_severity = airport_config.print_severity(self, @sub_severity_score)
    @print_sub_probability = airport_config.print_probability(self, @sub_probability_score)
    @print_sub_risk = airport_config.print_risk(@sub_probability_score, @sub_severity_score)

    {
      :severity_1       => @print_severity,
      :severity_2       => @print_sub_severity,
      :probability_1    => @print_probability,
      :probability_2    => @print_sub_probability,
      :risk_1           => @print_risk,
      :risk_2           => @print_sub_risk,
    }
  end

  def self.get_summary_headers
    [
      {:field => :get_month,                :title => "Month"},
      {:field => :get_year,                 :title => "Year"},
      {:field => :get_month_year,           :title => "Month/Year"},
      {:field => :get_fiscal_year,          :title => "Fiscal Year"},
      {:field => :get_id,                   :title => "Event Number"},
      {:field => :get_venue,                :title => "Venue"},
      {:field => :get_risk,                 :title => "Risk"},
      {:field => :get_icao,                 :title => "ICAO"},
      {:field => :get_label,                :title => "Type"},
      {:field => :get_name,                 :title => "Title"},
      {:field => :get_crew,                 :title => "Crew Involvement"},
      {:field => :get_causal_factor,        :title => "Causal Factors"},
      {:field => :get_hfacs,                :title => "HFACS"},
    ]
  end

  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end

  def get_description
    if self.description.blank?
      ""
    elsif self.description.length>30
      self.description[0..27]+"..."
    else
      self.description
    end
  end

  def submitted
    #self.created_at.strftime("%Y-%m-%d")
    self.created_at
  end
  def num_records
    self.records.blank? ? 0 : self.records.length
  end

  def get_template
    self.template.name
  end

  def get_event_date
    self.event_date.strftime("%Y-%m-%d") rescue ''
  end

  def get_month
    self.event_date.strftime("%B") rescue ''
  end

  def get_year
    self.event_date.year rescue ''
  end

  def get_month_year
    self.event_date.strftime("%B-%y") rescue ''
  end

  def get_fiscal_year
    self.get_year + (self.event_date.month < 10 ? 0 : 1)
  end

  def get_venue
    self.venue
  end

  def get_risk
    severity = self.severity.to_i if self.severity.present?
    likelihood = self.likelihood.to_i if self.likelihood.present?
    risk_factor = ApplicationController.helpers.print_risk(likelihood, severity)
    if risk_factor.present?
      case risk_factor.split(' - ').first
      when 'Green'
        'L'
      when 'Yellow'
        'M'
      when 'Red'
        'H'
      else
        risk_factor # print it as is
      end
    end
  end

  def get_icao
    self.icao
  end

  def get_label #type
    self.event_label
  end

  def self.count_events(label, fiscal_year)
    Report.all.select{|r| r.get_fiscal_year == fiscal_year && r.get_label == label}.count
  end

  def self.count_total_events(fiscal_year)
    Report.all.select{|r| r.get_fiscal_year == fiscal_year && r.get_label.present?}.count
  end

  def self.count_crew_involvement(fiscal_year)
    Report.all.select{|r| r.get_fiscal_year == fiscal_year && r.get_crew == "Yes"}.count
  end

  def self.count_crew_happenstance(fiscal_year)
    Report.all.select{|r| r.get_fiscal_year == fiscal_year && r.get_crew == "No"}.count
  end

  def get_name
    self.name
  end

  def get_crew
    self.crew
  end

  def get_causal_factor
    self.causes.reject{ |c| c.category.include? 'HFACS' }.map(&:category).uniq.join(", ")
  end

  def get_hfacs
    self.causes.select{ |c| c.category.include? 'HFACS' }.map(&:category).uniq.join(", ")
  end

  def self.get_label_options
    [
      "Aircraft Configuration",
      "Altitude Deviation",
      "ATC Concern",
      "Automation",
      "Duty/Rest",
      "EGPWS",
      "Fatigue",
      "Go Around/Missed",
      "Maintenance",
      "Miscellaneous",
      "Navigation",
      "Overspeed",
      "Rejected Takeoff",
      "Taxiway/Runway Incursion",
      "TCAS",
      "Unstable Approach",
      "Wildlife",
      "Windshear"
    ]
  end

  def self.get_venue_options
    [
      "PAS",
      "MAS",
      "MOPS",
      "OP",
      "FRM",
      "FA"
    ]
  end

  def self.get_crew_options
    ["Yes", "No"]
  end

  def self.getFormHeaders
    if BaseConfig.airline[:submission_description]
        [
          {:field=>"get_id", :size=>"col-xs-2 col-lg-2",:title=>"ID"},
          {:field=>"status" ,:size=>"col-xs-2 col-lg-2",:title=>"Status"},
          {:field=>"get_date" ,:size=>"col-xs-2 col-lg-2",:title=>"Date"},
          {:field=>"get_description" ,:size=>"col-xs-3 col-lg-3",:title=>"Description"},
          {:field=>"submit_name" ,:size=>"col-xs-2 col-lg-2",:title=>"Submitted By"}
        ]
      else
        [
          {:field=>"get_id", :size=>"col-xs-2 col-lg-2",:title=>"ID"},
          {:field=>"status" ,:size=>"col-xs-2 col-lg-2",:title=>"Status"},
          {:field=>"get_date" ,:size=>"col-xs-2 col-lg-2",:title=>"Date"},
          {:field=>"submit_name" ,:size=>"col-xs-2 col-lg-2",:title=>"Submitted By"}
        ]
      end
  end

    def self.dispositions
      [
        'Delegate for General Safety Review',
        'Electronic Response',
        'Informal Action',
        'Letter of Correction',
        'Letter of No Action',
        'No Action',
        'Open Investigation',
        'Voluntary Self-Disclosure',
        'Warning Notice'
      ]
    end

    def self.get_terms
    {
      "Title"                   => "name",
      "Status"                  => "status",
      "Description"             => "description",
      "Severity"                => "severity",
      "Likelihood"              => "likelihood",
      "Risk Factor"             => "risk_factor",
      "Likelihood (Mitigated)"  => "likelihood_after",
      "Severity (Mitigated)"    => "severity_after",
      "Risk Factor (Mitigated)" => "risk_factor_after",
    }
  end

    def self.company_dis
      [
        'No Action',
        'Voluntary Self-Disclosure'
      ]
    end

    def self.get_likelihood
    ["A - Improbable","B - Unlikely","C - Remote","D - Probable","E - Frequent"]
  end

    def likelihood_index
      if BaseConfig.airline[:base_risk_matrix]
        self.class.get_likelihood.index(self.likelihood).to_i
      else
        self.likelihood.to_i
      end
    end

    def likelihood_after_index
      if BaseConfig.airline[:base_risk_matrix]
        self.class.get_likelihood.index(self.likelihood_after).to_i
      else
        self.likelihood_after.to_i
      end
    end

    def get_privileges
      self.privileges.present? ?  self.privileges : []
    end
  def self.get_avg_complete
    candidates = self.where("status=? and close_date is not ?","Closed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.close_date-x.created_at.to_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end
end
