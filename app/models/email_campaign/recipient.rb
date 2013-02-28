class EmailCampaign::Recipient < ActiveRecord::Base
  self.table_name = 'email_campaign_recipients'
  
  attr_accessible :name, :email_address,
                  :subscriber_class_name, :subscriber_id,
                  :ready, :duplicate, :invalid_email, :unsubscribed,
                  :failed, :failed_at, :failure_reason,
                  :delivered, :delivered_at
  
  belongs_to :campaign, :class_name => 'EmailCampaign::Campaign', :foreign_key => 'email_campaign_id'
  
  validates_presence_of :email_address, :subscriber_id
  
  before_create :generate_identifier, :check_for_duplicates, :check_for_unsubscribe
  before_save :check_name, :check_email_address
  
  def generate_identifier(regenerate = false)
    return identifier if identifier && !regenerate
    
    attempts = 0
    new_identifier = nil
    
    # 28^8 = 378 billion possibilities
    validchars = 'ABCDEFGHJKLMNPQRTUVWXY346789'
    
    while new_identifier.nil? && attempts < 10
      # generate a 8 character identifier
      new_identifier = ''
      8.times { new_identifier << validchars[rand(validchars.length)] }
      
      new_identifier = nil if self.class.count > 0 && self.class.where(:identifier => new_identifier).first
      
      attempts += 1
    end
    
    self.identifier = new_identifier
  end
  
  def check_name
    self.name = nil if name.blank?
    
    true
  end
  
  def check_for_duplicates
    if campaign.recipients.where(:email_address => email_address).count > 0
      self.ready = false
      self.duplicate = true
    else
      self.duplicate = false
    end
    
    true
  end
  
  def check_email_address
    if valid_email_address?(email_address)
      self.invalid_email = false
    else
      self.ready = false
      self.invalid_email = true
    end
    
    true
  end
  
  def check_for_unsubscribe
    if self.class.where(:email_address => email_address, :unsubscribed => true).count > 0
      self.unsubscribed = true
      self.ready = false
    end
    
    true
  end
  
  def queue
    if !duplicate && !invalid_email && !unsubscribed && !failed
      update_attributes(:ready => true)
    else
      false
    end
  end
  
  # resets failed and delivered flags... use sparingly
  def requeue
    queue && update_attributes(:failed => false, :failed_at => nil, :failure_reason => nil,
                               :delivered => false, :delivered_at => nil)
  end
  
  def deliver
    if !ready
      puts "Not in ready state"
      return false
    end
    
    if delivered
      puts "Already delivered."
      return true  # not sure yet whether returning true is a good idea, but seems harmless enough
    end
    
    if failed
      puts "Already failed (reason: #{failure_reason}), not going to try again."
      update_attributes(:ready => false)
      return false
    end
    
    unless update_column(:attempted, true) && increment(:attempts)
      puts "Could not update 'attempted' flag, will not proceed for fear of sending multiple copies"
      update_attributes(:ready => false, :failed => true, :failed_at => Time.now.utc, :failure_reason => "Could not update 'attempted' flag, will not proceed for fear of sending multiple copies")
      return false
    end
    
    if !valid_email_address?(email_address)
      puts "Invalid email address: #{email_address}"
      update_attributes(:ready => false, :failed => true, :failed_at => Time.now.utc, :failure_reason => "Invalid email address")
      return false
    end
    
    begin
      campaign.mailer.constantize.send(campaign.method.to_sym, self).deliver
      update_attributes(:ready => false, :delivered => true, :delivered_at => Time.now.utc)
    rescue Exception => e
      puts e.message
      update_attributes(:ready => false, :failed => true, :failed_at => Time.now.utc, :failure_reason => "#{e.class.name}: #{e.message}")
      return false
    end
    
    true
  end
  
  def self.record_open(identifier, params = {})
    r = find_by_identifier(identifier)
    r.record_open(params) if r
  end
  
  def record_open(params = {})
    self.class.transaction do
      self.opened = true
      self.opened_at ||= Time.now.utc
      self.opens += 1
      save
    end
  end
  
  def self.record_click(identifier, params = {})
    r = find_by_identifier(identifier)
    r.record_click(params) if r
  end
  
  def record_click(params = nil)
    self.class.transaction do
      self.opened = true
      self.opened_at ||= Time.now.utc
      self.opens ||= 1
      self.clicked = true
      self.clicked_at ||= Time.now.utc
      self.clicks += 1
    end
  end
  
  def self.unsubscribe(identifier, params = {})
    r = find_by_identifier(identifier)
    r.unsubscribe(params) if r
  end
  
  def unsubscribe(params = nil)
    self.class.transaction do
      self.class.where(:email_address => email_address, :unsubscribed => false).each do |r|
        r.update_attributes(:unsubscribed => true, :ready => false)
      end
    end
    save
  end
  
  def self.resubscribe(identifier, params = {})
    r = find_by_identifier(identifier)
    r.resubscribe(params) if r
  end
  
  def resubscribe(params = nil)
    self.class.transaction do
      self.class.where(:email_address => email_address, :unsubscribed => true).each do |r|
        r.update_attributes(:unsubscribed, false)
      end
    end
  end
  
  
  
  def to_s
    name.blank? ? email_address : "#{name} <#{email_address}>"
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
