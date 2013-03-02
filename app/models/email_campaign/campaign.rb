class EmailCampaign::Campaign < ActiveRecord::Base
  self.table_name = 'email_campaigns'
  
  attr_accessible :name, :mailer, :method, :params_yaml, :deliver_at,
                  :finalized, :queued, :delivered,
                  :delivery_started_at, :delivery_finished_at
  
  has_many :recipients, :class_name => 'EmailCampaign::Recipient', :foreign_key => 'email_campaign_id'
  
  # new_recipients should be an Array of objects that respond to #email, #name, and #subscriber_id
  # (falls back to #id if #subscriber_id doesn't exist; either way, id should be unique within campaign)
  def add_recipients(new_recipients, options = {})
    options.stringify_keys!
    new_recipients = [ new_recipients ] unless new_recipients.is_a?(Array)
    
    processed = 0
    skipped = 0
    valid = 0
    invalid = 0
    duplicate = 0
    unsubscribed = 0
    
    new_recipients.each do |rcpt|
      subscriber_id = rcpt.respond_to?(:subscriber_id) ? rcpt.subscriber_id : rcpt.id
      
      if subscriber_id && r = recipients.find_by_subscriber_id(subscriber_id)
        if options['force']
          r.requeue
          valid += 1
        else
          skipped += 1
        end
        
        next
      end
      
      processed += 1
      r = recipients.build(:name => rcpt.name, :email_address => rcpt.email_address,
                           :subscriber_class_name => rcpt.class.name, :subscriber_id => subscriber_id)
      if r.save
        case
          when r.unsubscribed then unsubscribed += 1
          when r.duplicate then duplicate += 1
          when r.invalid_email then invalid += 1
          else valid += 1
        end
      else
        invalid += 1
      end
      
      r.queue
    end
    
    { :processed => processed, :skipped => skipped,
      :valid => valid, :invalid => invalid,
      :duplicate => duplicate, :unsubscribed => unsubscribed,
      :total => recipients.where(:ready => true).count }
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
    
    update_attributes(:queued => false, :delivered => true, :delivery_finished_at => Time.now.utc)
  end
  
  def process_delivery
    recipients.where(:ready => true).each { |r| r.delay.deliver }
  end
  
  def queued_recipients
    recipients.where(:ready => true)
  end
  
end
