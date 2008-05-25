class IssueController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  def index
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
end
