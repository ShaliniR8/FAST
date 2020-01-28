# ALL ProSafeT models inherit from this object:
  # This provides methods available to all objects system-wide
  # Any new methods added here are available to all Objects in Core ProSafeT

# Object Column Dependencies:
  # status (string) for defining status of object
  # complete_date (datetime) for defining completion time
  # open_date (datetime) for defining completion time
class ProsafetBase < ActiveRecord::Base

  include Occurrenceable
  include Noticeable
  include Messageable
  include ExtensionRequestable
  include Verifiable

  self.abstract_class = true
  include Rails.application.routes.url_helpers #For path method

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

  # Returns the AccessControl table name of the object (for user.has_access lookups)
  def self.rule_name
    self.name.demodulize.underscore.pluralize
  end
  def rule_name
    self.class.name.demodulize.underscore.pluralize
  end

  # Returns the titleized version of the class + strips any namespacing
  def self.titleize
    self.name.demodulize.titleize
  end

  # Returns the result of the path helper for any class
    # Links to element when provided with the elem
    # Can link to edit/new actions if action is defined
  def self.path elem=nil, action:nil
    action = nil unless %w[new edit].include?(action)
    prefix = self.name.gsub(/\:\:/, '_').downcase
    if elem.nil?
      eval("Rails.application.routes.url_helpers.#{prefix}s_path")
    else
      eval("Rails.application.routes.url_helpers.#{prefix}_path(elem)")
    end
  end

  # Returns the class with namespacing separated by / for url pathing
  def self.pathify
    self.name.gsub(/\:\:/, '/').pluralize.downcase
  end


  # Get full status including verification and extension
  def get_status
    verification_needed = self.verifications.select{|x| x.status == 'New'}.length > 0 rescue false
    extension_requested = self.extension_requests.select{|x| x.status == "New"}.length > 0
    if verification_needed
      "#{status}, Verification Required"
    elsif extension_requested
      "#{status}, Extension Requested"
    else
      status
    end
  end


  def get_risk_classification
    risk_factor.split('-').reject(&:empty?).first rescue risk_factor
  end

  def get_risk_score
    risk_factor.split('-').reject(&:empty?).second rescue ''
  end

  def get_risk_classification_after
    risk_factor_after.split('-').reject(&:empty?).first rescue risk_factor_after
  end

  def get_risk_score_after
    risk_factor_after.split('-').reject(&:empty?).second rescue ''
  end

  # find the occurrence template to match
  def self.find_top_level_section
    titles = OccurrenceTemplate.preload.where(archived: false, parent_id: nil).map(&:title)
    title = titles.find { |title| title.include? self.class.name }

    root = OccurrenceTemplate.preload(:children)
      .where(archived: false, parent_id: nil).find_by_title(title)
    root ||= OccurrenceTemplate.preload(:children)
      .where(archived: false, parent_id: nil).find_by_title('Default')

    return root
  end
end
