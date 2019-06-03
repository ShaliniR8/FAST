module Recommendationable
  extend ActiveSupport::Concern

  included do
    has_many :recommendations, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :recommendations
  end

end
