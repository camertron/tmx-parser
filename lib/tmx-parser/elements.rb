# encoding: UTF-8

module TmxParser

  class Unit
    attr_reader :tuid, :segtype, :properties, :variants

    def initialize(tuid, segtype)
      @tuid = tuid
      @segtype = segtype
      @properties = {}
      @variants = []
    end
  end

  class PropertyValue
    attr_accessor :value

    def initialize
      @value = ''
    end

    def receive_text(str)
      @value << str
    end
  end

  class Variant
    attr_reader :locale
    attr_accessor :elements

    def initialize(locale)
      @locale = locale
      @elements = []
    end

    def receive_text(str)
      @elements << str
    end
  end

  class Placeholder
    attr_reader :type, :text
    attr_accessor :start, :length

    def initialize(type)
      @type = type
      @text = ''
    end

    def receive_text(str)
      @text << str
    end
  end

  class Pair
    attr_reader :text, :i

    def initialize(i)
      @i = i
      @text = ''
    end

    def receive_text(str)
      @text << str
    end

    def type
      raise NotImplementedError
    end
  end

  class BeginPair < Pair
    def type
      :begin
    end
  end

  class EndPair < Pair
    def type
      :end
    end
  end

end
