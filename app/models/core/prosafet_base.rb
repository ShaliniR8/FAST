# ALL ProSafeT models inherit from this object:
  # This provides methods available to all objects system-wide
  # Any new methods added here are available to all Objects in Core ProSafeT

# Object Column Dependencies:
  # status (string) for defining status of object
  # complete_date (datetime) for defining completion time
  # open_date (datetime) for defining completion time
class ProsafetBase < ActiveRecord::Base
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

  # Returns the titleized version of the class + strips any namespacing
  def self.titleize
    self.name.split('::').last.titleize
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

end
