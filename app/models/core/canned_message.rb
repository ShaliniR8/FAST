class CannedMessage < ActiveRecord::Base


  validates_uniqueness_of :name, :case_sensitive => false, :message => " has already been taken."
  validates_presence_of :name, :message => " cannot be empty."

  def self.get_headers
    [
      {:title => "ID",        :field => :id},
      {:title => "Name",      :field => :name},
      {:title => "Content",   :field => "short_content"},
    ]
  end


  def short_content
    if content.length > 50
      content[0..50] + "..."
    else
      content
    end
  end


end
