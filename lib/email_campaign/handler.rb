module EmailCampaign
  module Handler
    
    def open
      EmailCampaign::Recipient.record_open(params[:k]) if params[:k]
      
      options = {}
      options[:disposition] = 'inline'
      path = File.join(Rails.root, 'public/assets/email_campaign/open-tracker.gif')
      send_file path, options
    end
    
    # deprecated, remove after 4/1/2013
    def asset
      EmailCampaign::Recipient.record_open(params[:k]) if params[:k]
      
      options = {}
      options[:disposition] = [ 'jpg', 'jpeg', 'gif', 'png' ].include?(params[:format].downcase) ? 'inline' : 'attachment'
      
      path = File.join(Rails.root, 'app', 'assets', 'images', 'email', params[:method].to_s, params[:filename] + '.' + params[:format])
      if !File.exists?(path)
        path = File.join(Rails.root, 'app', 'assets', 'images', 'email', params[:filename] + '.' + params[:format])
      end
      render :text => 'Not Found', :status => 404 and return if !File.exists?(path)
      
      send_file path, options
    end
    
    def link
      EmailCampaign::Recipient.record_click(params[:k]) if params[:k]
      redirect_to params[:url]
    end
    
    def unsubscribe
      if params[:k]
        @success = EmailCampaign::Recipient.unsubscribe(params[:k])
      else
        render :text => "No subscriber identifier given, cannot continue."
      end
    end
    
    def resubscribe
      if params[:k]
        @success = EmailCampaign::Recipient.resubscribe(params[:k])
      else
        render :text => "No subscriber identifier given, cannot continue."
      end
    end
    
    def web_version
      EmailCampaign::Recipient.record_click(params[:k]) if params[:k]
      redirect_to :action => params[:id]
    end
    
  end
end
