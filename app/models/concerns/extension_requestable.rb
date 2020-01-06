module ExtensionRequestable
  extend ActiveSupport::Concern

  included do
    has_many :extension_requests, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :extension_requests

  end
end
