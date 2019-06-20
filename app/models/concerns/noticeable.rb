module Noticeable
  extend ActiveSupport::Concern
  included do
    has_many :notices,   as: :owner,  dependent: :destroy

    accepts_nested_attributes_for :notices
  end

end
