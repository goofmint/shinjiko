require File.dirname(__FILE__) + '/../test_helper'

class IssueTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_validate
    issue = Issue.new :data => 'test message', :url => 'aaa'
    assert_kind_of Issue, issue
    # Error test
    p "Test 1"
    if issue.save
      p 'Issue save successful'
    else
      p 'Issue save failed.'
      print_error_message issue
    end
  end
  
  def test_validate2
    issue = Issue.new :data => 'test message'
    assert_kind_of Issue, issue
    p "Test 2"
    issue.save
    assert_kind_of Fixnum, issue.id
  end

  def test_validate3
    issue = Issue.new :url => 'http://code.google.com/p/shinjiko/'
    assert_kind_of Issue, issue
    p "Test 3"
    issue.save
    assert_kind_of Fixnum, issue.id
  end

  def test_validate4
    issue = Issue.new :url => 'http://rietveld.googlecode.com/svn-history/r66/trunk/TODO'
    assert_kind_of Issue, issue
    p "Test 4"
    issue.save
    assert_kind_of Fixnum, issue.id
  end
  
  private
  def print_error_message(issue)
    issue.errors.each{ |a, m|
      p "  #{a} => #{m}"
    }
  end
end
