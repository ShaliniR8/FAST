class AllExtraMatrix < ActiveRecord::Migration
  def self.up
    add_column :investigations,:severity_extra,:string
    add_column :investigations,:probability_extra,:string
    add_column :sras,:severity_extra,:string
    add_column :sras,:probability_extra,:string
    add_column :reports,:severity_extra,:string
    add_column :reports,:probability_extra,:string
    add_column :records,:severity_extra,:string
    add_column :records,:probability_extra,:string
    add_column :hazards,:severity_extra,:string
    add_column :hazards,:probability_extra,:string
  end

  def self.down
  end
end
