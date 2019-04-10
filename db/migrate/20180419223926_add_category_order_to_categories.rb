class AddCategoryOrderToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :category_order, :integer
  end

  def self.down
    remove_column :categories, :category_order
  end
end
