class Template < ActiveRecord::Base
  has_many          :categories,                  :foreign_key => "templates_id", :class_name => "Category", :dependent => :destroy, order: 'category_order ASC'
  has_many          :records,                     :foreign_key => "templates_id", :class_name => "Record"
  has_many          :fields,                      through: :categories
  belongs_to :map_template, foreign_key:"map_template_id", class_name:"Template"
  belongs_to  :created_by, foreign_key:"users_id", class_name: "User"
  accepts_nested_attributes_for :categories, reject_if: Proc.new{|category| category[:title].blank?}


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "id",                 title: "ID",          num_cols: 12, type: "text", visible: 'index,show',   required: false},
      { field: "name",               title: "Name",        num_cols: 12, type: "text", visible: 'index,show',   required: false},
      { field: "num_of_categories",  title: "Categories",  num_cols: 10, type: "text", visible: 'index,show',   required: true},
      { field: "num_of_fields",      title: "Fields",      num_cols: 12, type: "text", visible: 'index,show',   required: false},
      { field: "num_of_records",     title: "Records",     num_cols: 10, type: "text", visible: 'index,show',   required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_headers
    [
      #{:field => "id",                               :title => "ID"},
      {:field => "name" ,                             :title => "Name"},
      {:field => "num_of_categories",                 :title => "Categories"},
      {:field => "num_of_fields",                     :title => "Fields"},
      {:field => "num_of_records",                    :title => "Records"},
      #{:field => "status",                           :title => "Status"},
      #{:field => "updated" ,                         :title => "Last Update"}
    ]
  end

  def make_copy
    source_template = self
    target_template = Template.create(name: self.name + ' -- copy')
    target_template.update_attributes(users_id: self.users_id)

    AccessControl.get_template_opts.map { |disp, db_val|
      AccessControl.new({
        list_type: 1,
        action: db_val,
        entry: target_template.name,
        viewer_access: 1
      }).save
    }

    if source_template.map_template_id.present?
      source_template.map_template_id = target_template.id
      target_template.map_template_id = source_template.id
    end

    target_template_id = target_template.id
    source_template_id = self.id

    source_categories = Category.where(templates_id: source_template_id, deleted: 0)
    source_categories.each do |category|
      source_category_id = category.id
      target_category =
        Category.create(title: category.title,
                        templates_id: target_template_id,
                        description: category.description,
                        panel: category.panel,
                        print: category.print,
                        category_order: category.category_order)

      target_category_id = target_category.id

      source_fields = Field.where(categories_id: source_category_id, deleted: 0)
      source_fields = source_fields.select { |x| x.nested_field_id.nil? || !Field.find(x.nested_field_id).deleted }
      nested_field_ids_map = {}

      source_fields.each do |field|

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
                     map_id: field.id,
                     element_id: field.element_id,
                     element_class: field.element_class,
                     field_order: field.field_order,
                     required: field.required,
                     nested_field_id: field.nested_field_id,
                     nested_field_value: field.nested_field_value)

        field.map_id = target_field.id
        field.save

        field.nested_fields.each do |nested_field|
          nested_field_ids_map[nested_field.id] = target_field.id
        end

        target_field.update_attributes(nested_field_id: nested_field_ids_map[field.id])

      end
    end

    target_template
  end

  def status
    archive ? "Archived" : "Active"
  end

  def self.get_all
  end
  def num_of_records
    self.records.size
  end
  def num_of_fields
    total=0
    self.categories.map {|c| total+=c.fields.size}
    total
  end
  def num_of_categories
    self.categories.size
  end

  def owner
    if self.created_by.present?
      self.created_by.full_name
    else
      ""
    end
  end
  def updated
    updated_at.strftime("%Y-%m-%d")
  end
end
