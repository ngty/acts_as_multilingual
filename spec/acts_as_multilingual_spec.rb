# $Id: NgTzeYang [nineone@singnet.com.sg] 06 Sep 2008 13:34 $
# 

require File.dirname(__FILE__) + '/spec_helper'


class MultilingualFirstTestEntity < ActiveRecord::Base
  acts_as_multilingual :actions => :archive
  def archive
    update_attribute( :status, 'archived' ) and self
  end
end 

class MultilingualSecondTestEntity < ActiveRecord::Base
  acts_as_multilingual :foreign_key => :alternate_alias_id
end 

class NonMultilingualTestEntity < ActiveRecord::Base
end


describe "Acting as multilingual" do

  fixtures :multilingual_first_test_entities
  fixtures :multilingual_second_test_entities

  before(:each) do
    @entity = MultilingualFirstTestEntity.new
  end

  def lang_entities(*args)
    entities = [args].flatten.collect do |name| 
      block_given? ? yield(name) : multilingual_first_test_entities(name) 
    end
    entities.length == 1 ? entities.first : entities
  end

  def equal_entities?( entities_1, entities_2 )
    ( entities_1.length == entities_2.length ) and ( entities_1 - entities_2 ).empty?
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
        entity = MultilingualFirstTestEntity.send( meth, @entities_attrs )
        entity.lang.should == @langs[0]
      end

      it "using #{meth.to_s}, should build entity's aliases with remaining sets of attrs" do
        entity = MultilingualFirstTestEntity.send( meth, @entities_attrs )
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


  describe "when declared as multilingual" do
    
    def other_lang_entities(*args)
      lang_entities(*args) { |name| multilingual_second_test_entities(name) }
    end

    it "should support customizing of lang alias foreign key" do
      entity, entity_aliases = other_lang_entities(:en_SG), other_lang_entities( :zh_CN, :en_US )
      equal_entities?( entity.lang_aliases, entity_aliases ).should be_true
    end

  end


  it "entity should identify itself as multilingual" do
    @entity.should be_multilingual
  end

  it "class should identify itself as multilingual" do
    @entity.class.should be_multilingual
  end

  
end 


describe "Acting as non-multilingual" do

  before(:each) do
    @entity = NonMultilingualTestEntity.new
  end

  it "entity should not identify itself as multilingual" do
    @entity.should_not be_multilingual
  end

  it "class should not identify itself as multilingual" do
    @entity.class.should_not be_multilingual
  end

end


# __END__
