class ChecklistItem < ActiveRecord::Base
  belongs_to :submitter,foreign_key:"user_id",class_name:"User"
  has_many :packages,foreign_key: "owner_id",class_name: "Package"
  accepts_nested_attributes_for :packages


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      {field: "title",                title: "Title",               num_cols: 6,  type: "text",       visible: 'index,form,show', required: false},
      {field: 'department',           title: 'Department',          num_cols: 6,  type: 'text',       visible: 'index,form,show', required: false},
      {field: "reference_number",     title: "Reference Number",    num_cols: 6,  type: "text",       visible: 'index,form,show', required: false},
      {field: "reference",            title: "Reference",           num_cols: 12, type: "textarea",   visible: 'index,form,show', required: false},
      {field: "requirement",          title: "Requirement",         num_cols: 12, type: "textarea",   visible: 'index,form,show', required: false},
      {field: "status",               title: "Status",              num_cols: 12, type: 'select',     visible: 'index,show',      required: false},
      {field: "level_of_compliance",  title: "Level of Compliance", num_cols: 12, type: 'select',     visible: 'index,show',      required: false},
      {field: "comment",              title: "Comment",             num_cols: 12, type: 'textarea',   visible: 'index,show',      required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_headers
    [
      {:field=>"title",:title=>"Title"},
      {:field=>"department",:title=>"Department"},
      {:field=>"reference_number",:title=>"Reference Number"},
      {:field=>"requirement",:title=>"Requirement"},
      {:field=>"level_of_compliance",:title=>"Level of Compliance"},
      {:field=>"status",:title=>"Status"}
    ]
  end


  def get_revision_date
    self.revision_date.present? ?   self.revision_date.strftime("%Y-%m-%d")  : ""
  end
end
