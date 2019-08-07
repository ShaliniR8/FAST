module Sraable
  extend ActiveSupport::Concern

  included do
    has_one :sra,       as: :owner
  end

end
