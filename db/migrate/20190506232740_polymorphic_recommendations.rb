class PolymorphicRecommendations < ActiveRecord::Migration
  def self.up
    [
      'Investigation',
      'Finding'
    ].each do |type|
      execute "update recommendations set type = replace(type, '#{type}Recommendation', '#{type}')"
    end
    rename_column :recommendations, :type, :owner_type
  end

  def self.down
    [
      'Investigation',
      'Finding'
    ].each do |type|
      execute "update recommendations set owner_type = replace(owner_type, '#{type}', '#{type}Recommendation')"
    end
    rename_column :recommendations, :owner_type, :type
  end
end
