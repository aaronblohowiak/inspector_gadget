strings = %w{Dynamic Programming Sometimes Sucks}

def ScopedClassFactoryFactory(name)
  new_scope = Module.new 
  Kernel.const_set name, new_scope
  def new_scope.new_scoped_class(name)
    new_class = Class.new
    self.const_set(name, new_class)
    class << new_class
      def foo
        puts "huh?"
      end
    end
  end

  new_scope.instance_eval do
    def foo
      puts "hoo"
    end
  end
  return new_scope
end

b = ScopedClassFactoryFactory(strings[0])
c = b.new_scoped_class(strings[1])
