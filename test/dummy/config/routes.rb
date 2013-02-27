Rails.application.routes.draw do
  mount EmailCampaign::Engine => "/email_campaign"
end
