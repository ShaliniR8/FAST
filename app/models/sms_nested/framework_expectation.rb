class  FrameworkExpectation  < Expectation
  belongs_to :im,foreign_key:"owner_id",class_name:"Im"
  after_create :make_item

  def make_item
    Object.const_get(self.im.type+"Item").create({
      :title=>self.title,
      :department=>self.department,
      :owner_id=>self.owner_id,
      :reference_number=>self.reference_number,
      :revision_level=>self.revision_level,
      :revision_date=>self.revision_date,
      :instructions=>self.instruction,
      :user_id=>self.user_id,
      :reference=>self.reference,
      :requirement=>self.expectation,
      :status=>self.im.status
    })
  end
end
