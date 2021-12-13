module Completable
  extend ActiveSupport::Concern
  included do
    has_many :completions, as: :owner, class_name: 'Completion',  dependent: :destroy

    accepts_nested_attributes_for :completions
  end

end
