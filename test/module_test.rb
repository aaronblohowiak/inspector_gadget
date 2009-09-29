require 'test/lib/inspector_gadget.rb'

class ModuleTest < InspectorGadget::TestCase
  def test_module_edit
    output = inspect('module A;end')
    assert_match(/Editing module A/, output)
  end

  def test_module_include
    output = inspect <<-EOS
      module MyModule
        def self.singleton_method
        end
      end

      class MyClass
        include MyModule
      end
    EOS
    assert_match(/Included module MyModule into MyClass/, output)
  end

  
  def test_module_include_with_send
    output = inspect <<-EOS
      module MyModule
        def self.singleton_method
        end
      end

      class MyClass; end
      MyClass.send :include, MyModule
    EOS
    assert_match(/Included module MyModule into MyClass/, output)
  end

    
  def test_method_added_to_module
    output = inspect <<-EOS
      module MyModule
        def module_method
        end
      end
    EOS
    assert_match(/Added method module_method to MyModule/, output)
  end

  def test_method_aliased_in_module
    output = inspect <<-EOS
      module MyModule
        def module_method
        end

        alias_method :old_module_method, :module_method
      end
    EOS
    assert_match(/Aliased method old_module_method to module_method/, output)
  end

end
