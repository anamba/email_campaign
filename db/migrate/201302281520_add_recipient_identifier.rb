class AddRecipientIdentifier < ActiveRecord::Migration
  
  def change
    add_column :email_campaign_recipients, :identifier, :string, :limit => 35
    add_index :email_campaign_recipients, :identifier
  end
  
end
