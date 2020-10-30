class FaaReport < ActiveRecord::Base
  has_many :issues, foreign_key: "faa_report_id", class_name: "Issue", :dependent => :destroy
  accepts_nested_attributes_for :issues, allow_destroy: true


  def self.fiscal_quarter
    [
      {:quarter => 1,  :display => "1st Quarter (October 1 - December 31 of previous year)"  },
      {:quarter => 2,  :display => "2nd Quarter (January 1 - March 31)"  },
      {:quarter => 3,  :display => "3rd Quarter (April 1 - June 30)" },
      {:quarter => 4,  :display => "4th Quarter (July 1 - September 30)" },
    ]
  end


  def get_fiscal_quarter
    case self.quarter
      when 1
        "1st Quarter (October 1 - December 31)"
      when 2
        "2nd Quarter (January 1 - March 31)"
      when 3
        "3rd Quarter (April 1 - June 30)"
      when 4
        "4th Quarter (July 1 - September 30)"
      else
        ""
    end
  end


  def self.get_members
    [
      {title: 'FAA Member',     value: 'faa'},
      {title: 'Company Member', value: 'company'},
      {title: 'Labor Member',   value: 'labor'},
      {title: 'ASAP Manager',   value: 'asap'},
    ]
  end


  def self.get_stats
    [
      {title: 'Date Range', link: false, value: 'get_range'},
      {title: 'Number of ASAP reports submitted present quarter',
        link: true, mode: 1, value: 'statistics', value_key: 'asap_submitted'},
      {title: 'Number of ASAP reports accepted present quarter',
        link: true, mode: 2, value: 'statistics', value_key: 'asap_accepted'},
      {title: 'Number of accepted reports present quarter that were sole source to the FAA',
        link: true, mode: 3, value: 'statistics', value_key: 'asap_accepted_sole_source'},
      {title: 'Number of accepted reports present quarter closed under ASAP',
        link: true, mode: 4, value: 'statistics', value_key: 'asap_accepted_closed'},
      {title: 'Number of accepted reports present quarter (both sole source & non-sole source) closed with corrective action under ASAP for the employee',
        link: true, mode: 5, value: 'statistics', value_key: 'asap_accepted_employee_car'},
      {title: 'Number of accepted reports present quarter, which resulted in recommendations to the company for corrective action',
        link: true, mode: 6, value: 'statistics', value_key: 'asap_aceepted_company_car'},
    ]
  end


  def statistics(asap_reports)
    accepted_reports = asap_reports.select{|report| report.asap}
    result = {
      asap_submitted: asap_reports.map(&:id),
      asap_accepted: accepted_reports.map(&:id),
      asap_accepted_sole_source: accepted_reports.select{|report| report.sole}.map(&:id),
      asap_accepted_closed: accepted_reports.select{|report| report.status == 'Closed'}.map(&:id),
      asap_accepted_employee_car: accepted_reports.select{|report| report.has_emp}.map(&:id),
      asap_aceepted_company_car: accepted_reports.select{|report| report.has_com}.map(&:id)
    }
    result
  end


  # set statistics for FAA Report Print Word
  def set_statistics
    asap_reports = self.select_records_in_date_range(self.get_start_date, self.get_end_date)
      .select{|x|
        (x.template.name.include? "ASAP") &&
        (x.template.name.include? "#{self.employee_group}")}
    stats = self.statistics(asap_reports)
    self.asap_submit = stats[:asap_submitted].size
    self.asap_accept = stats[:asap_accepted].size
    self.sole        = stats[:asap_accepted_sole_source].size
    self.asap_close  = stats[:asap_accepted_closed].size
    self.asap_emp    = stats[:asap_accepted_employee_car].size
    self.asap_com    = stats[:asap_aceepted_company_car].size
    self.save
  end


  def self.get_new(y,q)
    result = FaaReport.new
    result.year = y
    result.quarter = q
    result.save
    result
  end



  def get_start_date
    faa_report_format = CONFIG.getTimeFormat[:faa_report]
    case self.quarter
      when 1
        faa_report_format ? "10/01/#{self.year-1}" : "#{self.year-1}-10-01"
      when 2
        faa_report_format ? "01/01/#{self.year}"   : "#{self.year}-01-01"
      when 3
        faa_report_format ? "04/01/#{self.year}"   : "#{self.year}-04-01"
      when 4
        faa_report_format ? "07/01/#{self.year}"   : "#{self.year}-07-01"
    end
  end


  def get_end_date
    faa_report_format = CONFIG.getTimeFormat[:faa_report]
    case self.quarter
      when 1
        faa_report_format ? "12/31/#{self.year-1}" : "#{self.year-1}-12-31"
      when 2
        faa_report_format ? "03/31/#{self.year}"   : "#{self.year}-03-31"
      when 3
        faa_report_format ? "06/30/#{self.year}"   : "#{self.year}-06-30"
      when 4
        faa_report_format ? "09/30/#{self.year}"   : "#{self.year}-09-30"
    end
  end


  def faa_format_date(date)
    faa_report_format = CONFIG.getTimeFormat[:faa_report]
    faa_report_format ? Date.strptime(date, '%m/%d/%Y') : Date.strptime(date, '%Y-%m-%d')
  end


  def select_records_in_date_range(start_date, end_date)
    faa_report_format = CONFIG.getTimeFormat[:faa_report]
    start_date = faa_format_date(start_date)
    end_date = faa_format_date(end_date)
    asap_reports = Record.preload(:corrective_actions, :template, report: :corrective_actions).all.select do |r|
      selected = false
      if r.event_date.present?
        r_date = r.event_date
        r_time_zone = r.event_time_zone
        r_date = r_date.in_time_zone(r_time_zone) if CONFIG.sr::GENERAL[:submission_time_zone]
        r_date = r_date.to_date
        selected = true if r_date >= start_date && r_date <= end_date
      end
      selected
    end
  end


  def self.getEmployeeGroup
    Template.select(:emp_group).map(&:emp_group).compact.uniq.map!(&:titleize)
  end


  def get_range
    faa_report_format = CONFIG.getTimeFormat[:faa_report]
    start_date = self.get_start_date
    end_date = self.get_end_date
    "#{start_date} To #{end_date}"
  end



  def self.get_headers
    [
      {:field =>  "year",           :title=>"Fiscal Year"},
      {:field =>  "quarter",        :title=>"Fiscal Quarter"},
      {:field =>  "enhancements",   :title=>"Safety Enhancements"},
      {:field =>  "employee_group", :title => "Employee Group"}
    ]
  end

  def enhancements
    if self.issues.present?
      self.issues.length
    else
      0
    end
  end


  def safety_enhencement
    result = ""
    if self.issues.present?
      self.issues.each do |x|
        result << "\"#{x.title}\": "
        result << "#{x.safety_issue} \n"
        result << "Corrective Action: #{x.corrective_action} \n"
      end
    end
    result
  end


  def car_docx
    result = ""
    asap_reports = select_records_in_date_range(self.get_start_date, self.get_end_date)
      .select{|x|
        (x.template.name.include? "ASAP") &&
        (x.template.name.include? "#{self.employee_group}")}
    asap_events = asap_reports.map{|x| x.report}.uniq.compact
    asap_events.each do |event|
      if event.corrective_actions.length > 0
        result << "Event ##{event.id}, #{event.name} - #{event.narrative} \n"
        event.corrective_actions.each do |car|
          result << "Corrective Action ##{car.id}, #{car.action} - #{car.description} \n"
        end
      end
    end
    result
  end

end
