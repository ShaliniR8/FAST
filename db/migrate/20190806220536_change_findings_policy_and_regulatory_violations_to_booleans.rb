class ChangeFindingsPolicyAndRegulatoryViolationsToBooleans < ActiveRecord::Migration
  def self.up
    %w[policy regulatory].each do |type|
      execute "UPDATE findings SET #{type}_violation = IF((#{type}_violation = '1' OR #{type}_violation = 'Yes'), '1', NULL)"
      change_column :findings, "#{type}_violation".to_sym, :boolean, default: false, null: false
    end
  end

  def self.down
    %w[policy regulatory].each do |type|
      change_column :findings, "#{type}_violation".to_sym, :string
      execute "UPDATE findings SET #{type}_violation = IF (#{type}_violation = FALSE, '0', '1')"
    end
  end

end
