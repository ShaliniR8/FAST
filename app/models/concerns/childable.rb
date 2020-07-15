module Childable
  extend ActiveSupport::Concern
  included do
    has_many :children, :as => :owner
  end
end
