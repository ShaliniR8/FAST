module ModelHelpers
  extend ActiveSupport::Concern
  # This set of terms are for common functions used by models and other sources.

  # Use the following to include these into the model:
  #  include ModelHelpers


  #######################
  ###  CLASS METHODS  ###
  #######################
  included do

    def self.get_avg_complete
      candidates = self.where('status = ? and complete_date is not ? and open_date is not ? ', 'Completed', nil, nil)
      if candidates.present?
        sum = 0
        candidates.map{|x| sum += (x.complete_date - x.open_date).to_i}
        result = (sum.to_f / candidates.length.to_f).round(1)
        result
      else
        'N/A'
      end
    end


    def self.get_custom_options(title)
      CustomOption
        .where(:title => title)
        .first
        .options
        .split(';') rescue ['Please go to Custom Options to add options.']
    end


    def self.progress
      {
        'New'               => { :score => 25,  :color => 'default'},
        'Assigned'          => { :score => 50,  :color => 'warning'},
        'Pending Approval'  => { :score => 75,  :color => 'warning'},
        'Completed'         => { :score => 100, :color => 'success'},
      }
    end

  end # End Class Methods

  ########################
  ###  OBJECT METHODS  ###
  ########################

  def get_id
    if self.respond_to?(:custom_id) && self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end


  def get_responsible_user_name
    self.responsible_user.full_name rescue ''
  end


  def overdue
    if self.respond_to?(:completion) #Mostly the primary forms of SA
      self.completion < Time.now.to_date && self.status != 'Completed' rescue false
    elsif self.respond_to?(:scheduled_completion_date) #Mostly SRA module
      self.status != "Completed" && self.scheduled_completion_date < Time.now.to_date rescue false
    elsif self.respond_to?(:schedule_completion_date) #SMS_Action spells it schedule_ not scheduled_
      self.status != "Completed" && self.schedule_completion_date < Time.now.to_date rescue false
    elsif self.respond_to?(:response_date) #Recommendations
      self.response_date < Time.now.to_date && self.status != 'Completed' rescue false
    end
  end


end
