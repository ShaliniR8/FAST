# Checklists V3
class ChecklistTemplate < ActiveRecord::Base

  has_many :checklist_questions, foreign_key: :owner_id, dependent: :destroy

  belongs_to :creator, foreign_key: :created_by, class_name: "User"

  accepts_nested_attributes_for :checklist_questions, reject_if: :all_blank, allow_destroy: true


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "id",          title: "ID",            num_cols: 12, type: "text",     visible: 'index,show',        required: false},
      { field: "name",        title: "Template Name", num_cols: 10, type: "text",     visible: 'index,form,show',   required: true    },
      { field: "created_by",  title: "Created By",    num_cols: 12, type: "user",     visible: 'index,show',        required: false   },
      { field: "notes",       title: "Notes",         num_cols: 10, type: "textarea", visible: 'index,form,show',   required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  # Create checklist records from checklist template
  def create_checklist_records(owner_class, owner_id)
    @class_name = Object.const_get("#{owner_class}ChecklistRecord")
    checklist_questions.where(archive: 0).each do |question|
      @class_name.create(
        :owner_id => owner_id,
        :number => question.number,
        :question => question.question,
        :faa_reference => question.faa_reference,
        :airline_reference => question.airline_reference,
        :header => question.header
      )
    end
  end

end
