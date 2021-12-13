module NewsletterAttachmentable
  extend ActiveSupport::Concern
  included do
    has_many :newsletter_attachments, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :newsletter_attachments,
      allow_destroy: true,
      reject_if: Proc.new{|newsletter_attachment| (newsletter_attachment[:name].blank? && newsletter_attachment[:_destroy].blank?)}
  end
end
