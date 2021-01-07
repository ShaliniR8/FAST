class Hazard < Srm::SafetyRiskManagementBase
  extend AnalyticsFilters
  include StandardWorkflow
  include ModelHelpers
  include RiskHandling

#Concerns List
  include Attachmentable
  include Commentable
  include Transactionable
  include RootCausable
  include ExtensionRequestable
  include Verifiable
  include Childable
  include Parentable

#Associations List
  belongs_to :sra,                :foreign_key => "sra_id",                 :class_name => "Sra"
  belongs_to :responsible_user,   :foreign_key => "responsible_user_id",    :class_name => "User"
  belongs_to :created_by,         :foreign_key => "created_by_id",          :class_name => "User"
  belongs_to :approver,           :foreign_key => 'approver_id',            :class_name => 'User'

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


  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show', 'adv', 'admin'] : args)
    keys = CONFIG.object['Hazard'][:fields].select { |key,val| (val[:visible].split(',') & visible_fields).any? }
                                           .map { |key, _| key.to_s }

    keys[keys.index('source')] = 'owner_id' # TODO: find a way
    keys[keys.index('responsible_user')] = 'responsible_user_id' # TODO: connect User table to get full name
    keys[keys.index('verifications')] = 'verifications.address_comment'

    keys
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
    CONFIG.custom_options['Manuals']
    # custom_options = CustomOption.where(:title => "Manuals").first
    # if custom_options.present?
    #   custom_options.options.split(";")
    # else
    #   [
    #     'Inadequate development / implementation of policy or procedure',
    #     'Inadequate training',
    #     'Inadequate training materials',
    #     'Lack of or inadequate policy or procedure',
    #     'Emotional overload',
    #     'Extreme judgement decisions/demands',
    #     'Preoccupation with problems',
    #     'Other'
    #   ]
    # end
  end

  def get_due_date
    self.due_date.present? ? self.due_date.strftime("%Y-%m-%d") : ""
  end
end
