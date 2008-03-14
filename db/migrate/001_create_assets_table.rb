class CreateAssetsTable < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.column "title",         :string
      t.column "caption",       :string
      t.column "content_type",  :string
      t.column "filename",      :string     
      t.column "size",          :integer
      t.column "db_file_id",    :integer # only for db files (optional)
      t.column "parent_id",     :integer 
      t.column "thumbnail",     :string
      t.column "width",         :integer  
      t.column "height",        :integer
      t.column "created_at",    :datetime
      t.column "created_by",    :integer
      t.column "updated_at",    :datetime
      t.column "updated_by",    :integer
    end
    
  end
  
  def self.down
    drop_table :assets
  end
end