class Parent < ActiveRecord::Base
  belongs_to :owner, polymorphic: true
  belongs_to :parent, polymorphic: true
end
