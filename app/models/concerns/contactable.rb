module Contactable
  extend ActiveSupport::Concern

  included do
    has_many :contacts, as: :owner, dependent: :destroy
  end

end
