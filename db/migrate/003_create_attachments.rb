class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.column :asset_id,     :integer
      t.column :page_id,      :integer
      t.columen :position,    :integer
    end
    
  end
  
  def self.down
    drop_table :assets
  end
end