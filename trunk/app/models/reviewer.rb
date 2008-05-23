class Reviewer < ActiveRecord::Base
  belongs_to :issue
end
