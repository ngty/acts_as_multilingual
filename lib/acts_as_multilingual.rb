# $Id: NgTzeYang [nineone@singnet.com.sg] 04 Sep 2008 21:37 $
#


module NgTzeYang
  module ActsAs
    module Multilingual

      def self.included(base)
        base.extend Macro
      end


      module Macro

        protected

          def acts_as_multilingual(opts={})
            create_lang_associations
            write_inheritable_attribute( :actions_for_lang_aliases, [opts[:actions]||[]].flatten )
            extend  ClassMethods
            include InstanceMethods
          end

        private

          def create_lang_associations
            class_eval do

              belongs_to :parent_lang_alias, 
                :class_name => to_param,
                :foreign_key => 'lang_alias_id'

              has_many :child_lang_aliases, 
                :class_name => to_param,
                :foreign_key => 'lang_alias_id',
                :conditions => 'lang_alias_id = #{to_param}'

            end
          end

      end


      module ClassMethods

        def build_with_lang_aliases(attrs)
          entity = new(attrs.shift)
          entity.child_lang_aliases.build(attrs)
          entity
        end

        alias_method :new_with_lang_aliases, :build_with_lang_aliases

        private

          def method_added(meth)
            unless @method_adding
              @method_adding, actions = true, read_inheritable_attribute(:actions_for_lang_aliases)
              create_action_on_lang_aliases(meth) if actions.include?(meth)
              @method_adding = false
            end
          end

          def create_action_on_lang_aliases(action)
            class_eval <<-EOL
              alias_method :#{action}_without_multilingual, :#{action}
              def #{action}
                begin
                  self.class.transaction do
                    lang_aliases.each do | lang_alias | 
                      lang_alias.#{action}_without_multilingual || 
                        raise( 'Cannot #{action} lang alias '+self.class.to_s+'#'+lang_alias.id.to_s+'.' )
                    end
                    #{action}_without_multilingual || 
                      raise( 'Cannot #{action} '+self.class.to_s+'#'+self.id.to_s+'.' )
                  end
                rescue
                  false
                end 
              end
            EOL
          end

      end


      module InstanceMethods

        public 

          def lang_aliases
            aliases = parent_lang_alias? ? 
              child_lang_aliases : [ parent_lang_alias, sibling_lang_aliases ].flatten
          end

          def multilingual?
            true
          end

          def to_lang(lang)
            self.lang == lang ? self : lang_aliases.find { |a| a.lang == lang }
          end

        protected

          def sibling_lang_aliases
            parent_lang_alias? ? [] : 
              parent_lang_alias.child_lang_aliases.reject { | child | child.to_param == to_param }
          end

          def parent_lang_alias?
            parent_lang_alias.nil?
          end

      end 


    end
  end
end



# __END__
