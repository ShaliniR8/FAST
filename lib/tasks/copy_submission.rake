desc "Copy submissions"
task :copy_submission => :environment do

  # print ' > Enter the template name you want to clone: '
  # template_name = STDIN.gets.strip

  template_name = 'Ground Incident'
  source_template = Template.where(name: template_name)

  if source_template.length == 1

    # 1) create the new template with given name
    target_name = 'Ground Safety'
    target_template = Template.create(name: target_name)
    target_template.update_attributes(users_id: source_template[0].users_id)
    target_template_id = target_template.id



    p "(info) Target template id: #{target_template_id}"

    # 2) find the template_id that you want to copy from
    source_template_id = source_template[0].id
    p "(info) Template [#{source_template[0].name}] id: #{source_template_id}"

    # 3) find the categories by template_id
    source_categories = Category.where(templates_id: source_template_id, deleted: 0)
    source_categories.each do |category|
      # 4) clone the categories for the target template
      source_category_id = category.id
      target_category =
        Category.create(title: category.title,
                        templates_id: target_template_id,
                        panel: category.panel,
                        print: category.print,
                        category_order: category.category_order)

      target_category_id = target_category.id
      p " > [#{category.title}] is cloned from #{source_category_id} to #{target_category_id} (categories)."

      # 5) find the fields by categories_id
      source_fields = Field.where(categories_id: source_category_id, deleted: 0)
      source_fields.each do |field|
        # 6) clone the field for the target field
        target_field =
          Field.create(categories_id: target_category_id,
                       data_type: field.data_type,
                       display_type: field.display_type,
                       label: field.label,
                       options: field.options,
                       display_size: field.display_size,
                       priority: field.priority,
                       description: field.description,
                       show_label: field.show_label,
                       print: field.print,
                       convert_id: field.convert_id,
                       map_id: field.map_id,
                       element_id: field.element_id,
                       element_class: field.element_class,
                       field_order: field.field_order,
                       required: field.required,
                       nested_field_id: field.nested_field_id,
                       nested_field_value: field.nested_field_value)

        p "    > [#{field.label}] is cloned from #{field.id} to #{target_field.id} (fields)."
      end
    end
  end
end
