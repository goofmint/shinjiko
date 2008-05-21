class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :subject, :baseuri
      t.text   :reviewer_string, :description
      t.integer :comment_count, :user_id, :closed, :base_id
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
