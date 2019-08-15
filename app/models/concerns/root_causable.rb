module RootCausable
  extend ActiveSupport::Concern

  included do
    has_many :root_causes, as: :owner, dependent: :destroy

    accepts_nested_attributes_for :root_causes
  end

end
