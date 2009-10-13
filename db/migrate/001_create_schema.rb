class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :extname
      t.string :original_filename
      t.string :video_codec
      t.string :audio_codec
      t.string :thumbnail_position
      t.string :upload_redirect_url
      t.string :state_update_url
      
      t.integer :duration
      t.integer :width
      t.integer :height
      t.integer :fps
      
      t.timestamps
    end
    
    remove_column :videos, :id
    add_column :videos, :id, :string, :limit => 36, :primary => true
    
    create_table :encodings do |t|
      t.string :extname
      t.string :status
      t.string :video_id
      t.string :profile_id
      
      t.integer :width
      t.integer :height
      t.integer :encoding_progress
      t.integer :encoding_time
      
      t.datetime :started_encoding_at
      
      t.timestamps
    end
    
    remove_column :encodings, :id
    add_column :encodings, :id, :string, :limit => 36, :primary => true
    
    create_table :profiles do |t|
      t.string :category
      t.string :title
      t.string :extname
      t.string :command
      
      t.integer :width
      t.integer :height
      
      t.timestamps
    end
    
    remove_column :profiles, :id
    add_column :profiles, :id, :string, :limit => 36, :primary => true
  end

  def self.down
    drop_table :videos
    drop_table :encodings
    drop_table :profiles
  end
end
