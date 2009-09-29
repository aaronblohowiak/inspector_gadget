require 'test/lib/inspector_gadget.rb'

class ClassTest < InspectorGadget::TestCase
  def test_class_definition
    output = inspect('class A;end')
    assert_match(/Editing class A/, output)
  end

  def test_class_overriding
    output = inspect('class A; end; class A; end')
    assert_same(2, output.scan(/Editing class A/).size)
  end

  def test_singleton_method
    output = inspect <<-EOS
      class A
        def self.singleton
        end
      end
    EOS
    assert_match(/Added singleton method singleton to A/, output)
  end

  def test_singleton_method
    output = inspect <<-EOS
      class A
      end
    
      a_instance = A.new
      class << a_instance
        def hi
        end
      end
    EOS
    assert_match(/Added singleton method hi to/, output)
  end

  def test_singleton_method_override
    output = inspect <<-EOS
      class A
        def hello
        end
      end

      a_instance = A.new

      class << a_instance
        def hello
        end
      end
    EOS
    assert_match(/Added method hello to/, output)
    assert_match(/Added singleton method hello to/, output)
  end

  def test_member_classes
    output = inspect <<-EOS
      class A
        class Member
        end
      end
    EOS
    assert_match(/Editing class A::Member/, output)
  end


  def test_dynamic_classes
    output = inspect <<-EOS
      dynamic_class = Class.new 
      class << dynamic_class
        def method
        end
      end
    EOS
    assert_match(/Editing class #<Class/, output)
  end

  def test_class_eval
    output = inspect <<-EOS
      eval('class A; end') 
    EOS
    assert_match(/Editing class A/, output)
  end
end
