# $Id: NgTzeYang [nineone@singnet.com.sg] 13 Sep 2008 12:50 $
# 

ActiveRecord::Schema.define(:version => 0) do

  create_table :multilingual_first_test_entities, :force => true do |t|
    t.column :lang_alias_id, :integer
    t.column :lang, :string
    t.column :status, :string
    t.timestamps
  end

  create_table :multilingual_second_test_entities, :force => true do |t|
    t.column :alternate_alias_id, :integer
    t.column :lang, :string
    t.timestamps
  end

  create_table :non_multilingual_test_entities, :force => true do |t|
    t.timestamps
  end

end
