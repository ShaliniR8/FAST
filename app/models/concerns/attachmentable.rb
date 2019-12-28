module Attachmentable
  extend ActiveSupport::Concern
  included do
    has_many :attachments, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :attachments,
      allow_destroy: true,
      reject_if: Proc.new{|attachment| (attachment[:name].blank? && attachment[:_destroy].blank?)}
  end
end
