class PolymorphicFindings < ActiveRecord::Migration
  def self.up
    [
      'Audit',
      'Inspection',
      'Evaluation',
      'Investigation'
    ].each do |type|
      execute "update findings set type = replace(type, '#{type}Finding', '#{type}')"
    end
    rename_column :findings, :type, :owner_type
    rename_column :findings, :audit_id, :owner_id
  end

  def self.down
    [
      'Audit',
      'Inspection',
      'Evaluation',
      'Investigation'
    ].each do |type|
      execute "update findings set owner_type = replace(owner_type, '#{type}', '#{type}Finding')"
    end
    rename_column :findings, :owner_type, :type
    rename_column :findings, :owner_id, :audit_id
  end
end
