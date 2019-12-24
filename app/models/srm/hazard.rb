class Hazard < Srm::SafetyRiskManagementBase
  extend AnalyticsFilters
  include StandardWorkflow
  include ModelHelpers
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Occurrenceable
  include Transactionable
  include RootCausable

#Associations List
  belongs_to :sra,                :foreign_key => "sra_id",                 :class_name => "Sra"
  belongs_to :responsible_user,   :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :created_by,         :foreign_key => "created_by_id",          :class_name => "User"

  has_many :risk_controls,        :foreign_key => "hazard_id",              :class_name => "RiskControl",         :dependent => :destroy
  has_many :descriptions,         :foreign_key => "owner_id",               :class_name => "HazardDescription",   :dependent => :destroy

  accepts_nested_attributes_for :risk_controls
  accepts_nested_attributes_for :descriptions


  after_create :create_transaction
  after_create :create_owner_transaction


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv'] : args)
    CONFIG.object['Hazard'][:fields].values.select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def get_source
    "<a style='font-weight:bold' href='/sras/#{sra.id}'>
      SRA ##{sra.id}
    </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
  end


  def self.get_headers
    if CONFIG::GENERAL[:has_root_causes]
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


  def can_complete?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status == 'New' || form_conds
    user_confirmed = true
    form_confirmed && user_confirmed && !self.root_cause_lock?
  end

  def self.get_avg_complete
    candidates=self.where("status=? and close_date is not ? and created_at is not ?","Completed",nil,nil)
    if candidates.present?
      sum=0
      candidates.map{ |x| sum += (x.close_date.to_date - x.created_at.to_date).to_i }
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end
end
