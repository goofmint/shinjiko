class IssueController < ApplicationController
  before_filter :login_required, :except => [:index]
  layout 'default'
  def index
  end
end
