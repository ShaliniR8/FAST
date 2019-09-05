class RenameCauseOptionsObjects < ActiveRecord::Migration
  def self.up
    CauseOption.transaction do
      CauseOption.where(level: 0).each do |option|
        option[:name] = option[:name].gsub(/Root Causes/, '').strip
        option.save!
      end
    end
  end

  def self.down
    CauseOption.transaction do
      CauseOption.where(level: 0).each do |option|
        option[:name] = "#{option[:name]} Root Causes"
        option.save!
      end
    end
  end

end
