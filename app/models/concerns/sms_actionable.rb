module SmsActionable
  extend ActiveSupport::Concern

  included do
    has_many :corrective_actions, as: :owner, class_name: 'SmsAction',  dependent: :destroy

    accepts_nested_attributes_for :corrective_actions
  end

end
