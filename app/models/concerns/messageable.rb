module Messageable
  extend ActiveSupport::Concern
  included do
    has_many :messages, as: :owner, class_name: 'Message',  dependent: :destroy

    accepts_nested_attributes_for :messages
  end

end
