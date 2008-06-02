class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.integer :user_id, :issue_id, :patchset_id, :patch_id, :line, :draft, :parent_id, :patchset_left_id, :patch_left_id, :patchset_right_id, :patch_right_id
      t.string  :side, :snapshot, :file
      t.text    :text
      t.timestamps
    end
  end

  def self.down
    drop_table :comments
  end
end
