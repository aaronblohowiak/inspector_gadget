InspectorGadget
========

Ever think to yourself "Where did this method get defined?" So did I.  Now I include this file before my stuff boots, then I grep the output.  Currently tracking class definitions (and re-definitions), module definitions, method definitions, method aliasing, dynamic constant definition (using const_set), and module inclusion.  InspectorGadget should give an easily-greppable log that you can use to help you figure out where some monkey-patching or method overriding happened.  

## example ##

    $ ruby -r inspector_gadget.rb my_file.rb

You can also use -e to try it out

    $ ruby -r inspector_gadget.rb -e'class A; end; def A.pants; puts "hello"; end;'

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

This isn't an issue for my uses, so I may not fix this in the near future. Please send me your patches / pull requests.

## Contributors ##
  * [Aaron Blohowiak](http://github.com/aaronblohowiak)
  
## License ##
InspectorGadget is released under the [WTFPL](http://en.wikipedia.org/wiki/WTFPL). 
