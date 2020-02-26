class OrmField < ActiveRecord::Base
  belongs_to :owner, :foreign_key => "orm_template_id", :class_name => "OrmTemplate"
end
