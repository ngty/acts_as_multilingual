# $Id: NgTzeYang [nineone@singnet.com.sg] 06 Sep 2008 13:35 $
# 

class CreateMultilingualSecondTestEntities < ActiveRecord::Migration

  def self.up
    create_table :multilingual_second_test_entities do |t|
      t.column :alternate_alias_id, :integer
      t.column :lang, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :multilingual_second_test_entities
  end

end

# __END__
