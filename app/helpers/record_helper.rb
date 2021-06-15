module RecordHelper
  def get_category_tag(category)
    category.title.underscore.parameterize("_") rescue 'no_name'
  end


  def get_field_tag(field)
    return 'no_name' if field.export_label.blank?
    field.export_label.gsub('&amp;', 'and').gsub(/[^0-9A-Za-z_]/, '')
  end
end
