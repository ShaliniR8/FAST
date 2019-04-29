class RiskMatrixTable < ActiveRecord::Base

  belongs_to :group, :foreign_key => "group_id",    :class_name => "RiskMatrixGroup"

  has_many  :risk_matrix_cells,   :foreign_key => "table_id",  :class_name => "RiskMatrixCell", :dependent => :destroy


  accepts_nested_attributes_for :risk_matrix_cells

  def column_header
    risk_matrix_cells.select{|x| x.table_row == 0}
  end

  def row_header
    risk_matrix_cells.select{|x| x.table_column == 0 && x.table_row != 0}
  end

  def get_row(row_num)
    risk_matrix_cells.select{|x| x.table_row == row_num}
  end

  def row_num
    risk_matrix_cells.map(&:table_row).uniq.sort_by{|x| x} || 0
  end

  def column_num
    risk_matrix_cells.map(&:table_column).uniq.sort_by{|x| x} || 0
  end

  def add_row
    row_index = row_num.max + 1
    column_num.each do |x|
      cell = RiskMatrixCell.create(:table_row => row_index, :table_column => x, :table_id => id, :created_at => Time.now, :updated_at => Time.now)
      cell.table = self
      cell.save
    end
    if name == "severity"
      risk_table = self.group.risk_table
      risk_table.column_num.each do |x|
        if x != 0
          cell = RiskMatrixCell.create(:table_row => risk_table.row_num.max+1, :table_column => x, :table_id => risk_table.id, :created_at => Time.now, :updated_at => Time.now)
          cell.table = risk_table
          cell.save
        end
      end
    end
  end


  def add_column
    col_index = column_num.max + 1
    row_num.each do |x|
      cell = RiskMatrixCell.create(:table_row => x, :table_column => col_index, :table_id => id, :created_at => Time.now, :updated_at => Time.now)
      cell.table = self
      cell.save
    end
    if name == "probability"
      risk_table = self.group.risk_table
      risk_table.row_num.each do |x|
        if x != 0
          cell = RiskMatrixCell.create(:table_row => x, :table_column => risk_table.column_num.max+1, :table_id => risk_table.id, :created_at => Time.now, :updated_at => Time.now)
          cell.table = risk_table
          cell.save
        end
      end
    end
  end

end
