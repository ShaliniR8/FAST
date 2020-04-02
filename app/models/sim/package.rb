class Package < ActiveRecord::Base
  extend AnalyticsFilters

#Concern List
  include Attachmentable
  include Transactionable
  include Noticeable

#Associations List
  has_many :sms_agendas,    foreign_key:"event_id",   class_name:"SmsAgenda",            :dependent=>:destroy

  belongs_to :meeting,      foreign_key:"meeting_id", class_name:"Meeting"


  after_create :create_transaction


  def self.get_terms
    {
      "Status"=>"status",
      "Title" => "title",
      "Requested Level of Compliance" => "level_of_compliance",
      "Plan Due Date" => "get_plan_due_date",
      "Statement of Compliance" => "statement",
      "Gap Description" => "description",
      "Plan" => "plan",
      "Responsibility" => "responsibility"
    }
  end


  def get_plan_due_date
    if self.plan_due_date.present?
      self.plan_due_date.strftime("%Y-%m-%d")
    else
      ""
    end
  end


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      { field: 'id',                  title: 'ID',                            num_cols: 6,  type: 'text',      visible: 'index,show',      required: false },
      { field: 'title',               title: 'Title',                         num_cols: 6,  type: 'text',      visible: 'index,form,show', required: true },
      { field: 'level_of_compliance', title: 'Requested Level of Compliance', num_cols: 6,  type: 'select',    visible: 'index,form,show', required: true, options:['Note Performed','Planned','Documented','Implemented','Demonstrated','Not Applicable'] },
      { field: 'statement',           title: 'Statement of Compliance',       num_cols: 12, type: 'textarea',  visible: 'form,show',       required: false },
      { field: 'description',         title: 'Gap Description',               num_cols: 12, type: 'textarea',  visible: 'form,show',       required: false },
      { field: 'plan',                title: 'Plan',                          num_cols: 12, type: 'textarea',  visible: 'form,show',       required: false },
      { field: 'responsibility',      title: 'Responsibility',                num_cols: 12, type: 'textarea',  visible: 'form,show',       required: false },
      { field: 'plan_due_date',       title: 'Plan Due Date',                 num_cols: 6,  type: 'date',      visible: 'form,show',       required: false },
      { field: 'comment',             title: 'Evaluator Comment',             num_cols: 12, type: 'textarea',  visible: 'form,show',       required: false }
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_fields
    [
      {:title=>"Title",                           :field=>"title",                :type=>"text_field",    :class=>"form-control",:size=>"8"},
      {:title=>"Requested Level of Compliance",   :field=>"level_of_compliance",  :type=>"select",        :class=>"form-control",:options=>["Not Performed",'Planned','Documented','Implemented','Demonstrated','Not Applicable'],:size=>"4"},
      {:title=>"Statement of Compliance",         :field=>"statement",            :type=>"text",          :class=>"form-control"},
      {:title=>"Gap Description",                 :field=>"description",          :type=>"text",          :class=>"form-control"},
      {:title=>"Plan",                            :field=>"plan",                 :type=>"text",          :class=>"form-control"},
      {:title=>"Responsibility",                  :field=>"responsibility",       :type=>"text",          :class=>"form-control"},
      {:title=>"Plan Due Date",                   :field=>"plan_due_date",        :type=>"text_field",    :class=>"form-control field-date",:size=>"4"},
      {:title=>"Evaluator Comment",               :field=>"comment",              :type=>"text",          :class=>"form-control"}
    ]
  end


  def self.get_headers
    [
      {:field=>"get_id", :title=>"ID"},
      {:title=>"Title",:field=>"title"},
      {:title=>"Requested Level of Compliance",:field=>"level_of_compliance"},
      {:title=>"Plan Due Date",:field=>"plan_due_date"},
      {:title=>"Status",:field=>"status"}
    ]
  end


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def self.show_fields
    [
      {:title=>"Title",:field=>"title",:long_text=>false,:size=>"4"},
      {:title=>"Requested Level of Compliance",:field=>"level_of_compliance",:long_text=>false,:size=>"4"},
      {:title=>"Plan Due Date",:field=>"plan_due_date",:size=>"4",:long_text=>false},
      {:title=>"Statement of Compliance",:field=>"statement",:type=>"text",:long_text=>true},
      {:title=>"Gap Description",:field=>"description",:type=>"text",:long_text=>true},
      {:title=>"Plan",:field=>"plan",:type=>"text",:long_text=>true},
      {:title=>"Responsibility",:field=>"responsibility",:long_text=>true},
      {:title=>"Evaluator Comment",:field=>"comment",:long_text=>true},
      {:title=>"Meeting Minutes",:field=>"minutes",:long_text=>true}
    ]
  end


  def get_time(field)
    if self.send(field).present?
      self.send(field).strftime("%Y-%m-%d %H:%M")
    else
      ""
    end
  end


  def self.get_avg_complete
    candidates=self.where("status=? and date_complete is not ?","Completed",nil)
    if candidates.present?
      sum=0
      candidates.map{|x|
        if x.date_complete.present? && x.created_at.present?
          sum+=(x.date_complete-x.created_at.to_date).to_i
        end
      }
      result= (sum.to_f/candidates.length.to_f).round(1)
      result
    else
      "N/A"
    end
  end


end
