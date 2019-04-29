class Privilege < ActiveRecord::Base

  has_many :assignments, foreign_key: "privileges_id", class_name: "Assignment", :dependent => :destroy
  has_many :roles, foreign_key: "privileges_id", class_name: "Role", :dependent => :destroy

  has_many :access_controls, through: :assignments



  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'id',           title: 'ID',            size: '5%',   type: 'text',     visible: 'index,show',      required: false},
      {field: 'name',         title: 'Title',         size: '20%',  type: 'text',     visible: 'index,form,show', required: true},
      {field: 'description',  title: 'Description',   size: '25%',  type: 'textarea', visible: 'index,form,show', required: false},
      {field: 'example',      title: 'User Example',  size: '20%',  type: 'textarea', visible: 'index,form,show', required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end



  def self.get_headers
    {
      "ID"=>"id",
      "Name"=>"name",
      "Description"=>"description",
      "User Example"=>"example"
    }
  end



  def control_ids
    if self.assignments.present?
      self.assignments.map{|x|  x.access_control.id}
    else
      []
    end
  end



  def users
    if self.roles.present?
      self.roles.map{|x| x.user}
    else
      []
    end
  end


end
