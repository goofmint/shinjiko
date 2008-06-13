class Repository < ActiveRecord::Base
  has_many :branches
  
  before_create :create_trunk
  before_save   :move_password_base
  
  def create_trunk
    uri  = self.uri =~ /.*\/$/ ? self.uri[0..-2] : self.uri
    uri += "/trunk/"
    self.branches << Branch.new(:category => Category.find_by_name('*trunk*'), :name => 'Trunk', :uri => uri)
  end
  
  def password_base
    @password_base
  end
  
  def password_base=(base)
    @password_base = base
  end
  
  private
  def move_password_base
    self.password = @password_base if @password_base != ""
  end
end
