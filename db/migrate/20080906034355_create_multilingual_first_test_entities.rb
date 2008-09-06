# $Id: NgTzeYang [nineone@singnet.com.sg] 06 Sep 2008 11:57 $
# 

class CreateMultilingualFirstTestEntities < ActiveRecord::Migration

  def self.up
    create_table :multilingual_first_test_entities do |t|
      t.column :lang_alias_id, :integer
      t.column :lang, :string
      t.column :status, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :multilingual_first_test_entities
  end

end

# __END__
