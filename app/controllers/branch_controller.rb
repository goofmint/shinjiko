class BranchController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  
  def new
    @repository = Repository.find :first, :conditions => ['repositories.id = ?', params[:id]]
    return render(:status => 404, :text => _("No repository found.")) unless @repository
    unless request.post?
      @branch = Branch.new :uri => @repository.uri, :repository => @repository, :category => Category.find_by_name("branch")
      return render
    end
    @branch = Branch.new params[:branch]
    return render unless @branch.save
    return redirect_to(:controller => :repos)
  end
  
  def edit
    @branch = Branch.find :first, :conditions => ['branches.id = ?', params[:id]], :include => [:repository]
    return render unless request.post?
    return render unless @branch.update_attributes(params[:branch])
    return redirect_to(:controller => :repos)
  end
end
