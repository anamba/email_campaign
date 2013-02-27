class EmailCampaign::Campaign < ActiveRecord::Base
  set_table_name "email_campaigns"
  
  attr_accessible :name, :mailer, :method, :params_yaml, :deliver_at,
                  :finalized, :queued, :delivered
  
  has_many :recipients, :class_name => 'EmailCampaign::Recipient'
  
  # new_recipients should be an Array of objects that respond to #email, #name, and #subscriber_id
  # (falls back to #id if #subscriber_id doesn't exist; either way, this id should be unique)
  def queue(new_recipients, limit = nil)
    count = 0
    while rcpt = new_recipients.shift do
      next unless recipients.where(:subscriber_id => rcpt.subscriber_id).count == 0
      
      rcpt.name.strip!
      rcpt.email_address.strip!
      
      r = recipients.create(:name => rcpt.name, :email_address => rcpt.email_address,
                            :subscriber_class_name => rcpt.class.name, :subscriber_id => rcpt.subscriber_id || rcpt.id)
      
      r.queue if count < limit
      count += 1
    end
  end
  
end
