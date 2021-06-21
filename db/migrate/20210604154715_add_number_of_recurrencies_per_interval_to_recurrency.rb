class AddNumberOfRecurrenciesPerIntervalToRecurrency < ActiveRecord::Migration
  def self.up
    add_column :recurrences, :number_of_recurrencies_per_interval, :integer, :default => 1
    change_column :recurrences, :number_of_recurrencies_per_interval, :integer, :default => 1
  end

  def self.down
    remove_column :recurrences, :number_of_recurrencies_per_interval
  end
end
