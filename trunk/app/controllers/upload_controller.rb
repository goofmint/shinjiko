class UploadController < ApplicationController
  def index
    # new or update
    if params[:issue]
      # update
    else
      # new
      api = Api.find :first, :conditions => ['cookie = ?', cookies[:ACSID]], :include => :user
      return render(:status => 401, :text => 'Authorization expired.') unless api && api.user
      user = api.user
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
      patchset = Patchset.new :issue => issue, :data => data, :url => params[:url], :owner => user, :parrent => issue
      patchset.save
      unless patchset.save
        patchset.errors.each{ |a, m|
          logger.debug " Patchset Error::#{a} => #{m}"
        }
      end
      # End
      return render :text => url_for(:controller => :issue, :action => :view, :id => issue.id, :only_path => false)
    end
  end
end
