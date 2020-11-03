class SetViewerAccessEnabledDefaultToTrue < ActiveRecord::Migration
  def self.up
    change_column :records, :viewer_access, :boolean, default: true

    records = Record.all
    records.each { |r| r.viewer_access = true }

    Record.transaction do
      records.each(&:save!)
    end
  end

  def self.down
    change_column :records, :viewer_access, :boolean, default: false

    records = Record.all
    records.each { |r| r.viewer_access = false }

    Record.transaction do
      records.each(&:save!)
    end
  end

end
