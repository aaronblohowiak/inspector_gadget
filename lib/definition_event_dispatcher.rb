require 'lib/object_defintion_events.rb'

module InspectorGadget
  class DefinitionEventDispatcher
    def self.method_id_for(b, arg)
      # use eval with send instead of IG.real_object_id to preserve line numbers
      IG.real_to_s(b.eval("instance_method(#{arg}.to_sym).send(:#{METHOD_PREFIX}_object_id)"))
    end
      
    def self.id_for(b, arg)
      # use eval with send instead of IG.real_object_id to preserve line numbers
      IG.real_to_s(b.eval("#{arg}.send(:#{METHOD_PREFIX}_object_id)"))
    end
    
    def self.dispatch_trace_func(*args)
      event, file, line, id, b, classname = args

      method = id.to_s.sub( METHOD_PREFIX+"_", '')
      loc =  {:file => file, :line => line}
      object = b.eval('self')
      object_id = "(#{IG.real_to_s(self.id_for(b,'self'))}) "
      subject = b.eval("args[0] rescue nil")

      if method.length > 0
        case method
        when "method_added"
          MethodAdded.new(
            :location => loc, 
            :method => subject, 
            :method_id => self.method_id_for(b,'args[0]'),
            :object => object
          )
        when "alias_method"
          MethodAliased.new(
            :location => loc,
            :old_method => b.eval("args[1]"),
            :new_method => subject.to_s
          )
        when "append_features"
          FeaturesAppended.new(
            :location => loc, 
            :module => object, 
            :klass=> subject 
          )
        when "singleton_method_added"
          SingletonMethodAdded.new(
            :location=>loc, 
            :method => subject, 
            :object_id =>IG.real_object_id(subject), 
            :klass=>object, 
            :klass_id =>object_id
          )
        when "const_set"
          ConstantSet.new(
            :location => loc, 
            :constant => subject,
            :value => b.eval('args[1]') 
          )
        end
      else
        case IG.real_to_s(IG.real_class(object))
        when "Module"
          ModuleEdit.new(
            :location => loc, 
            :module => object
          )
        when "Class"
          ClassEdit.new(
            :location => loc, 
            :klass =>object
          )
        end
      end
    end

  end 

end
