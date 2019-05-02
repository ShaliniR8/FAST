class Hazard < ActiveRecord::Base
  belongs_to :sra,                :foreign_key => "sra_id",                 :class_name => "Sra"
  belongs_to :responsible_user,   :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :created_by,         :foreign_key => "created_by_id",          :class_name => "User"

  has_many :attachments,          :foreign_key => "owner_id",               :class_name => "HazardAttachment",    :dependent => :destroy
  has_many :risk_controls,        :foreign_key => "hazard_id",              :class_name => "RiskControl",         :dependent => :destroy
  has_many :transactions,         as: :owner,                               :dependent => :destroy
  has_many :descriptions,         :foreign_key => "owner_id",               :class_name => "HazardDescription",   :dependent => :destroy
  has_many :root_causes,          :foreign_key => "owner_id",               :class_name => "HazardRootCause",     :dependent => :destroy

  accepts_nested_attributes_for :risk_controls
  accepts_nested_attributes_for :descriptions
  accepts_nested_attributes_for :attachments, allow_destroy: true, reject_if: Proc.new{|attachment| (attachment[:name].blank?&&attachment[:_destroy].blank?)}



  after_create -> { create_transaction('Create') }


  serialize :severity_extra
  serialize :probability_extra
  serialize :mitigated_severity
  serialize :mitigated_probability
  before_create :set_extra

  extend AnalyticsFilters


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      {field: "get_id",                     title: "Hazard ID",             num_cols: 6,  type: "text",     visible: 'index,show',      required: false},
      {field: "status",                     title: "Status",                num_cols: 4,  type: "text",     visible: 'index,show',      required: false},
      {field: "title",                      title: "Hazard Title",          num_cols: 6,  type: "text",     visible: 'form,index,show', required: true},
      {field: 'get_source',                 title: 'Source of Input',       num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: "description",                title: "Description",           num_cols: 12, type: "textarea", visible: 'form,show'},
      {field: "get_root_causes",            title: "Root Causes",                         type: "text",     visible: 'index'},
      {field: "display_before_risk_factor", title: "Baseline Risk",                       type: "text",     visible: 'index',   html_class: "get_before_risk_color" },
      {field: "display_after_risk_factor",  title: "Mitigated Risk",                      type: "text",     visible: 'index', html_class: "get_after_risk_color"    },
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.progress
    {
      "New"       => { :score => 25,  :color => "default"},
      "Rejected"    => { :score => 100, :color => "warning"},
      "Completed"   => { :score => 100, :color => "success"},
    }
  end


  def get_source
    "<a style='font-weight:bold' href='/sras/#{sra.id}'>
      SRA ##{sra.id}
    </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
  end


  def self.get_headers
    if BaseConfig.airline[:has_root_causes]
      [
        { :field => :get_id                           ,:title => "ID"                                                               },
        { :field => :title                            ,:title => "Title"                                                            },
        { :field => :description                      ,:title => "Description"                                                      },
        { :field => :get_root_causes                  ,:title => "Root Causes"                                                      },
        { :field => :display_before_risk_factor       ,:title => "Baseline Risk"            ,:html_class => :get_before_risk_color  },
        { :field => :display_after_risk_factor        ,:title => "Mitigated Risk"           ,:html_class => :get_after_risk_color   },
        { :field => :status                           ,:title => "Status"                                                           },
      ]
    else
      [
        { :field => :get_id                           ,:title => "ID"                                                               },
        { :field => :title                            ,:title => "Title"                                                            },
        { :field => :description                      ,:title => "Description"                                                      },
        { :field => :display_before_risk_factor       ,:title => "Baseline Risk"            ,:html_class => :get_before_risk_color  },
        { :field => :display_after_risk_factor        ,:title => "Mitigated Risk"           ,:html_class => :get_after_risk_color   },
        { :field => :status                           ,:title => "Status"                                                           },
      ]
    end
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
  def responsible_user_name
    self.responsible_user.present? ? self.responsible_user.full_name : ""
  end

  def self.root_causes
    custom_options = CustomOption.where(:title => "Manuals").first
    if custom_options.present?
      custom_options.options.split(";")
    else
      [
        'Inadequate development / implementation of policy or procedure',
        'Inadequate training',
        'Inadequate training materials',
        'Lack of or inadequate policy or procedure',
        'Emotional overload',
        'Extreme judgement decisions/demands',
        'Preoccupation with problems',
        'Other'
      ]
    end
  end

  def create_transaction(action)
    Transaction.build_for(
      self,
      action,
      (session[:simulated_id] || session[:user_id])
    )
    Transaction.build_for(
      self.sra,
      'Add Hazard',
      (session[:simulated_id] || session[:user_id]),
      "##{self.get_id} #{self.title}"
    )
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

  def get_root_causes
    root_cause_arr = root_causes.map{|x| "<li>#{x.cause_option.name}</li>"}.join("").html_safe
    "<ul class='table_ul'>#{root_cause_arr}</ul>".html_safe
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



  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end



  # Search terms used in Advanced Search from index page
  def self.get_terms
    {
      "Status"                      => "status",
      "Description"                 => "description",
    }.sort_by{|k, v| k}
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

    def can_reopen? current_user
      BaseConfig.airline[:allow_reopen_report] && (
        current_user.admin? ||
        current_user.has_access('sras','admin'))
    end

    def release_controls
      self.risk_controls.each(&:release)
    end

    def self.get_avg_complete
      candidates=self.where("status=? and close_date is not ? and created_at is not ?","Completed",nil,nil)
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
