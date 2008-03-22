class CreateAssetsPages < ActiveRecord::Migration
  def self.up
    create_table :asset_associations do |t|
      t.column :asset_id,     :integer
      t.column :page_id,      :integer
      t.columen :position,    :integer
    end
    
  end
  
  def self.down
    drop_table :assets
  end
end