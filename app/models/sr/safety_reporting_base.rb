# All Safety Reporting-specific models inherit from this object:
  # This provides module-specific methods for Safety Reporting
  # Any new methods added here are available to all Safety Reporting Objects
module Sr
  class SafetyReportingBase < ProsafetBase
    self.abstract_class = true


    def categories
      template.categories
    end


    def get_date
      event_date.strftime("%Y-%m-%d") rescue ''
    end


    def get_id
      custom_id || id
    end

    def get_description
      return '' if self.description.blank?
      return self.description[0..50] + '...' if self.description.length > 50
      return self.description
    end

    def get_event_date
      event_date.strftime("%Y-%m-%d %H:%M:%S") rescue ''
    end


    def get_user_id
      anonymous ? 'Anonymous' : user_id
    end


    def submit_name
      return 'Anonymous' if self.anonymous?
      return (self.created_by.full_name rescue 'Disabled')
    end


    def submitted_date
      created_at.strftime("%Y-%m-%d") rescue ''
    end


    def get_submitter_name
      anonymous ? 'Anonymous' : created_by.full_name
    end

    def get_template
      template.name
    end


    def time_diff(base)
      return 100000.0 if event_date.blank?
      diff = ((event_date - base.event_date) / (24*60*60)).abs
    end


    def getTimeZone()
      ['Z','NZDT','IDLE','NZST','NZT','AESST','ACSST','CADT','SADT','AEST','CHST','EAST','GST',
       'LIGT','SAST','CAST','AWSST','JST','KST','MHT','WDT','MT','AWST','CCT','WADT','WST',
       'JT','ALMST','WAST','CXT','MMT','ALMT','MAWT','IOT','MVT','TFT','AFT','MUT','RET',
       'SCT','IRT','IT','EAT','BT','EETDST','HMT','BDST','CEST','CETDST','EET','FWT','IST',
       'MEST','METDST','SST','BST','CET','DNT','FST','MET','MEWT','MEZ','NOR','SET','SWT',
       'WETDST','GMT','UT','UTC','ZULU','WET','WAT','FNST','FNT','BRST','NDT','ADT','AWT',
       'BRT','NFT:NST','AST','ACST','EDT','ACT','CDT','EST','CST','MDT','MST','PDT','AKDT',
       'PST','YDT','AKST','HDT','YST','MART','AHST','HST','CAT','NT','IDLW']
    end



  end
end
