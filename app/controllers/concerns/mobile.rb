#----------# For ProSafeT App v2 #----------#
#-------------------------------------------#

module Concerns
  module Mobile extend ActiveSupport::Concern
    included do
      # maps to the concern in ./mobile with the same name as the controller that includes it
      include Concerns::Mobile.const_get(controller_name.capitalize)
    end
  end
end