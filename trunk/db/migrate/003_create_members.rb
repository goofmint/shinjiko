class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :issue_id, :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
