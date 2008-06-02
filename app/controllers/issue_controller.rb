require 'diff/lcs'
require 'diff/lcs/hunk'

class IssueController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  
  def index
  end
  
  def patch
    @patch    = Patch.find :first, :conditions => ['patches.id = ?', params[:pid]], :include => [:patchset, :issue]
    return render(:status => 404, :text => _("Patch is not found.")) unless @patch
    # next and previous
    p_and_n
    
    # issue and patchset
    @issue = @patch.issue
    @patchset = @patch.patchset
  end
  
  def diff
    @patch    = Patch.find :first, :conditions => ['patches.id = ?', params[:pid]], :include => [:patchset, :issue]
    return render(:status => 404, :text => _("Patch is not found.")) unless @patch
    p_and_n
    @issue = @patch.issue
    @patchset = @patch.patchset
    @old, @new = @patch.application_patch
    @comments = Hash.new
    user_id = logged_in? ? self.current_user.id : 0
    
    Comment.find(:all, :conditions => ['patch_id = ? and (draft = 0 or user_id = ?)', params[:pid], user_id], :order => 'comments.id').each { |c|
      @comments["#{c.line}#{c.side}"] = [] unless @comments["#{c.line}#{c.side}"]
      @comments["#{c.line}#{c.side}"] << c
    }
    
    return render(:status => 403, :text => _("Invalid file type.")) unless @old
  end
  
  def diff2
    @patch    = Patch.find :first, :conditions => ['patches.id = ?', params[:pid]], :include => [:patchset, :issue]
    return render(:status => 404, :text => _("Patch is not found.")) unless @patch
    p_and_n
    @issue = @patch.issue
    @patchset = @patch.patchset
    psid = params[:psid].split(":")[1]
    
    # Get another patch
    @patch2 = Patch.find :first, :conditions => ['patches.filename = ? and patches.patchset_id = ?', @patch.filename, psid]
    return render(:status => 404, :text => _("Another patch is not found.")) unless @patch2
    
    # make diff file
    tmp, new = @patch.application_patch
    tmp, old = @patch2.application_patch
    return render(:status => 403, :text => _("This patch is not valid.")) unless new || old
    difference  = "--- #{@patch.filename}\n"
    difference += "+++ #{@patch.filename}\n"
    new.delete nil
    old.delete nil
    difference += diff_as_string old, new
    @patch.content = old.join "\n"
    @patch.text = difference
    @old, @new = @patch.application_patch
    @comment = Comment.new :patchset_left_id => @patch2.patchset_id, :patch_left_id => @patch2.id, :patchset_right_id => @patch.patchset_id, :patch_right_id => @patch.id
    @comments = Hash.new
    user_id = logged_in? ? self.current_user.id : 0
    
    Comment.find(:all, 
                 :conditions => ['patchset_left_id = ? and patch_left_id = ? and patchset_right_id = ? and patch_right_id = ? and (draft = 0 or user_id = ?)', @patch2.patchset_id, @patch2.id, @patch.patchset_id, @patch.id, user_id],
                 :order => 'comments.id').each { |c|
      @comments["#{c.line}#{c.side}"] = [] unless @comments["#{c.line}#{c.side}"]
      @comments["#{c.line}#{c.side}"] << c
    }
    
    return render(:status => 403, :text => _("Invalid file type.")) unless @old
  end
  
  def inline_draft
    return render(:status => 403, :text => _("You have to log in for comment.")) unless logged_in?
    delta = params[:comment][:patchset_left_id] ? true : false
    if delta
      # Delta
      @patch = Patch.find :first, 
      :conditions => [
                      'patches.id = ? and patches.issue_id = ? and patches.patchset_id = ?', 
                      params[:comment][:patch_left_id], 
                      params[:issue][:id], 
                      params[:comment][:patchset_left_id]], 
      :include => [:issue, :patchset]
      return render(:status => 404, :text => _("Patch is not found.")) unless @patch
      
      @patch2 = Patch.find :first, 
      :conditions => [
                      'patches.id = ? and patches.issue_id = ? and patches.patchset_id = ?', 
                      params[:comment][:patch_right_id], 
                      params[:issue][:id], 
                      params[:comment][:patchset_right_id]], 
      :include => [:issue, :patchset]
      return render(:status => 404, :text => _("Patch is not found.")) unless @patch2
    else
      # Diff
      @patch = Patch.find :first, :conditions => ['patches.id = ? and patches.issue_id = ? and patches.patchset_id = ?', params[:patch][:id], params[:issue][:id], params[:patchset][:id]], :include => [:issue, :patchset]
      return render(:status => 404, :text => _("Patch is not found.")) unless @patch
    end
    
    if params[:comment][:id]
      @comment = Comment.find :first, :conditions => ['comments.id = ? and comments.user_id = ?', params[:comment][:id], self.current_user.id]
      return render(:status => 403, :text => _("Comment is not found")) unless @comment
      @comment.attributes = params[:comment]
      if @comment.text == ""
        @comment.destroy
        return render(:nothing => true)
      end
    else
      @comment = Comment.new params[:comment]
      if delta
        @comment.patch_left  = @patch
        @comment.patch_right = @patch2
        @comment.patchset_left  = @patch.patchset
        @comment.patchset_right = @patch2.patchset
      else
        @comment.patch = @patch
        @comment.patchset = @patch.patchset
      end
      @comment.draft = 1
      @comment.issue = @patch.issue
      @comment.parent_id = 0
      @comment.user = self.current_user
    end
    return render(:status => 403, :text => _("Comment save failed.")) unless @comment.save
    @issue = @patch.issue
    @patchset = @patch.patchset unless delta
    render :layout => false
  end
  
  def new
    return render unless request.post?
    @issue = Issue.new params[:issue]
    @issue.user = self.current_user
    unless @issue.save
      return render
    end
    data = params[:patchset][:data] ? params[:patchset][:data].read : nil
    @patchset = Patchset.new params[:patchset]
    @patchset.issue = @issue
    @patchset.data  = data
    unless @patchset.save
      return render
    end
    redirect_to :controller => :issue, :action => :view, :id => @issue.id
  end
  
  def edit
    @issue = Issue.find params[:id]
    return render (:status => 404, :text => _("No issue exists with that id (%{issue})") % { :issue => params[:id]}) unless @issue
    @patchset = @issue.patchsets.first
    return render unless request.post?
    return render unless @issue.update_attributes params[:issue]
    return render unless @patchset.update_attributes params[:patchset]
    redirect_to :controller => :issue, :action => :view, :id => @issue.id
  end
  
  def view
    @issue = Issue.find params[:id]
    return render (:status => 404, :text => _("No issue exists with that id (%{issue})") % { :issue => params[:id]}) unless @issue
  end
  
  def publish
    @issue = Issue.find params[:id]
    return render (:status => 404, :text => _("No issue exists with that id (%{issue})") % { :issue => params[:id]}) unless @issue
    unless request.post?
      @message = Message.new :subject => @issue.subject, :reviewer_string => @issue.reviewer_string, :sendmail => 1
      return render
    end
    @message = Message.new params[:message]
    @comments = self.current_user.comments.find(:all, 
                                                :conditions => ['draft = 1'], 
                                                :order => 'comments.patch_id, comments.patch_left_id, comments.patch_right_id, comments.side, comments.line, comments.id',
                                                :include => [:patch]
                                                )
    @message.message = render_to_string(:partial => 'message')
    @message.issue = @issue
    @message.user = self.current_user
    # All comments will be public
    Comment.update_all 'draft = 0', ['user_id = ? and issue_id and draft = 1', self.current_user.id]
    @issue.reviewers << self.current_user if @issue.reviewers.count(:conditions => ['user_id = ?', self.current_user.id]) == 0 && @issue.user_id != self.current_user.id
    @issue.reviewer_string = @issue.reviewers.map(&:login)
    @issue.comment_count = 0 unless @issue.comment_count
    @issue.comment_count += @comments.length
    @comments.each { |c|
      if c.patch_left_id
        # delta
        [c.patch_left, c.patch_right, c.patchset_left, c.patchset_right].each { |o|
          o.comment_count = 0 unless o.comment_count
          o.comment_count += 1
          o.save
        }
      else
        [c.patchset, c.patch].each { |o|
          o.comment_count = 0 unless o.comment_count
          o.comment_count += 1
          o.save
        }
      end
    }
    return render unless @message.save
    redirect_to :controller => :issue, :action => :view, :id => @issue.id
  end
  
  def download
    @patchset = Patchset.find :first, :conditions => ['patchsets.id = ? ', params[:psid]]
    return render(:status => 404, :text => _("Patchset is not found")) unless @patchset
    response.content_type = 'text/plain'
    return render(:text => @patchset.file)
  end
  
  private
  def p_and_n
    @p_patch  = Patch.find :first, :conditions => ['patches.id < ? and issue_id = ? and patchset_id = ?', params[:pid], params[:id], params[:psid]], :order => 'patches.id'
    @n_patch  = Patch.find :first, :conditions => ['patches.id > ? and issue_id = ? and patchset_id = ?', params[:pid], params[:id], params[:psid]], :order => 'patches.id'
  end

  def diff_as_string(data_old, data_new, format=:unified, context_lines=3)
    # data_old = data_old.split(/\n/).map! { |e| e.chomp }
    # data_new = data_new.split(/\n/).map! { |e| e.chomp }
    output = ""
    diffs = Diff::LCS.diff(data_old, data_new)
    return output if diffs.empty?
    oldhunk = hunk = nil
    file_length_difference = 0
    diffs.each do |piece|
      begin
        hunk = Diff::LCS::Hunk.new(data_old, data_new, piece, context_lines,
                                   file_length_difference)
        file_length_difference = hunk.file_length_difference
        next unless oldhunk
        
        # Hunks may overlap, which is why we need to be careful when our
        # diff includes lines of context. Otherwise, we might print
        # redundant lines.
        if (context_lines > 0) and hunk.overlaps?(oldhunk)
          hunk.unshift(oldhunk)
        else
          output << "\n" + oldhunk.diff(format)
        end
      ensure
        oldhunk = hunk
      end
    end
    
    #Handle the last remaining hunk
    output << oldhunk.diff(format)
  end
  
end
