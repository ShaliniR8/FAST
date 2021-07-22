# Checklist V3
class Checklist < ActiveRecord::Base

  belongs_to :owner, polymorphic: true
  belongs_to :checklist_header, foreign_key: :checklist_header_id, class_name: "ChecklistHeader"

  has_many :checklist_rows, foreign_key: :checklist_id, dependent: :destroy, order: 'row_order'

  accepts_nested_attributes_for :checklist_rows, allow_destroy: true

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',    title: 'ID',    num_cols: 12,  type: 'text', visible: 'index,show',      required: false},
      {field: 'title', title: 'Title', num_cols: 12,  type: 'text', visible: 'index,form,show', required: true},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def assignees
    User.where(id: (self.assignee_ids || "").split(',').map(&:to_i))
  end

  def get_headers
    self.checklist_header.checklist_header_items.order('display_order')
  end

  def get_contents
    contents = []
    self.checklist_rows.order(:id).each do |checklist_row|
      # next if checklist_row.is_header
      content = {}
      checklist_row.checklist_cells.order{ |x| x.checklist_header_item.display_order }.each do |checklist_cell|
        content[checklist_cell[:checklist_header_item_id]] = checklist_cell.value
      end
      contents << content
    end
    contents
  end

  def assign_row_orders
    count = 1
    self.checklist_rows.order(:id).each do |checklist_row|
      checklist_row.row_order = count
      count += 1
      checklist_row.save
    end
  end

  def row_orders_updated?
    checklist_rows.map(&:row_order).uniq != [1000]
  end

  def update_row_orders
    if row_orders_updated?
      # get last row_order
      orders = checklist_rows.select { |row| row.row_order != 1000}.map(&:row_order)
      count = orders.max + 1
      # assign row order
      checklist_rows.where(row_order: 1000).order(:id).each do |row|
        row.row_order = count
        count += 1
        row.save
      end
    else
      assign_row_orders
    end
  end

end
