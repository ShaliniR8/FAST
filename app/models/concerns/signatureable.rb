module Signatureable
  extend ActiveSupport::Concern
  included do
    has_many :signatures, as: :owner,    dependent: :destroy

    accepts_nested_attributes_for :signatures,
      allow_destroy: true,
      reject_if: Proc.new{|signature| (signature[:signee_name].blank? && signature[:_destroy].blank?)}
  end
end
