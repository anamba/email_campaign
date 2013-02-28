module EmailCampaign
  module EmailHelper
    
    def email_asset_url(filename)
      AppBaseURL + url_for(:controller => 'email', :action => 'asset', :method => @method, :filename => filename, :k => @identifier)
    end
    
    def email_link_url(url)
      AppBaseURL + url_for(:controller => 'email', :action => 'link', :url => url, :k => @identifier)
    end
    
    def email_unsubscribe_url
      AppBaseURL + url_for(:controller => 'email', :action => 'unsubscribe', :k => @identifier)
    end
    
    def email_web_version_url
      AppBaseURL + url_for(:controller => 'email', :action => 'web_version', :method => @method, :k => @identifier)
    end
    
  end
end
