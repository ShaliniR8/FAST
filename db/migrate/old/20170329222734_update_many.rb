class UpdateMany < ActiveRecord::Migration
  def self.up
     rename_column :reports,:likehood,:likelihood
     add_column :audits,:auditor_1_id,:integer
     add_column :audits,:auditor_2_id,:integer
     add_column :audits,:auditor_3_id,:integer
     add_column :audits,:auditor_4_id,:integer
     add_column :audits,:auditor_5_id,:integer
  end

  def self.down
  end
end
