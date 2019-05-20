class OrmTemplate < ActiveRecord::Base

  has_many :orm_fields,       :foreign_key => "orm_template_id",  :class_name => "OrmField",      :dependent => :destroy
  has_many :orm_submissions,  :foreign_key => "orm_template_id",  :class_name => "OrmSubmission",   :dependent => :destroy

  belongs_to :user,           :foreign_key => "created_by",       :class_name =>  "User"

  accepts_nested_attributes_for :orm_fields, reject_if: Proc.new{ |orm_field| orm_field[:name].blank?}


  def self.get_headers
    [
      {:field => "id",        :title => "ID"},
      {:field => "name",      :title => "Title"},
      {:field => :created,    :title => "Created At"},
      {:field => :updated,    :title => "Updated At"},
    ]
  end

  def created
    self.created_at.strftime("%Y-%m-%d")
  end

  def updated
    self.updated_at.strftime("%Y-%m-%d")
  end


end
