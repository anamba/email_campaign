class CreateEmailCampaignRecipients < ActiveRecord::Migration
  
  def change
    create_table :email_campaign_recipients do |t|
      t.integer :email_campaign_id, :null => false
      
      t.string :email_address
      t.string :name
      
      t.string :subscriber_class_name
      t.string :subscriber_id
      
      t.string :status
      
      t.boolean :ready, :default => false, :null => false
      
      t.boolean :duplicate, :default => false, :null => false
      t.boolean :invalid_email, :default => false, :null => false
      t.boolean :unsubscribed, :default => false, :null => false
      
      t.boolean :attempted, :default => false, :null => false
      t.integer :attempts, :default => 0, :null => false
      t.datetime :attempted_at
      
      t.boolean :failed, :default => false, :null => false
      t.datetime :failed_at
      t.string :failure_reason
      
      t.boolean :delivered, :default => false, :null => false
      t.datetime :delivered_at
      
      t.boolean :opened, :default => false, :null => false
      t.datetime :opened_at
      t.integer :opens, :default => 0, :null => false
      
      t.boolean :clicked, :default => false, :null => false
      t.datetime :clicked_at
      t.integer :clicks, :default => 0, :null => false
      
      t.timestamps
    end
    add_index :email_campaign_recipients, :email_address
    add_index :email_campaign_recipients, :subscriber_id
  end
  
end
