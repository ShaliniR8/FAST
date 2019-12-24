module Occurrenceable
  extend ActiveSupport::Concern

  included do
    has_many :occurrences, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :occurrences
  end

end
