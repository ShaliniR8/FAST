class AddCloseDate < ActiveRecord::Migration

  ADD = {
    :close_date => {
      table: %i[
        audits
        evaluations
        findings
        inspections
        investigations
        recommendations
        risk_controls
        safety_plans
        sms_actions
        sras
      ],
      type: :datetime
    }
  }

  CHANGE = {
    :close_date => {
      table: %i[
        corrective_actions
        hazards
        records
        reports
      ],
      type: :datetime
    }
  }

  def self.up
    ADD.each do |column_name, data|
      data[:table].each do |table_name|
        add_column table_name, column_name, data[:type]
      end
    end

    CHANGE.each do |column_name, data|
      data[:table].each do |table_name|
        change_column table_name, column_name, data[:type]
      end
    end
  end

  def self.down
    ADD.each do |column_name, data|
      data[:table].each do |table_name|
        remove_column table_name, column_name
      end
    end

    CHANGE.each do |column_name, data|
      data[:table].each do |table_name|
        change_column table_name, column_name, :date
      end
    end
  end
end
