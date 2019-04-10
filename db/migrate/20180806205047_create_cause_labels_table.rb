class CreateCauseLabelsTable < ActiveRecord::Migration
  def self.up
    create_table "cause_options", :force => true do |t|
	t.string "name", :null => false
    end

    create_table "cause_options_connections", :force => true, :id => false do |t|
        t.integer "cause_option_1_id", :null => false
        t.integer "cause_option_2_id", :null => false
    end
  end

  def self.down
  end
end
