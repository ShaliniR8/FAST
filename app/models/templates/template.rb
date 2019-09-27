class Template < ActiveRecord::Base
  has_many          :categories,                  :foreign_key => "templates_id", :class_name => "Category", :dependent => :destroy
  has_many          :records,                     :foreign_key => "templates_id", :class_name => "Record"
  has_many          :fields,                      through: :categories
  belongs_to :map_template,foreign_key:"map_template_id",class_name:"Template"
  belongs_to  :created_by,foreign_key:"users_id",class_name: "User"
  accepts_nested_attributes_for :categories, reject_if: Proc.new{|category| category[:title].blank?}


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "name",               title: "Name",        num_cols: 12, type: "text", visible: 'index,show',   required: false},
      { field: "num_of_categories",  title: "Categories",  num_cols: 10, type: "text", visible: 'index,show',   required: true    },
      { field: "num_of_fields",      title: "Fields",      num_cols: 12, type: "text", visible: 'index,show',   required: false   },
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
