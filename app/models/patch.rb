class Patch < ActiveRecord::Base
  belongs_to :patchset
  belongs_to :parent, :class_name => 'Patchset', :foreign_key => :parent_id

end
