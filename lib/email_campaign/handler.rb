module EmailCampaign
  module Handler
    
    def self.included(base)
      EmailCampaign::Config.controller_name = base.controller_name
    end
    
    def open
      EmailCampaign::Recipient.record_open(params[:k]) if params[:k]
      
      send_file File.join(Rails.root, 'public', view_context.path_to_image('email_campaign/open-tracker.gif')),
                disposition: 'inline'
    end
    
    def link
      EmailCampaign::Recipient.record_click(params[:k]) if params[:k]
      redirect_to params[:url]
    end
    
    def unsubscribe
      if params[:k]
        @success = EmailCampaign::Recipient.unsubscribe(params[:k])
      else
        render :text => "Cannot unsubscribe you without a subscriber ID, please check the link and try again."
      end
    end
    
    def resubscribe
      if params[:k]
        @success = EmailCampaign::Recipient.resubscribe(params[:k])
      else
        render :text => "Cannot re-subscribe you without a subscriber ID, please check the link and try again."
      end
    end
    
    def web_version
      EmailCampaign::Recipient.record_click(params[:k]) if params[:k]
      redirect_to :action => params[:id]
    end
    
  end
end
