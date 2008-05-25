class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  belongs_to :patchset
  belongs_to :patch
  belongs_to :parent, :class_name => 'Comment', :foreign_key => :parent_id
end
