require 'net/http'
require 'net/https'

class Patchset < ActiveRecord::Base
  before_save :parsepatch
  has_many :patches
  has_many :childs, :class_name => 'Patch', :foreign_key => :parent_id
  belongs_to :issue
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  belongs_to :parrent, :class_name => 'Issue', :foreign_key => :parrent_id
  has_many :comments
  
  def validate
    if @data && self.url != ""
      errors.add :data, _('You must specify either a URL or upload a file but not both')
    end
    unless @data || self.url
      errors.add :data, _('You must specify a URL or upload a file')
    end
    if self.url.to_s != ""
      url = URI.parse(self.url)
      response = nil
      unless url.host
        errors.add :url, _('Invalid URL')
      else
        Net::HTTP.start(url.host, url.port){|http|
          response = http.head(url.path + (url.query ? "?" + url.query : "" ))
        }
        unless response.code == "200"
          errors.add :url, _('HTTP status code %{code}') % {:code => response.code}
        end
      end
    end
  end
  
  def data
    @data
  end
  
  def data=(d)
    @data = d
    self.file = d
  end
  
  def parsepatch
    return true unless @data
    self.patches = []
    filename = nil
    lines = []
    @data.split(/\r\n|\r|\n/).each { |l|
      if l =~ /^Index:/
        if filename && lines.size > 0
          self.patches << Patch.new(:patchset => self, :text => lines.join("\n"), :filename => filename, :parent => self, :issue => self.issue)
        end
        filename = l.split(":", 2)[1].strip
        lines = [l]
        next
      end
      lines << l
    }
    if filename && lines.size > 0
      self.patches << Patch.new(:patchset => self, :text => lines.join("\n"), :filename => filename, :parent => self, :issue => self.issue)
    end
    logger.debug "Patches? #{self.patches}"
  end
  
end
