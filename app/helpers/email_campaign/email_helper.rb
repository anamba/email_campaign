module EmailCampaign
  module EmailHelper
    
    def email_tracking_tag
      if @identifier
        image_tag(EmailCampaign::Config.base_url + url_for(:controller => 'email', :action => 'open', :method => @method, :k => @identifier), :size => '1x1', :alt => '')
      else
        image_tag(EmailCampaign::Config.base_url + path_to_image('email_campaign/open-tracker.gif'), :size => '1x1', :alt => '')
      end
    end
    
    def email_link_url(url)
      if @identifier
        EmailCampaign::Config.base_url + url_for(:controller => 'email', :action => 'link', :url => url, :k => @identifier)
      else
        url
      end
    end
    
    def email_unsubscribe_url
      EmailCampaign::Config.base_url + url_for(:controller => 'email', :action => 'unsubscribe', :k => @identifier)
    end
    
    def email_web_version_url
      EmailCampaign::Config.base_url + url_for(:controller => 'email', :action => 'web_version', :method => @method, :k => @identifier)
    end
    
  end
end
