require File.dirname(__FILE__) + '/../test_helper'

class MemberTest < ActiveSupport::TestCase
  fixtures :issues, :users, :patches, :patchsets
  
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_reviewers
    issue = Issue.find 1
    # Default
    assert issue.reviewers.size, 0
    issue.reviewers << User.find(2)
    issue.save
    
    issue.reload
    assert issue.reviewers.size, 1
    assert_kind_of User, issue.reviewers[0]
    
    # Delete reviewer
    issue.reviewers = []
    issue.save
    
    issue.reload
    assert issue.reviewers.size, 0
    
  end
end
