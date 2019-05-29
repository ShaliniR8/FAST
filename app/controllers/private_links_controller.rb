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

class PrivateLinksController < ApplicationController

  require "digest"

  before_filter :login_required, :except => [:index]

  def show
    private_link = PrivateLink.find_by_digest(params[:id])
    redirect_to "#{private_link.link}"
  end

  def index
    private_link = PrivateLink.find_by_digest(params[:digest])
    if private_link.expire_date > Time.now.to_date
      session[:digest] = private_link
      redirect_to "#{private_link.link}"
    else
      redirect_to login_url, :alert => "The link has expired."
    end
  end


  def new
    @owner = PrivateLink.new
    @link = params[:link]
    render :partial => '/forms/new_private_link'
  end


  def create
    @owner = PrivateLink.create(params[:private_link])
    @owner.digest = Digest::SHA512.hexdigest("#{@owner.created_at}#{@owner.email}")
    @owner.save
    NotifyMailer.share_private_link(current_user, @owner)
    redirect_to "#{@owner.link}"
  end




  private


  def generate_digest(column)
    begin
      self[column] = Digest::SHA512.hexdigest("#{Time.now}#{current_user.id}")
    end
  end



end
