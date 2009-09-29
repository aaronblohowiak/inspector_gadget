require "lib/object_defintion_event.rb"

module InspectorGadget
  class ClassEdit < ObjectDefinitionEvent
    def self.description
      "Editing class #{@args[:klass]} in #{location}\n"
    end
  end

  class ModuleEdit < ObjectDefinitionEvent
    def self.description
      "Editing module #{@args[:module]} in #{location}\n"
    end
  end

  class SingletonMethodAdded < ObjectDefinitionEvent
    def self.description
      "Added singleton method #{@args[:method]} to #{@args[:klass]} in #{location}\n"
    end
  end

  class FeaturesAppended < ObjectDefinitionEvent
    def self.description
      "Included module #{@args[:module]} into #{@args[:klass]}\ in #{location}\n"
    end
  end

  class MethodAdded < ObjectDefinitionEvent
    def self.description
      "Added method #{@args[:method] } to #{IG.real_to_s(@args[:object])} in #{location}\n"
    end
  end

  class MethodAliased < ObjectDefinitionEvent
    def self.description
      "Aliased method #{@args[:new_method]} to #{@args[:old_method]} in #{location}\n"
    end
  end

  class ConstantSet < ObjectDefinitionEvent
    def self.description
      "Dynamically defined constant #{@args[:constant]} in #{location}\n"
    end
  end
end
