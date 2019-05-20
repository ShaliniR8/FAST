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

class RiskMatrixGroupsController < ApplicationController

  before_filter :login_required

  def index
    @title = "Risk Matrices"
    @table_name = "risk_matrix_groups"
    @headers = RiskMatrixGroup.get_headers
    @records = RiskMatrixGroup.find(:all)
  end

  def show
    @record = RiskMatrixGroup.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
    @record = RiskMatrixGroup.find(params[:id])
  end

  def update
  end

  def destroy
  end


end
