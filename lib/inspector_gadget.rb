require File.dirname(__FILE__) + '/definition_event_dispatcher.rb'

module InspectorGadget
  METHOD_PREFIX = "__com_aaronblohowiak_inspector_gadget"
  IG = self

  def self.real_to_s(object)
    call_original_method object, "to_s" 
  end

  def self.real_class(object)
    call_original_method(object, "class")
  end

  def self.real_object_id(object)
    call_original_method object, "object_id"
  end

  def self.call_original_method(object, method)
    object.send((METHOD_PREFIX+"_"+method).to_sym)
  end

  module MetaprogrammingWatchdog
    def watch(*my_args)
      my_args.each do |method|
        self.send :alias_method, "#{METHOD_PREFIX}_#{method}", "#{method}"
          self.class_eval <<-END
            def #{method}(*args, &blk)
              #{METHOD_PREFIX}_#{method}( *args, &blk)
            end
        END
      end
    end
  end

  def self.alias_methods_for_easy_tracing
    {
      Kernel => [:method_missing, :eval, :class],
      Object => [ :extend, :object_id, :singleton_method_added, 
                  :singleton_method_removed, :singleton_method_undefined, :to_s],
      Class => [:define_method],
      Module => [:const_set,  :append_features, :included, :alias_method, 
                  :method_added, :method_undefined, :method_removed, :to_s]
    }.each_pair do |klass, ary|
      klass.send( :include, MetaprogrammingWatchdog )
      klass.send( :watch, *ary.map{|e| e.to_s } )
    end
  end

  def self.trace_proc
    proc { |event, file, line, id, binding, classname|
      #also add in class creation.. inherited doesn't always catch it!
      if event.end_with?("call") && id.to_s.start_with?(InspectorGadget::METHOD_PREFIX) || event == "class"
        file = @last_file
        line = @last_line.to_s
        InspectorGadget::DefinitionEventDispatcher.dispatch_trace_func(event, file, line, id, binding, classname)
      end
      
      if event == "line" && file != "(eval)"
        @last_file = file
        @last_line = line
      end
    }
  end

end
