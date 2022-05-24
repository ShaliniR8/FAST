module ModelHelpers
  extend ActiveSupport::Concern
  # This set of terms are for common functions used by models and other sources.

  # Use the following to include these into the model:
  #  include ModelHelpers


  #######################
  ###  CLASS METHODS  ###
  #######################
  included do

    def self.get_avg_complete(current_user=nil, start_date=nil, end_date=nil, departments=nil)
      if start_date && end_date
        completed_objects = self.within_timerange(start_date, end_date).where('status = ? and close_date is not ?', 'Completed', nil)
      else
        completed_objects = self.where('status = ? and close_date is not ?', 'Completed', nil)
      end

      case self.name
      when 'Record'
        # completed_objects = self.where('status = ? and close_date is not ?', 'Closed', nil)
        # completed_objects.keep_if{|r| (current_user.has_access(r.template.name, "viewer_template_id" ) rescue false) }

        completed_objects = self.preload(:template)
                            .where('status = ? and close_date is not ?', 'Closed', nil)
                            .can_be_accessed(current_user)

      when 'Report'
        completed_objects = self.where('status = ? and close_date is not ?', 'Closed', nil)
      when 'Sra', 'Hazard', 'RiskControl'
        if start_date && end_date
          completed_objects = self.within_timerange(start_date, end_date).where('status = ? and close_date is not ?', 'Completed', nil).by_departments(departments)
        else
          completed_objects = self.where('status = ? and close_date is not ?', 'Completed', nil).by_departments(departments)
        end
      end

      if completed_objects.present?
        sum = 0
        completed_objects.map{ |x|
          has_open_date = (self.columns.map(&:name).include? 'open_date') && x.open_date.present?
          start_date = has_open_date ? x.open_date : x.created_at
          sum += (x.close_date.to_date - start_date.to_date).to_i rescue next # when created_at is nil
        }
        result = (sum.to_f / completed_objects.length.to_f).round(1)
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
    if self.respond_to?(:due_date) # temporary for SR (keep below incase)
      self.due_date < Time.now.to_date && self.status != 'Completed' rescue false
    elsif self.respond_to?(:completion) #Mostly the primary forms of SA
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
