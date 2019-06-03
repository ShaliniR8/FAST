module Commentable
  extend ActiveSupport::Concern
  included do
    has_many :comments,   as: :owner, class_name: 'ViewerComment',  dependent: :destroy

    accepts_nested_attributes_for :comments
  end

end
