class PolymorphicSmsActions < ActiveRecord::Migration
  def self.up
    [
      'Investigation',
      'Finding'
    ].each do |type|
      execute "update sms_actions set type = replace(type, '#{type}Action', '#{type}')"
    end
    rename_column :sms_actions, :type, :owner_type
  end

  def self.down
    [
      'Investigation',
      'Finding'
    ].each do |type|
      execute "update sms_actions set owner_type = replace(owner_type, '#{type}', '#{type}Action')"
    end
    rename_column :sms_actions, :owner_type, :type
  end
end
