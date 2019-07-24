module SmsTaskable
  extend ActiveSupport::Concern

  included do
    has_many :tasks, as: :owner, class_name:'SmsTask', dependent: :destroy

    accepts_nested_attributes_for :tasks
  end

end
