module Findingable
  extend ActiveSupport::Concern

  included do
    has_many :findings, as: :owner,      dependent: :destroy

    accepts_nested_attributes_for :findings
  end

end
