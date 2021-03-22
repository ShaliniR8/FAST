if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end

class AirportsController < ApplicationController
  require 'csv'

  skip_before_filter :authenticate_user!

  def index
    @airports = Airport.all

    respond_to do |format|
      format.json do
        render :json => @airports.to_json
      end
      format.html {home_path}
    end
  end


end
