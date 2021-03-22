class CustomOption < ActiveRecord::Base

  after_save :update_custom_option
  after_destroy :update_custom_option

  def self.get_headers
    [
      {:title => "Title",         :field => :title},
      {:title => "Description",   :field => :description}
    ]
  end

  def update_custom_option
    Rails.application.config.custom_options = CustomOption.all.map{|x| [x.title, (x.options.split(';') rescue [''])]}.to_h
    Rails.application.config.custom_options_arr = CustomOption.all.sort_by(&:title)
    Rails.logger.info "[INFO] Custom Options have been updated- custom_options application config updated"
  end


end
