class CreatePatchsets < ActiveRecord::Migration
  def self.up
    create_table :patchsets do |t|
      t.integer :issue_id, :branch_id, :user_id, :parrent_id, :comment_count
      t.text    :file, :message, :base
      t.string  :url
      t.timestamps
    end
  end

  def self.down
    drop_table :patchsets
  end
end
