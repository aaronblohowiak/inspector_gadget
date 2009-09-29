require 'test/lib/inspector_gadget.rb'

class MethodTest < InspectorGadget::TestCase
  def test_singleton_method
    output = inspect <<-EOS
      a = String.new
    
      def a.singleton
        return a.downcase
      end
    EOS
    assert_match(/Added singleton method singleton to/, output)
  end

  def test_proc_method
    output = inspect <<-EOS
      class C
        define_method( :dynamic_method ){|arg| puts arg}
      end
    EOS
    assert_match(/Added method dynamic_method to C/, output)
  end


  def test_class_eval_method
    output = inspect <<-EOS
      class C
      end
      C.class_eval('def dynamic_method;end')
    EOS
    assert_match(/Added method dynamic_method to C/, output)
  end

  def test_eval_method
    output = inspect <<-EOS
      eval('def dynamic_method; end')
    EOS
    assert_match(/Added method dynamic_method to Kernel/, output)
  end

  def test_class_eval_in_module_inclusion
    output = inspect <<-EOS
      module MyModule
        def self.included(base)
         base.class_eval do
           def self.singleton_method
           end

           def instance_method
           end
         end 
        end  
      end

      class MyClass
        include MyModule
      end 
    EOS
    assert_match(/Added singleton method singleton_method to MyClass/, output)
    assert_match(/Added method instance_method to MyClass/, output)
  end

end
