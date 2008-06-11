# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie, :config_load
  init_gettext "shinjiko"

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'c8fcef0f8ee0ed2d4c27db1d18a35778'
  
  def config_load
    file = "#{RAILS_ROOT}/config/shinjiko.yml"
    raise "Config file does not exits." unless File::exist?(file)
    @shinjiko_config = YAML::load_file(file)[RAILS_ENV]
  end
end
