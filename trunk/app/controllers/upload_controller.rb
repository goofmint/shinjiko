class UploadController < ApplicationController
  def index
    # new or update
    api = Api.find :first, :conditions => ['cookie = ?', cookies[:ACSID]], :include => :user
    return render(:status => 401, :text => 'Authorization expired.') unless api && api.user
    user = api.user
    message = nil
    if params[:issue]
      # update
      issue = Issue.find :first, :conditions => ['issues.id = ?', params[:issue]]
      unless issue
        return render(:status => 404, :text => _("Issue is not found."))
      end
      message = params[:subject]
    else
      # new
      # Get data url
      #  data or url required. But not both.
      #  if data, save data to database
      #  if url, fetch url. Status code 200 is OK.
      # Get reviewers
      #   User check.
      #   Original script use email address, but this script use login name.
      #   It's for security.
      
      # Get base
      #  Use input base.
      #  If no base, use branch parameter.
      
      # Create issue
      #  - subject
      #  - description
      #  - base
      #  - reviewers
      #  - owner
      issue = Issue.new :subject => params[:subject], :description => params[:description], :base => params[:base], :user => user
    end
    unless issue.save
      issue.errors.each{ |a, m|
        logger.debug " Issue Error::#{a} => #{m}"
      }
    end
    # Create patchset
    #  - issue
    #  - data
    #  - url
    #  - base
    #  - owner
    #  - parrent => issue
    data = nil
    data = params[:data].read if params[:data]
    patchset = Patchset.new :issue => issue, :data => data, :url => params[:url], :owner => user, :parrent => issue, :message => message
    unless patchset.save
      patchset.errors.each{ |a, m|
        logger.debug " Patchset Error::#{a} => #{m}"
      }
    end
    # End
    return render :text => url_for(:controller => :issue, :action => :view, :id => issue.id, :only_path => false)
  end
end
