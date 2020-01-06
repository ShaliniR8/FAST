module Verifiable
  extend ActiveSupport::Concern

  included do
    has_many :verifications, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :verifications

  end
end
