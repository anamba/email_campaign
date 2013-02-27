class EmailCampaignRecipient < ActiveRecord::Base
  attr_accessible :name, :email_address,
                  :ready, :duplicate, :invalid_email, :unsubscribed,
                  :subscriber_class_name, :subscriber_id
  
  belongs_to :email_campaign
  
  before_save :check_for_duplicates, :check_email_address, :check_for_unsubscribe
  
  def check_for_duplicates
    if self.class.where(:campaign_id => campaign_id, :email_address => rcpt.email_address).count > 0
      self.ready = false
      self.duplicate = true
    else
      self.duplicate = false
    end
  end
  
  def check_email_address
    if valid_email_address?(rcpt.email_address)
      self.invalid_email = false
    else
      self.ready = false
      self.invalid_email = true
    end
  end
  
  def check_for_unsubscribe
    if self.class.where(:email_address => rcpt.email_address, :unsubscribed => true).count > 0
      self.unsubscribed = true
      self.ready = false
    else
      self.unsubscribed = false
    end
  end
  
  def queue
    if !duplicate && !invalid_email && !unsubscribed
      update_attributes(:ready => true)
    else
      false
    end
  end
  
  def deliver
    # if we want to allow retries in the future we can change this bit
    if attempted && attempts > 0
      puts "Already attempted, not going to try again."
      return false
    end
    
    if failed
      puts "Already failed (reason: #{failure_reason}), not going to try again."
      return false
    end
    
    unless update_column(:attempted, true) && increment(:attempts)
      print "Could not update 'attempted' flag, will not proceed for fear of sending multiple copies"
      return false
    end
    
    if email_address !~ /^[\w\d]+([\w\d\!\#\$\%\&\*\+\-\/\=\?\^\`\{\|\}\~\.]*[\w\d]+)*@([-\w\d]+\.)+[\w]{2,}$/
      print "Invalid email address: #{email_address}"
      self.failed = true
      self.failure_reason = "Invalid email address"
      save
      return false
    end
    
    # TODO: wrap this with begin;rescue;end and set failed/failure_reason in case of exception
    Mailer.email_campaign(self).deliver
    
    true
  end
  
  
  def valid_email_address?(value)
    begin
      m = Mail::Address.new(value)
      # We must check that value contains a domain and that value is an email address
      r = m.domain && m.address == value
      t = m.__send__(:tree)
      # We need to dig into treetop
      # A valid domain must have dot_atom_text elements size > 1
      # user@localhost is excluded
      # treetop must respond to domain
      # We exclude valid email values like <user@localhost.com>
      # Hence we use m.__send__(tree).domain
      r &&= (t.domain.dot_atom_text.elements.size > 1)
    rescue Exception => e
      false
    end
  end
  
end
