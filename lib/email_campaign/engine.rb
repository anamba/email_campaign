module EmailCampaign
  
  class Engine < Rails::Engine
    engine_name 'email_campaign'
    
    config.app_root = root
    middleware.use ::ActionDispatch::Static, "#{root}/public"
    
    initializer "email_campaign.assets.precompile" do |config|
      Rails.application.config.assets.precompile += %w( email_campaign/open-tracker.gif )
    end
    
    require 'email_campaign/config'
    require 'email_campaign/handler'
    
    #
    # activate gems as needed
    #
    
  end
  
end
