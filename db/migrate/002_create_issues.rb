class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :subject
      t.text   :reviewer_string, :description, :base
      t.integer :user_id, :closed, :comment_count
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
