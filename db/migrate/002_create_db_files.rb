class CreateDbFiles < ActiveRecord::Migration
  def self.up
    
    create_table :db_files, :force => true do |t|
      t.column :data, :binary, :limit => 2.megabyte
    end
    
  end
  
  def self.down
    drop_table :db_files
  end
end