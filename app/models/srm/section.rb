class Section < ActiveRecord::Base

  belongs_to :template,   :foreign_key => "template_id", :class_name => "Template"
  belongs_to :assignee,   :foreign_key => "assignee_id", :class_name => "User"
  belongs_to :approver,   :foreign_key => "approver_id", :class_name => "User"

  has_many :section_fields, :foreign_key => "section_id", :class_name => "SectionField",  :dependent => :destroy


  accepts_nested_attributes_for :section_fields


  after_create :post_creation


  def post_creation
    self.template.fields.each do |field|
      section_field = SectionField.new(:section_id => self.id, :field_id => field.id)
      section_field.save
    end
    #notify(self.assignee, Time.now + 7.days, "A new section has been assigned to you.", "Section", self.id, "assign")
  end


  def panel_color(current_user)
    if status != "Approved" && status != "Completed" && assignee == current_user
      "danger"
    elsif status == "Completed" && approver == current_user
      "danger"
    else
      "info"
    end
  end


  def self.get_headers
    [
      {:field => "id",            :title => "ID"},
      {:field => "title",         :title => "Title"},
    ]
  end


  def self.build(template)
    record = self.new()
    record.template_id = template.id
    record
  end


  def categories
    self.template.categories
  end

end
