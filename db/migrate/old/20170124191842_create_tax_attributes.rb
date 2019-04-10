class CreateTaxAttributes < ActiveRecord::Migration
  def self.up
    create_table :tax_attributes do |t|
	t.string :category
	t.string :label
	t.string :url_reference
        t.text   :definition
        t.string :control_class
        t.string :source
    end
  end

  def self.down
    drop_table :tax_attributes
  end
end
