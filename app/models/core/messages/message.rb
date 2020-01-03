class Message < ActiveRecord::Base

#Concerns List
  include Attachmentable
  include Noticeable

#Associations List
  belongs_to :owner,  polymorphic: true
  belongs_to :response,          foreign_key: "response_id",         class_name: "Message"
  has_many :dialogs,             foreign_key: "response_id",         class_name: "Message"

  has_one :send_from,            foreign_key: "messages_id",         class_name: "SendFrom"
  has_many :send_to,             foreign_key: "messages_id",         class_name: "SendTo"
  has_many :cc,                  foreign_key: "messages_id",         class_name: "CC"


  def getAll(att)
    if att == "send_from"
      self.send(att).getName
    else
      self.send(att).map{|x| x.getName}.join(", ")
    end
  end


  def getDialogs
    result=[self]
    if self.dialogs.empty?
      Rails.logger.debug "Message #{self.id} has no dialogs"
      result
    else
      self.dialogs.each do |d|
        result.concat(d.getDialogs)
      end
      result.sort_by!{|x| x.id}
    end
  end


  def getPrev
    result = [self]
    if self.response.present?
      result.concat(self.response.getPrev).sort_by!{|x| !x.id}
    else
      result.sort_by!{|x| x.id}
    end
  end


  def get_time
    self.time.in_time_zone(Time.zone).strftime("%Y-%m-%d %H:%M:%S") rescue ''
  end
end
