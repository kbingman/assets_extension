class CreateAssetsPages < ActiveRecord::Migration
  def self.up
    create_table :assets_pages, :id => false do |t|
      t.column :asset_id,     :integer
      t.column :page_id,      :integer
    end
    
  end
  
  def self.down
    drop_table :assets
  end
end