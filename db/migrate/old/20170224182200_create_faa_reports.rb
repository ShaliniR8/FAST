class CreateFaaReports < ActiveRecord::Migration
  def self.up
    create_table :faa_reports do |t|
      t.integer :year
      t.integer :quarter
      t.string  :faa
      t.string  :company
      t.string  :labor
      t.string  :asap
      t.integer  :asap_submit
      t.integer  :asap_accept
      t.integer  :sole
      t.integer  :asap_close
      t.integer  :asap_emp
      t.integer  :asap_com
      t.timestamps
    end
  end

  def self.down
    drop_table :faa_reports
  end
end
