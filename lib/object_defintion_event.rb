module InspectorGadget
  class ObjectDefinitionEvent
    def self.output
      @@out ||= STDOUT # monkeypatch this to redirect output, say, to a file
    end
    
    def self.output=(ostr)
      if ostr.respond_to? :<<
        @@out = ostr 
      else
        raise 'whoops. output needs to respond to <<'
      end
    end
    
    def output
      self.class.output
    end

    attr :args
    def self.new(args)
      @args = args 
      output << description
    end

    def self.description
      "#{self.to_s}.new \n"
    end

    def self.location
      "#{@args[:location][:file]}:#{@args[:location][:line]}"
    end
  end
end
