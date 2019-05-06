module Contactable
  extend ActiveSupport::Concern

  included do
    has_many :contacts, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :contacts
  end

end
