module Investigationable
  extend ActiveSupport::Concern

  included do
    has_one :investigation,      as: :owner
  end

end
