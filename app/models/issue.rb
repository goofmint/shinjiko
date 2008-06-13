require 'net/http'
require 'net/https'
require 'svn/client'

class Issue < ActiveRecord::Base
  validates_presence_of :subject
  
  has_many :members
  has_many :reviewers, :through => :members, :source => :user
  
  belongs_to :user
  has_many :patchsets
  has_many :patches
  has_many :messages
  belongs_to :branch
  has_many :comments
  
  def validate
    if self.reviewer_string
      reviewers = []
      olds = self.reviewers.map(&:login)
      self.reviewer_string.split(",").each { |r|
        r.strip!
        next if r == ""
        reviewers << r
      }
      reviewers.uniq!
      reviewers.each { |r|
        next if olds.index(r)
        u = User.find(:first, :conditions => ['login = ?', r])
        unless u
          errors.add :reviewer_string, _("Invalid user name: %{user}") % { :user => r}
          break
        end
        self.reviewers << u
      }
      self.reviewer_string = self.reviewers.map(&:login).join ","
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
    if url.is_a? String
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
    end
    # Subversion access
    url, filename, rev = url
    url += "/" unless url =~ /\/$/
    filename = filename[1..-1] if filename =~ /^\//
    if self.patchsets.first.username != ""
      username = self.patchsets.first.username
    else
      username = self.patchsets.first.branch.repository.username
    end
    if self.patchsets.first.password != ""
      password = self.patchsets.first.password
    else
      password = self.patchsets.first.branch.repository.password
    end
    logger.debug "#{username} #{password}"
    ctx = Svn::Client::Context.new
    if username && password
      ctx.add_simple_prompt_provider(0) do |cred, realm, user_name, may_save|
        cred.username = username
        cred.password = password
      end
    end
    body = ""
    begin
      body = ctx.cat(url + filename, rev)
    rescue Svn::Error::FS_NOT_FOUND
    end
    body
  end

  def repo_url
    return self.base if self.base != ""
    return self.patchsets.first.branch.uri if self.patchsets.first && self.patchsets.first.branch
    return ""
  end
  
  def reviewers_email_address
    reviewers = self.reviewers + [self.user]
    return reviewers.map(&:email).join(",") if reviewers.size > 0
  end
  
  private
  def make_url(filename, rev = nil)
    url = repo_url
    if url =~ /^http/
      scheme, userinfo, host, port, registry, path, opaque, query, fragment = URI.split url
      if host =~ /^.*\.googlecode\.com$/
        return nil unless rev
        return nil unless path =~ /\/svn\//
        path = path[5..-1] # Strip "/svn/"
        return "%s://%s/svn-history/r%d/%s/%s" % [scheme, host, rev, path, filename]
      end
      url += "/" unless url =~ /\/$/
      url += filename
      url += "?rev=#{rev}" unless rev
      url
    elsif url =~ /^svn/
      return url, filename, rev
    end
  end
  
end
