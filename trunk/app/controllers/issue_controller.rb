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
    return render(:status => 403, :text => _("Invalid file type.")) unless @old
  end
  
  def inline_draft
    return render(:status => 403, :text => _("You have to log in for comment.")) unless logged_in?
    @patch = Patch.find :first, :conditions => ['patches.id = ? and patches.issue_id = ? and patches.patchset_id = ?', params[:patch][:id], params[:issue][:id], params[:patchset][:id]], :include => [:issue, :patchset]
    return render(:status => 404, :text => _("Patch is not found.")) unless @patch
    @comment = Comment.new params[:comment]
    @comment.patch = @patch
    @comment.side = params[:side]
    @comment.draft = 1
    @comment.issue = @patch.issue
    @comment.patchset = @patch.patchset
    @comment.parent_id = 0
    @comment.user = self.current_user
    return render(:status => 403, :text => _("Comment save failed.")) unless @comment.save
    @issue = @patch.issue
    @patchset = @patch.patchset
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
    logger.debug "Data::#{data}"
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
  end
  
  private
  def p_and_n
    @p_patch  = Patch.find :first, :conditions => ['patches.id < ? and issue_id = ? and patchset_id = ?', params[:pid], params[:id], params[:psid]], :order => 'patches.id'
    @n_patch  = Patch.find :first, :conditions => ['patches.id > ? and issue_id = ? and patchset_id = ?', params[:pid], params[:id], params[:psid]], :order => 'patches.id'
  end
end
