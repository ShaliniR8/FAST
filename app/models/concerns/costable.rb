module Costable
  extend ActiveSupport::Concern

  included do
    has_many :costs, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :costs
  end

end
