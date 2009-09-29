require 'test/unit'

module InspectorGadget
  #This is a base class, inherit from it for more IG test cases
  class TestCase < Test::Unit::TestCase
    def inspect(string)
      `ruby -r inspector_gadget.rb -e"#{string}"`
    end

    def default_test
      # suppress no test error from Test::Unit
    end
  end
end
