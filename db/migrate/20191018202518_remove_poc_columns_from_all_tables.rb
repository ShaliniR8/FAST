class RemovePocColumnsFromAllTables < ActiveRecord::Migration

  TABLES = {
    user_poc_id: {
      table: %i[
        agendas
        corrective_actions
        message_accesses
        recommendations
        sms_actions
        transactions
      ],
      type: :integer
    },
    approver_poc_id: {
      table: %i[
        audits
        evaluations
        findings
        inspections
        investigations
        sms_actions
      ],
      type: :integer
    },
    poc_id: {
      table: %i[
        participations
        users
      ],
      type: :integer
    },
    auditor_poc_id: {
      table: %i[
        audits
      ],
      type: :integer
    },
    evaluator_poc_id: {
      table: %i[
        evaluations
      ],
      type: :integer
    },
    responsible_user_poc_id: {
      table: %i[
        findings
      ],
      type: :integer
    },
    lead_evaluator_poc_id: {
      table: %i[
        ims
      ],
      type: :integer
    },
    pre_reviewer_poc_id: {
      table: %i[
        ims
      ],
      type: :integer
    },
    investigator_poc_id: {
      table: %i[
        investigations
      ],
      type: :integer
    },
    poc_first_name: {
      table: %i[
        transactions
      ],
      type: :string
    },
    poc_last_name: {
      table: %i[
        transactions
      ],
      type: :string
    },
  }

  def self.up
    TABLES.each do |column_name, data|
      data[:table].each do |table_name|
        remove_column table_name, column_name
      end
    end
  end

  def self.down
    TABLES.each do |column_name, data|
      data[:table].each do |table_name|
        add_column table_name, column_name, data[:type]
      end
    end
  end
end
