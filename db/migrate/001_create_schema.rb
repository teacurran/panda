class CreateSchema < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :key, :limit => 36, :primary => true
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
    
    create_table :encodings do |t|
      t.string :key, :limit => 36, :primary => true
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
    
    create_table :profiles do |t|
      t.string :key, :limit => 36, :primary => true
      t.string :category
      t.string :title
      t.string :extname
      t.string :command
      
      t.integer :width
      t.integer :height
      
      t.timestamps
    end
  end

  def self.down
    drop_table :videos
    drop_table :encodings
    drop_table :profiles
  end
end
