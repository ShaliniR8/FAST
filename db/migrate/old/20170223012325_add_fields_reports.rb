class AddFieldsReports < ActiveRecord::Migration
  def self.up
    add_column :reports,:eir,:string
    add_column :reports,:disposition,:string
    add_column :reports,:company_disposition,:string
    add_column :reports,:scoreboard,:boolean
    add_column :reports,:asap,:boolean
    add_column :report, :sole,:boolean
    add_column :reports,:narrative,:text
    add_column :reports,:regulation,:text
    add_column :reports,:notes,:text
    add_column :reports,:severity,:string
    add_column :reports,:likehood,:string
    add_column :reports,:risk,:string
  end

  def self.down
 
    remove_column :reports,:eir
    remove_column :reports,:disposition
    remove_column :reports,:company_disposition
    remove_column :reports,:scoreboard    
    remove_column :reports,:narrative
    remove_column :reports,:regulation
    remove_column :reports,:notes
    remove_column :reports,:severity
    remove_column :reports,:likehood
    remove_column :reports,:risk
    remove_column :reports,:sole
    remove_column :reports,:asap
  end
end
