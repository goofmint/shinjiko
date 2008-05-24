class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :subject, :base
      t.text   :reviewer_string, :description
      t.integer :user_id, :closed
      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end
