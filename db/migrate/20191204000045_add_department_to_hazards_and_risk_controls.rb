class AddDepartmentToHazardsAndRiskControls < ActiveRecord::Migration

  TABLES = {
    department: {
      table: %i[
        hazards
        risk_controls
      ],
      type: :text
    }
  }

  def self.up
    TABLES.each do |column_name, data|
      data[:table].each do |table_name|
        add_column table_name, column_name, data[:type]
      end
    end
  end

  def self.down
    TABLES.each do |column_name, data|
      data[:table].each do |table_name|
        remove_column table_name, column_name
      end
    end
  end
end
