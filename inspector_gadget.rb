require 'rubygems'
require File.dirname(__FILE__) + '/lib/inspector_gadget.rb'

InspectorGadget.alias_methods_for_easy_tracing
set_trace_func InspectorGadget.trace_proc
  
