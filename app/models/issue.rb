require 'net/http'
require 'net/https'

class Issue < ActiveRecord::Base
  validates_presence_of :subject
    
  has_many :reviewers
  belongs_to :user
  has_many :patchsets
  has_many :patches
  has_many :messages
  belongs_to :branch
  has_many :comments
  
  def validate
    if self.reviewer_string
      self.reviewer_string.split(",").each { |r|
        u = User.find(:first, :conditions => ['login = ?', r])
        unless u
          errors.add :reviewer_string, _("Invalid user name: %{user}") % { :user => r}
          next
        end
        self.reviewers << u
      }
    end
    unless self.base || self.branch
      errors.add :base, _("You must specify a base %{base}") % { :base => self.base}
    end
    
  end
  
  def fetch(patch)
    rev = patch.parseRevision
    return "" if rev == 0 # new file
    url = make_url patch.filename, rev
    return nil unless url
    url = URI.parse url
    response = nil
    logger.debug "HOST::#{url.host} : #{url.port}"
    Net::HTTP.start(url.host, url.port){|http|
      response = http.get(url.path + (url.query ? "?" + url.query : "" ))
      unless response.code == "200"
        return nil
      end
    }
    return response.body
    # response.body.split(/\r\n|\r|\n/).each { |l|
      
    # }
  end
  
  private
  def make_url(filename, rev = nil)
    scheme, userinfo, host, port, registry, path, opaque, query, fragment = URI.split self.base
    if host =~ /^.*\.googlecode\.com$/
      return nil unless rev
      return nil unless path =~ /\/svn\//
      path = path[5..-1] # Strip "/svn/"
      return "%s://%s/svn-history/r%d/%s/%s" % [scheme, host, rev, path, filename]
    end
    url = self.base
    url += "/" unless url =~ /\/$/
    url += filename
    url += "?rev=#{rev}" unless rev
    url
  end
end
