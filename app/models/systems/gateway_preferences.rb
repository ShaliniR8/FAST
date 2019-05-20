class GatewayPreferences < ActiveRecord::Base

  def self.getLayout
    {
      # :custom  => true, #set this true if airport wants to NOT have all modules/systems display in gateway
    }
  end


  def self.getModulePaths
    [
      { :db_name => "p139",      :href_path => "/home",         :icon_path => "/images/Part139_icon_square.png" },
      # p139_self is set at db level
      { :db_name => "p139_self", :href_path => "/home",         :icon_path => "/images/Airport_Self_Inspection_icon_square.png"},
      { :db_name => "arff",      :href_path => "/arff_home",    :icon_path => "/images/ARFF_icon_square.png" },
      { :db_name => "wildlife",  :href_path => "/wcr_home",     :icon_path => "/images/WCR_icon_square.png"},

      { :db_name => "fuel",      :href_path => "/fsi_home",     :icon_path => "/images/fsi_icon_square.png" },
      { :db_name => "bird",    :href_path => "/bird_home",    :icon_path => "/images/bird_icon_square.png" },
      { :db_name => "vehicle",   :href_path => "/vehicle_home", :icon_path => "/images/vehicle_icon_square.png" },

      { :db_name => "storm",     :href_path => "/water_home",   :icon_path => "/images/storm_icon_square.png" },
      { :db_name => "notam",     :href_path => "/notam_home",   :icon_path => "/images/notams_icon_square.png" },
      { :db_name => "tms",       :href_path => "/tms_home",     :icon_path => "/images/training_icon_square.png" }
    ]
  end

  def self.getSystemPaths
    [
      { :db_name => "sms",       :href_path => "#",             :icon_path => "/images/smsBackground_small.jpg",          :name => "Safety Management"},
      { :db_name => "lms",       :href_path => "#",             :icon_path => "/images/leasePortalImage_small.gif",       :name => "Lease Management"},
      { :db_name => "maint",     :href_path => "/maint_home",   :icon_path => "/images/maintenancePortalImage_small.png", :name => "Maintenance Management"},
      { :db_name => "oms",       :href_path => "#",             :icon_path => "/images/leasePortalImage_small.gif",       :name => "Operations Management"}
    ]
  end



end
# { :db_name => "maint" }
