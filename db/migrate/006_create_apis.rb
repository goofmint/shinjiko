class CreateApis < ActiveRecord::Migration
  def self.up
    create_table :apis do |t|
      t.string    :session, :cookie
      t.integer   :user_id
      t.timestamp :expired_at
      t.timestamps
    end
  end

  def self.down
    drop_table :apis
  end
end
