class Repository < ActiveRecord::Base
  has_many :branches
  
  before_create :create_trunk
  
  def create_trunk
    uri  = self.uri[0..-2] if self.uri =~ /.*\/$/
    uri += "/trunk/"
    self.branches << Branch.new(:category => Category.find_by_name('*trunk*'), :name => 'Trunk', :uri => uri)
  end
end
