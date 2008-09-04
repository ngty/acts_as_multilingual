# $Id: NgTzeYang [nineone@singnet.com.sg] 04 Sep 2008 21:28 $
# 

require File.dirname(__FILE__) + '/spec_helper'


class MultilingualEntity < ActiveRecord::Base
  acts_as_multilingual :actions => :archive
  def archive
    update_attribute( :status, 'archived' ) and self
  end
end 


describe "Acting as multilingual" do

  fixtures :multilingual_entities

  before(:each) do
    @entity = MultilingualEntity.new
  end

  def lang_entities( *args )
    entities = [ args ].flatten.collect { | name | multilingual_entities(name) }
    entities.length == 1 ? entities.first : entities
  end

  def equal_entities?( entities_1, entities_2 )
    ( entities_1.length == entities_2.length ) and ( entities_1 - entities_2 ).empty?
  end


  it "should identify itself as multilingual" do
    @entity.should be_multilingual
  end

  
  describe "on fetching lang_aliases" do

    it "as parent alias, should yield all child aliases" do
      parent = lang_entities(:en_SG)
      children = lang_entities( :zh_CN, :en_US )
      equal_entities?( parent.lang_aliases, children ).should be_true
    end

    it "as child alias, should yield parent and sibling aliases" do
      parent = lang_entities(:en_SG)
      children = lang_entities( :zh_CN, :en_US )
      child = children.pop
      equal_entities?( child.lang_aliases, [ parent, children ].flatten ).should be_true
    end

  end


  describe "on doing translation" do
    
    before(:each) do
      @entity_1 = lang_entities(:zh_CN)
      @entity_2 = lang_entities(:en_SG)
    end

    it "should return itself if language is matching" do
      @entity_1.to_lang(@entity_1.lang).should == @entity_1
    end

    it "should return alias with matching language" do
      @entity_1.to_lang(@entity_2.lang).should == @entity_2
    end

    it "should return nil if no alias with matching language is found" do
      @entity_1.to_lang('abcd').should be_nil
    end

  end


  describe "on building with aliases" do

    before(:each) do
      @langs = %w( en_SG en_US zh_CN )
      @entities_attrs = @langs.collect { |lang| { :lang => lang } }
    end

    # 
    # See http://rubyforge.org/pipermail/rspec-users/2007-March/000978.html
    # for testing of alias methods
    #
    [ :new_with_lang_aliases, :build_with_lang_aliases ].each do | meth |

      it "using #{meth.to_s}, should build entity with the 1st set of attrs and return entity" do
        entity = MultilingualEntity.send( meth, @entities_attrs )
        entity.lang.should == @langs[0]
      end

      it "using #{meth.to_s}, should build entity's aliases with remaining sets of attrs" do
        entity = MultilingualEntity.send( meth, @entities_attrs )
        equal_entities?( entity.lang_aliases.collect { |a| a.lang }, @langs[1,(@langs.size-1)] ).should be_true
      end

    end

  end


  describe "demonstrating transactional action on archive" do

    before(:each) do
      @entity = lang_entities(:en_SG)
    end

    it "upon success, should return success" do
      @entity.status.should == 'active'
      @entity.archive.should == @entity
    end

    it "upon success, should archive itself" do
      @entity.status.should == 'active'
      @entity.archive
      @entity.reload
      @entity.status.should == 'archived'
    end

    it "upon success, should archive all aliases" do
      @entity.lang_aliases.each { |a| a.status.should == 'active' }
      @entity.archive
      @entity.lang_aliases.each do |a| 
        a.reload
        a.status.should == 'archived' 
      end
    end

    it "upon failure to archive itself, should return failure" do
      @entity.stub!(:archive_without_multilingual).and_return(false)
      @entity.archive.should be_false
    end

    it "upon failure to archive itself, should not archive itself" do
      @entity.stub!(:archive_without_multilingual).and_return(false)
      @entity.archive
      @entity.reload
      @entity.status.should == 'active'
    end

    it "upon failure to archive itself, should not archive all aliases" do
      @entity.stub!(:archive_without_multilingual).and_return(false)
      @entity.archive
      @entity.lang_aliases.each do |a| 
        a.reload
        a.status.should == 'active' 
      end
    end

    it "upon failure to archive any alias, should return failure" do
      @entity.lang_aliases[0].stub!(:archive_without_multilingual).and_return(false)
      @entity.archive.should be_false
    end

    it "upon failure to archive any alias, should not archive itself" do
      @entity.lang_aliases[0].stub!(:archive_without_multilingual).and_return(false)
      @entity.archive
      @entity.reload
      @entity.status.should == 'active'
    end

    it "upon failure to archive any alias, should not archive all aliases" do
      @entity.lang_aliases[0].stub!(:archive_without_multilingual).and_return(false)
      @entity.archive
      @entity.lang_aliases.each do |a| 
        a.reload
        a.status.should == 'active' 
      end
    end

  end


end 


# __END__
