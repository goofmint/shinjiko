class CreatePatches < ActiveRecord::Migration
  def self.up
    create_table :patches do |t|
      t.integer :patchset_id, :parent_id, :issue_id, :comment_count
      t.text    :text, :content
      t.string  :filename
      t.timestamps
    end
  end

  def self.down
    drop_table :patches
  end
end
