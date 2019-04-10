class AddTemplateReport < ActiveRecord::Migration
  def self.up
  	change_table :reports do |t|
      t.belongs_to  :templates
    end
  end

  def self.down
  	remove_columns :reoports, :templates_id
  end
end
