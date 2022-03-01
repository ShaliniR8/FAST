module Subscriptionable

  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :owner, dependent: :destroy
    accepts_nested_attributes_for :subscriptions, allow_destroy: true
  end

end
