# $Id: NgTzeYang [nineone@singnet.com.sg] 06 Sep 2008 11:57 $
# 

class CreateNonMultilingualTestEntities < ActiveRecord::Migration

  def self.up
    create_table :non_multilingual_test_entities do |t|
      t.timestamps
    end
  end

  def self.down
    drop_table :non_multilingual_test_entities
  end

end

# __END__
