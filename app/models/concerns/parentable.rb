module Parentable
  extend ActiveSupport::Concern
  included do
    has_many :parents, :as => :owner
  end

  def get_parent
    self.parents[0].parent rescue ''
  end
end
