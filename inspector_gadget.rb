require 'rubygems'

NO_TRACE_FUNC = false
MUTE_WATCHDOG_OUTPUT = true

class MonkeyingAround

  def self.output
    @out ||= STDOUT
  end
  
  def self.output=(ostr)
    if ostr.respond_to? :<<
      @out = ostr 
    else
      raise 'whoops. output needs to respond to <<'
    end
  end
  
  attr :args
  def self.new(*args)
    self.output << "#{self.to_s}.new \n" #"("+args.inspect+")"
    @args = args 
  end
  
  def output
    self.class.output
  end
end


module MetaprogrammingWatchdog
  def watch(*my_args)
    my_args.each do |method|
      self.send :alias_method, "__BLOHOWIAK_#{method}", "#{method}"
      if NO_TRACE_FUNC
            self.class_eval <<-END
            def #{method}(*args, &blk)
              printf "#{method} \#{args.inspect}\n" unless #{method.to_s == "to_s"}
              __BLOHOWIAK_#{method}( *args, &blk)
            end
      END
      else
          self.class_eval <<-END
            def #{method}(*args, &blk)
              __BLOHOWIAK_#{method}( *args, &blk)
            end
      END
      end
    end
  end
end

{
  Kernel => [:method_missing, :eval, :class],
  Object => [ :extend, :object_id, :singleton_method_added, 
              :singleton_method_removed, :singleton_method_undefined, :to_s],
  Class => [:define_method, :inherited],
  Module => [:const_set,  :append_features, :included, :alias_method, 
              :method_added, :method_undefined, :method_removed, :to_s]
}.each_pair do |klass, ary|
  klass.send( :include, MetaprogrammingWatchdog )
  klass.send( :watch, *ary.map{|e| e.to_s } )
end

class ClassEdit < MonkeyingAround
  
end

class ModuleEdit < MonkeyingAround
  def self.new(args)
    output << "Editing module #{args[:module]} in #{args[:location]}\n"
  end
end

class SingletonMethodAdded < MonkeyingAround
  def self.new(args)
    output <<  "Added singleton method #{args[:method]} \
 to #{args[:klass]} in\
 #{args[:location]}\n"
  end
end

class FeaturesAppended < MonkeyingAround
  def self.new(args)
    output <<  "Included module #{args[:module]} into \
 #{args[:klass]}\
 in #{args[:location]}\n"
  end
end

class MethodAdded < MonkeyingAround
  def self.new(args)
    output << "Added method #{ args[:method] } \
 to #{args[:object].__BLOHOWIAK_to_s}\
 in #{args[:location]}\n"
  end
end

class ConstantSet < MonkeyingAround
  def self.new(args)
    output <<  "Dynamically defined constant #{args[:constant]} \
 in #{args[:location]}\n"
  end
end

class Handler  
  def self.method_id_for(b, arg)
    b.eval("instance_method(#{arg}.to_sym).__BLOHOWIAK_object_id").__BLOHOWIAK_to_s
  end
    
  def self.id_for(b, arg)
    b.eval("#{arg}.__BLOHOWIAK_object_id").__BLOHOWIAK_to_s
  end
  
  def self.dispatch_trace_func(*args)
    event, file, line, id, b, classname = args
    #print b.eval("args[0]").to_s+" has ruby id "+"(#{self.id_for(b,0).to_s})"+"\n"
    method = id.to_s.sub( "__BLOHOWIAK_", '')
    loc =  "#{file}:#{line} "
    object = eval('self', b)
    object_id = "(#{self.id_for(b,'self').__BLOHOWIAK_to_s}) "
    subject = b.eval("args[0] rescue nil")

    if method.length > 0
      case method
      when "method_added"
        MethodAdded.new(:location => loc, 
                        :method => subject, 
                        :method_id => self.method_id_for(b,'args[0]'),
                        :object => object
                        )
      when "alias_method"
        #TODO: make a class for this as well!
        print "Aliased method #{b.eval("args[1]")} to #{subject.to_s} in #{loc}\n"
      when "append_features"
        FeaturesAppended.new(:location => loc, :module => subject, :klass=>object )
      when "singleton_method_added"
        SingletonMethodAdded.new(:location=>loc, :method => subject, :object_id =>subject.__BLOHOWIAK_object_id, :klass=>object, :klass_id =>object_id)
      when "const_set"
        ConstantSet.new(:location => loc, :constant => subject, :value=> b.eval('args[1]') )
      end
    else
      case object.__BLOHOWIAK_class.__BLOHOWIAK_to_s
      when "Module"
        ModuleEdit.new(:location => loc, :module => object)
      when "Class"
        ClassEdit.new(:location => loc, :klass =>object )
      end
    end
  end
end
    

class Class
  def inherited(klass)
    puts "(#{self.to_s} INHERITED: "+klass.to_s+")"
  end
end

set_trace_func proc { |event, file, line, id, binding, classname|
  
  #also add in class creation.. inherited doesn't always catch it!
  if event.end_with?("call") && id.to_s.start_with?( "__BLOHOWIAK") || event == "class"
    file = @last_file
    line = @last_line.to_s
    Handler.dispatch_trace_func(event, file, line, id, binding, classname)
  end
  
  if event == "line" && file != "(eval)"
    @last_file = file
    @last_line = line
  end
} unless NO_TRACE_FUNC


#require 'ActiveRecord'
  
#__END__
#TODO: Make a test suite out of the following
module Stack
 @@stack = [ ]
  
 def self.included(base)
   @@stack << base
   
   base.class_eval do
     def self.inherited(child)
       @@stack << child
     end
     
     def self.show_stack
       @@stack
    end
   end 
 end  # included
 
  def pants
    "3. ????"
  end
end # module

class A
 include Stack
end 

class B<A
end

class C<B
  class Q
    def poop
    end
  end
end

class C::D
end

CRAP="yea"
Object.const_set("FUCK", "yea")

a = B.new

def a.great
  return "aaron"
end

class Aaron; end;

class C; define_method( :aaron ){|yo| puts yo};end;

eval "class D; end; class D; end"

class Aaron  
  def monkey
    "monkey"
  end
  
  alias_method :oldmonkey, :monkey
  
  def monkey
    "new monkey"
  end
  
  def self.monkeyr
    "grand kahuna monkey"
  end
end

class Aaron
  def monkey
    "oh no"
  end
end

Aaron.class_eval("def monkey;'oh yea';end")


#set_trace_func nil

