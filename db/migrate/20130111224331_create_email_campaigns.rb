class CreateEmailCampaigns < ActiveRecord::Migration
  
  def change
    create_table :email_campaigns do |t|
      t.string :name
      
      t.string :mailer
      t.string :method
      t.text :params_yaml
      
      t.datetime :deliver_at
      
      t.boolean :finalized, :default => false, :null => false
      t.boolean :queued, :default => false, :null => false
      t.boolean :delivered, :default => false, :null => false
      t.datetime :delivery_started_at
      t.datetime :delivery_finished_at
      
      t.timestamps
    end
  end
  
end
