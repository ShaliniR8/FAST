class CreateWbat < ActiveRecord::Migration
  def self.up
    create_table :fields do |t|
      t.string   :data_type
      t.string   :display_type  
      t.string   :label
      t.string   :options
      t.integer  :display_size
      t.integer  :priority   
      t.belongs_to :categories
      t.text     :description
      t.timestamps
    end
    
    create_table :categories do |t|
      t.string   :title
      t.text     :description
      t.belongs_to  :templates
      t.timestamps
    end
    create_table :templates do |t|
      t.integer  :access
      t.string   :name
      t.timestamps
    end

    create_table :record_fields do |t|
      t.string   :value
      t.belongs_to :records   
      t.belongs_to :fields
      t.timestamps
    end

    create_table :records do |t|
      t.string   :status
      t.belongs_to :templates
      t.timestamps
    end
  end
        
  def self.down
    drop_table :fields 
    drop_table :templates
    drop_table :records
    drop_table :record_fields
    drop_table :categories
  end
end