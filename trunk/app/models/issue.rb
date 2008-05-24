require 'net/http'
require 'net/https'

class Issue < ActiveRecord::Base
  validates_presence_of :subject
    
  has_many :reviewers
  belongs_to :user
  has_many :patchsets
  has_many :patches
  has_many :messages
  belongs_to :branch
  
  def validate
    if self.reviewer_string
      self.reviewer_string.split(",").each { |r|
        u = User.fin(:first, :conditions => ['login = ?', r])
        unless u
          errors.add :reviewer, _("Invalid user name: %{user}") % { :user => r}
          next
        end
        self.reviewers << u
      }
    end
    
    unless self.base || self.branch
      errors.add :base, _("You must specify a base %{base}") % { :base => self.base}
    end
    
  end
end
