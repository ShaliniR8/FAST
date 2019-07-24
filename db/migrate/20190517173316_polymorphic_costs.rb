class PolymorphicCosts < ActiveRecord::Migration
  def self.up
    [
      ['Investigation','Investigation'],
      ['Action','SmsAction'],
      ['Control','RiskControl']
    ].each do |type|
      execute "update costs set type = replace(type, '#{type[0]}Cost', '#{type[1]}')"
    end
    rename_column :costs, :type, :owner_type
  end

  def self.down
    [
      ['Investigation','Investigation'],
      ['Action','SmsAction'],
      ['Control','RiskControl']
    ].each do |type|
      execute "update costs set owner_type = replace(owner_type, '#{type[1]}', '#{type[0]}Cost')"
    end
    rename_column :costs, :owner_type, :type
  end
end
