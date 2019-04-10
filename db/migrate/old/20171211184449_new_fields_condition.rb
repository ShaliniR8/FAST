class NewFieldsCondition < ActiveRecord::Migration
  def self.up
    add_column :query_conditions,:template_id,:integer
    add_column :query_conditions,:classname,:string
    add_column :query_conditions,:field_id,:integer
    add_column :query_conditions,:fieldname,:string
  end

  def self.down
  end
end
