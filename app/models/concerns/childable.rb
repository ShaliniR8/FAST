module Childable
  extend ActiveSupport::Concern
  included do
    has_many :children, :as => :owner
  end

  def get_children(child_type:)
    self.children.select { |child| child.child.class.name == child_type}.map do |child|
      child.child
    end
  end
end
