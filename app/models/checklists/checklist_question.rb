# Checklists V2
class ChecklistQuestion < ActiveRecord::Base

  belongs_to :checklist_template, foreign_key: :owner_id, class_name: "ChecklistTemplate"



  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { name: "id",                 description: "ID",                type: "text", visible: '',            required: false,    editable: false   },
      { name: "number",             description: "#",                 type: "text", visible: 'form,show',   required: true  ,   editable: true    },
      { name: "question",           description: "Question",          type: "user", visible: 'form,show',   required: true,     editable: true    },
      { name: "faa_reference",      description: "FAA Reference",     type: "user", visible: 'form,show',   required: false,    editable: true    },
      { name: "airline_reference",  description: "Airline Reference", type: "user", visible: 'form,show',   required: false,    editable: true    },
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end



end
