InspectorGadget
========

Ever think to yourself "Where did this method get defined?" So did I.  Now I include this file before my stuff boots, then I grep the output.  Currently tracking class definitions (and re-definitions), module definitions, method definitions, method aliasing, dynamic constant definition (using const_set), and module inclusion.  InspectorGadget should give an easily-greppable log that you can use to help you figure out where some monkey-patching or method overriding happened.  

## example ##

    $ ruby -r inspector_gadget.rb my_file.rb

You can also use -e to try it out

    $ ruby -r inspector_gadget.rb -e'class A; end; def A.pants; puts "hello"; end;'

## longer example ##

Let's say we see in our code Dynamic::Programming.foo and Dynamic.foo being called, but we arent sure how it is all being defined.
Let us also assume that we have a file, example.rb, that contains:

    strings = %w{Dynamic Programming Sometimes Sucks}

    # this code intentionally gross to demonstrate inspector_gadget
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

and we run 
  
    ruby -r inspector_gadget.rb example.rb

We will see

    Added method ScopedClassFactoryFactory to Object in example.rb:3
    Dynamically defined constant Dynamic in example.rb:5
    Added singleton method new_scoped_class to Kernel::Dynamic in example.rb:6
    Added singleton method foo to Kernel::Dynamic in example.rb:17
    Dynamically defined constant Programming in example.rb:8
    Added singleton method foo to Kernel::Dynamic::Programming in example.rb:10 

As you can see, the linear print-out is much easier to follow than trying to unwind the source above.  This is an even greater boon when there are modules being mixed-in and extending classes and so on.

## Source Code ##

Main repository is at [http://github.com/aaronblohowiak/inspector_gadget/](http://github.com/aaronblohowiak/inspector_gadget/)

## Running Tests ##
in the inspector_gadget root folder

    $ ruby test/all_tests.rb

## .plan ##
In future versions, I would like to use the object\_id to explicitly call out when methods are being overridden in classes, and to let you pass in an object and a symbol for the method name and get a useful diagram about how and where the method was defined.  Even cooler would be a visualization of the declaration, aliasing and overriding of methods.  Further, I would like to gemify inspector_gadget and supply a convienence script like rcov's.


## Known Issues ##
Presently, class editing that takes the form of eval('class A; end') is not being caught.  I could patch Class.inherited and listen for new classes this way, but then the issue of usable line numbering comes into play.  Along with that, the file/line numbering is bypassed if alias_method has been aliased. For example:

    $ ruby -r inspector_gadget.rb -e 'require "active_record"' | grep split

Will correctly identify
    
    Added method split to ActiveSupport::CoreExtensions::Array::Grouping in /opt/local/lib/ruby/gems/1.8/gems/activesupport-2.3.2/lib/active_support/core_ext/array/grouping.rb:90

But does not have the correct line numbers after BlankSlate is introduced:
    Added method split to BigDecimal in /opt/local/lib/ruby/gems/1.8/gems/builder-2.1.2/lib/blankslate.rb:84
    Added method split_names to Pathname in /opt/local/lib/ruby/gems/1.8/gems/builder-2.1.2/lib/blankslate.rb:84
    Added method split to Pathname in /opt/local/lib/ruby/gems/1.8/gems/builder-2.1.2/lib/blankslate.rb:84

Also, there is no support for the removal of methods / undefinition.

I didn't respect 80 character line widths =/

These aren't blockers for my uses, so I may not fix this in the near future. Please send me your patches / pull requests.

## Contributors ##
  * [Aaron Blohowiak](http://github.com/aaronblohowiak)
  
## License ##
InspectorGadget is released under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL). 
