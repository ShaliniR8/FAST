class Hazard < ActiveRecord::Base
  extend AnalyticsFilters
  include StandardWorkflow
  include ModelHelpers
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable

#Associations List
  belongs_to :sra,                :foreign_key => "sra_id",                 :class_name => "Sra"
  belongs_to :responsible_user,   :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :created_by,         :foreign_key => "created_by_id",          :class_name => "User"

  has_many :risk_controls,        :foreign_key => "hazard_id",              :class_name => "RiskControl",         :dependent => :destroy
  has_many :descriptions,         :foreign_key => "owner_id",               :class_name => "HazardDescription",   :dependent => :destroy
  has_many :root_causes,          :foreign_key => "owner_id",               :class_name => "HazardRootCause",     :dependent => :destroy

  accepts_nested_attributes_for :risk_controls
  accepts_nested_attributes_for :descriptions


  after_create :create_transaction
  after_create :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    return [
      {field: "get_id",             title: "Hazard ID",             num_cols: 6,  type: "text",     visible: 'index,show',      required: false},
      {field: "status",             title: "Status",                num_cols: 4,  type: "text",     visible: 'index,show',      required: false},
      {field: 'created_by_id',           title: 'Created By',                  num_cols: 6,  type: 'user',         visible: 'show',            required: false},

      {field: "title",              title: "Hazard Title",          num_cols: 6,  type: "text",     visible: 'form,index,show', required: true},
      {field: 'get_source',         title: 'Source of Input',       num_cols: 6,  type: 'text',     visible: 'index,show',      required: false},
      {field: "description",        title: "Description",           num_cols: 12, type: "textarea", visible: 'form,show'},
      {field: "get_root_causes",    title: "Root Causes",                         type: "text",     visible: 'index'},

      {field: 'likelihood',         title: 'Baseline Likelihood',   num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity',           title: 'Baseline Severity',     num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor',        title: 'Baseline Risk',         num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_before_risk_color'},

      {field: 'likelihood_after',   title: 'Mitigated Likelihood',  num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'severity_after',     title: 'Mitigated Severity',    num_cols: 12,   type: 'text',     visible: 'adv',             required: false},
      {field: 'risk_factor_after',  title: 'Mitigated Risk',        num_cols: 12,   type: 'text',     visible: 'index',           required: false,  html_class: 'get_after_risk_color'},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
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


  def owner
    self.sra
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
  

  def get_root_causes
    root_cause_arr = root_causes.map{|x| "<li>#{x.cause_option.name}</li>"}.join("").html_safe
    "<ul class='table_ul'>#{root_cause_arr}</ul>".html_safe
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
