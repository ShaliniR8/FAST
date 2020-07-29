class Report < Sr::SafetyReportingBase
  include ModelHelpers

#Concerns List
  include Attachmentable
  include Commentable
  include Investigationable
  include RiskHandling
  include RootCausable
  include Sraable
  include Transactionable
  include Childable
  include Parentable


  has_many :records,            foreign_key: 'reports_id',  class_name: 'Record'
  has_many :corrective_actions, foreign_key: 'reports_id',  class_name: 'CorrectiveAction',   dependent: :destroy
  has_many :agendas,            foreign_key: 'event_id',    class_name: 'AsapAgenda',         dependent: :destroy
  has_many :suggestions,        foreign_key: 'owner_id',    class_name: 'ReportSuggestion',   dependent: :destroy
  has_many :descriptions,       foreign_key: 'owner_id',    class_name: 'ReportDescription',  dependent: :destroy
  has_many :causes,             foreign_key: 'owner_id',    class_name: 'ReportCause',        dependent: :destroy
  has_many :detections,         foreign_key: 'owner_id',    class_name: 'ReportDetection',    dependent: :destroy
  has_many :reactions,          foreign_key: 'owner_id',    class_name: 'ReportReaction',     dependent: :destroy

  serialize :privileges

  before_create :set_priveleges
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
        self.child_connections.delete_all
      end
  ### END TAGGED AREA
    has_many :active_meetings, through: :child_connections, source: :owner, source_type: 'Meeting', conditions: "connections.complete = 0 AND connections.archive = 0"

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    CONFIG.object['Report'][:fields].values.select{ |f| (f[:visible].split(',') & visible_fields).any? }
  end

  def title
    name
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
    agenda = "<b>Agendas:</b><br>#{agendas.map(&:get_content).join('<br>')}" if agendas.length > 0
    meeting_minutes = "<hr><b>Minutes:</b> <br>#{minutes}" if !minutes.blank?
    "#{agenda || ''} #{meeting_minutes || ''}".html_safe
  end


  def is_asap
    records.any? { |record| record.template.report_type == 'asap' }
  end

  def has_open_asap
    records.any? { |record| record.template.report_type == 'asap' && record.status != 'Closed' }
  end

  def additional_info
    result = ""

    if attachments.length > 0
      attachments.each do |attachment|
        result +="<a href='#{attachment.name.url}' target='_blank'><i class='fa fa-paperclip view_attachments'></i> #{attachment[:name]}</a><br>"
      end
    end

    if records.map(&:attachments).flatten.length > 0
      records.map(&:attachments).flatten.each do |attachment|
        result +="<a href='#{attachment.name.url}' target='_blank'><i class='fa fa-paperclip view_attachments'></i> #{attachment[:name]}</a><br>"
      end
    end

    result.html_safe
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


  def included_reports_types
    records.map{|record| record.get_template}.join(';')
  end


  def reopen(new_status)
    self.status = new_status
    self.close_date = nil
    self.records.each{|x| x.reopen("Linked");}
    Transaction.build_for(
      self,
      'Reopen',
      (session[:simulated_id] || session[:user_id])
    )
    self.save
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
      {:field => :get_id,                      :title => "ID"                                                     },
      {:field => :name,                        :title => "Title"                                                  },
      {:field => :num_records,                 :title => "Reports Included"                                       },
      {:field => :get_event_date,              :title => "Event Date",      :type => "date"                       },
      {:field => :display_before_risk_factor,  :title => "Baseline Risk",   :html_class => :get_before_risk_color },
      {:field => :display_after_risk_factor,   :title => "Mitigated Risk",  :html_class => :get_after_risk_color  },
      {:field => :status,                      :title => "Status"                                                 },
    ]
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
    if CONFIG.sr::GENERAL[:submission_description]
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


    def get_privileges
      self.privileges.present? ?  self.privileges : []
    end
  def self.get_avg_complete
    candidates = self.where("status=? and close_date is not ?","Closed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x| sum+=(x.close_date.to_date - x.created_at.to_date).to_i}
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end

  def can_meeting_ready?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status == 'New' || form_conds
    user_confirmed = true
    form_confirmed && user_confirmed && !self.occurrence_lock?
  end

  def can_close?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status != 'Closed' || form_conds
    user_confirmed = true
    form_confirmed && user_confirmed && !self.occurrence_lock?
  end
end
