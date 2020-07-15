module Parentable
  extend ActiveSupport::Concern
  included do
    has_many :parents, :as => :owner
  end
end
