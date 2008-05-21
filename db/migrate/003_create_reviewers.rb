class CreateReviewers < ActiveRecord::Migration
  def self.up
    create_table :reviewers do |t|
      t.integer :issue_id, :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reviewers
  end
end
