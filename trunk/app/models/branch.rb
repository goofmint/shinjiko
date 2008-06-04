class Branch < ActiveRecord::Base
  belongs_to :issue
  belongs_to :repository
  belongs_to :category
end
