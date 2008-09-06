# $Id: NgTzeYang [nineone@singnet.com.sg] 06 Sep 2008 11:37 $
# 

begin
  require File.dirname(__FILE__) + '/../../../../spec/spec_helper'
rescue LoadError
  puts "You need to install rspec in your base app"
  exit
end

Spec::Runner.configure do |config| 
  config.use_transactional_fixtures = false
  config.fixture_path = File.dirname(__FILE__) + '/fixtures/' 
end

plugin_spec_dir = File.dirname(__FILE__)
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

# __END__
