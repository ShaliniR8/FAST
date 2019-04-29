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



  def self.get_new(y,q)
    result = FaaReport.new
    result.year = y
    result.quarter = q
    result.save
    result
  end



  def get_start_date
    case self.quarter
      when 1
        "#{self.year-1}-10-01"
      when 2
        "#{self.year}-01-01"
      when 3
        "#{self.year}-04-01"
      when 4
        "#{self.year}-07-01"
    end
  end



  def self.getEmployeeGroup
    Template.select(:emp_group).map(&:emp_group).compact.uniq.map!(&:titleize)
  end



  def get_end_date
    case self.quarter
      when 1
        "#{self.year-1}-12-31"
      when 2
        "#{self.year}-03-31"
      when 3
        "#{self.year}-06-30"
      when 4
        "#{self.year}-09-30"
    end
  end



  def get_range
    "#{self.get_start_date} To #{self.get_end_date}"
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



end
