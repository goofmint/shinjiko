class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  belongs_to :patchset
  belongs_to :patch
  belongs_to :parent, :class_name => 'Comment', :foreign_key => :parent_id
  
  def oldtext
    @oldtext = self.text unless @oldtext
    @oldtext
  end
  def oldtext=(text)
    @oldtext = text
  end
end
