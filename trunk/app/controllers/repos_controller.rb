class ReposController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  
  def index
    
  end
  
  def new
    return render unless request.post?
    @repository = Repository.new params[:repository]
    return render unless @repository.save
    redirect_to :action => :index
  end
  
end
