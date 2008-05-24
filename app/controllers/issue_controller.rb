class IssueController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  def index
  end
  
  def view
    @issue = Issue.find params[:id]
  end
end
