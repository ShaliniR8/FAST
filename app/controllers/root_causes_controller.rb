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

class RootCausesController < ApplicationController
  def destroy
    if RootCause.find(params[:id]).destroy
      render json: {}, status: 200
    else
      render json: {}, status: 500
    end
  end
end
