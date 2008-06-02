class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  belongs_to :patchset
  belongs_to :patch
  belongs_to :parent, :class_name => 'Comment', :foreign_key => :parent_id
  belongs_to :patch_left, :class_name => 'Patch'
  belongs_to :patch_right, :class_name => 'Patch'
  belongs_to :patchset_left, :class_name => 'Patchset'
  belongs_to :patchset_right, :class_name => 'Patchset'
  
  def oldtext
    @oldtext = self.text unless @oldtext
    @oldtext
  end
  def oldtext=(text)
    @oldtext = text
  end
  def code
    line = self.line - 1
    if self.patch_id
      old, new = self.patch.application_patch
      old.delete nil
      new.delete nil
      return self.side == 'a' ? old[line] : new[line]
    end
    tmp, new = self.side == 'a' ? self.patch_left.application_patch : self.patch_right.application_patch
    new.delete nil
    return new[line]
  end
end
