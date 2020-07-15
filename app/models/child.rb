class Child < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :child, polymorphic: true
end
