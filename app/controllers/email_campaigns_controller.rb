class EmailCampaignsController < ApplicationController
  include EmailCampaignsAuthenticator
  before_filter :check_permissions
  
  # define authenticate in your initializer (in main app)
  
  def check_permissions
    render :action => 'permission_denied' unless authenticate
  end
  
  def index
    # @drafts = EmailCampaign.where(:queued => false)
    # @queued = EmailCampaign.where(:queued => true, :delivered => false)
    # @sent = EmailCampaign.where(:delivered => true).order('delivery_finished_at desc')
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def show
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  def deliver
    
  end
  
  def status
    
  end
  
end
