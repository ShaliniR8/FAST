class Expectation < ActiveRecord::Base
  belongs_to :user, foreign_key:"user_id", class_name:"User"

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "title",             title: "Title",             num_cols: 6,  type: "text",         visible: 'index,form,show',   required: false},
      #{ field: "user_id",           title: "Created By",        num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      #{ field: "analyst_id",        title: "Analyst",           num_cols: 6,  type: "user",         visible: 'form,show',         required: false},
      #{ field: "revision_date",     title: "Revision Date",     num_cols: 6,  type: "date",         visible: 'index,form,show',   required: false},
      #{ field: "revision_level",    title: "Revision Level",    num_cols: 6,  type: "text",         visible: 'form,show',         required: false},
      { field: 'department',        title: 'Department',        num_cols: 6,  type: 'select',       visible: 'index,form,show',   required: false,  options: get_departments},
      { field: "reference_number",  title: "Reference Number",  num_cols: 6,  type: "text",         visible: 'index,form,show',   required: false},
      { field: "reference",         title: "Reference",         num_cols: 12, type: "textarea",     visible: 'index,form,show',   required: false},
      { field: "expectation",       title: "Requirement",       num_cols: 12, type: "textarea",     visible: 'index,form,show',   required: false},
      #{ field: "instruction",       title: "Instructions",      num_cols: 12, type: "textarea",     visible: 'form,show',         required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_departments
    custom_options = CustomOption.where(:title => 'Departments').first
    if custom_options.present?
      custom_options.options.split(';')
    else
      Inspection.get_departments
    end
  end
end
