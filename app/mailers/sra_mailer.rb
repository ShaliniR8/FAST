class SraMailer < ActionMailer::Base

  include ApplicationHelper

  default :from => "engineering@prosafet.com"

  def assign(owner, user)
    @user = user
    @owner = owner
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} Assigned").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} Assigned (dev)").deliver
      end
    end
  end

  def review(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} Pending Review").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} Pending Review (dev)").deliver
      end
    end
  end

  def approve(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} Pending Approval").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} Pending Approval (dev)").deliver
      end
    end
  end

  def reject(owner, user, rejected_by)
    @owner = owner
    @user = user
    @rejected_by = rejected_by
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} Rejected").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} Rejected (dev)").deliver
      end
    end
  end


  def complete(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} has been Completed").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} has been Completed (dev)").deliver
      end
    end
  end

  def reopen(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: SRA ##{@owner.id} Reopened and Assigned").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: SRA ##{@owner.id} Reopened and Assigned (dev)").deliver
      end
    end
  end

  def risk_control_assign(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: Risk Control ##{@owner.id} Assigned").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: Risk Control ##{@owner.id} Assigned (dev)").deliver
      end
    end
  end

  def risk_control_approve(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: Risk Control ##{@owner.id} Pending Approval").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: Risk Control ##{@owner.id} Pending Approval (dev)").deliver
      end
    end
  end

  def risk_control_reject(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: Risk Control ##{@owner.id} Rejected").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: Risk Control ##{@owner.id} Rejected (dev)").deliver
      end
    end
  end

  def risk_control_complete(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: Risk Control ##{@owner.id} Completed").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: Risk Control ##{@owner.id} Completed (dev)").deliver
      end
    end
  end

  def risk_control_reopen(owner, user)
    @owner = owner
    @user = user
    @link = generate_link_to("View", @owner, :use_url => true).html_safe
    if BaseConfig.airline[:sra_mailers]
      if Rails.env.production?
        mail(:to => @user.email, :subject => "ProSafeT: Risk Control ##{@owner.id} Reopened and Assigned").deliver
      else
        mail(:to => "noc@prodigiq.com", :subject => "ProSafeT: Risk Control ##{@owner.id} Reopened and Assigned (dev)").deliver
      end
    end
  end

end
