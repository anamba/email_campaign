class EmailCampaign::Campaign < ActiveRecord::Base
  set_table_name "email_campaigns"
  
  attr_accessible :name, :mailer, :method, :params_yaml, :deliver_at,
                  :finalized, :queued, :delivered,
                  :delivery_started_at, :delivery_finished_at
  
  has_many :recipients, :class_name => 'EmailCampaign::Recipient', :foreign_key => 'email_campaign_id'
  
  # new_recipients should be an Array of objects that respond to #email, #name, and #subscriber_id
  # (falls back to #id if #subscriber_id doesn't exist; either way, id should be unique within campaign)
  def add_recipients(new_recipients, limit = nil)
    new_recipients = [ new_recipients ] unless new_recipients.is_a?(Array)
    
    count = 0
    new_recipients.each do |rcpt|
      subscriber_id = rcpt.subscriber_id || rcpt.id
      # next if subscriber_id && recipients.where(:subscriber_id => subscriber_id).count > 0
      
      r = recipients.create(:name => rcpt.name.strip, :email_address => rcpt.email_address.strip,
                            :subscriber_class_name => rcpt.class.name, :subscriber_id => subscriber_id)
      
      r.queue unless limit && count >= limit
      count += 1
    end
    
    recipients.where(:ready => true).count
  end
  
  def queue(deliver_at = Time.now.utc)
    # update_attributes(:deliver_at => deliver_at, :queued => true, :queued_at => Time.now.utc)
    update_attributes(:deliver_at => deliver_at, :queued => true)
  end
  
  # delivers campaign NOW, ignoring deliver_at setting
  def deliver!(unsanitary = false)
    sent = []
    error = []
    
    update_attributes(:delivery_started_at => Time.now.utc) unless delivery_started_at
    
    if unsanitary
      SanitizeEmail.unsanitary { process_delivery }
    else
      process_delivery
    end
    
    # update_attributes(:delivered => true, :delivered_at => Time.now.utc)
    update_attributes(:delivered => true, :delivery_finished_at => Time.now.utc)
  end
  
  def process_delivery
    sent = []
    error = []
    recipients.where(:ready => true).each do |r|
      # begin
        mailer.constantize.send(method.to_sym, r).deliver
        sent << r
      # rescue Exception => e
        # error << [ r, e ]
      # end
    end
  end
  
end
