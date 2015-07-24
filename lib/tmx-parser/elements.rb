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

    def copy
      self.class.new(tuid.dup, segtype.dup).tap do |new_unit|
        new_unit.variants.concat(variants.map(&:copy))
        properties.each do |key, property_value|
          new_unit.properties[key] = property_value.copy
        end
      end
    end

    def ==(other_unit)
      tuid == other_unit.tuid &&
        segtype == other_unit.segtype &&
        variants.each_with_index.all? do |v, idx|
          other_unit.variants[idx] == v
        end &&
        properties.each_with_index.all? do |(key, prop_val), idx|
          other_unit.properties[key] == prop_val
        end
    end
  end

  class PropertyValue
    attr_accessor :value

    def initialize(init_value = '')
      @value = init_value
    end

    def receive_text(str)
      @value << str
    end

    def copy
      self.class.new(value.dup)
    end

    def ==(other_property_value)
      value == other_property_value.value
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

    def copy
      self.class.new(locale.dup).tap do |new_variant|
        new_variant.elements.concat(
          elements.map do |element|
            element.respond_to?(:copy) ? element.copy : element.dup
          end
        )
      end
    end

    def ==(other_variant)
      locale == locale &&
        elements.each_with_index.all? do |element, idx|
          other_variant.elements[idx] == element
        end
    end
  end

  class Placeholder
    attr_reader :type, :text
    attr_accessor :start, :length

    def initialize(type, text = '')
      @type = type
      @text = text
    end

    def receive_text(str)
      @text << str
    end

    def copy
      self.class.new(type.dup, text.dup).tap do |new_placeholder|
        new_placeholder.start = start  # can't dup fixnums
        new_placeholder.length = length
      end
    end

    def ==(other_placeholder)
      type == other_placeholder.type &&
        text == other_placeholder.type &&
        start == other_placeholder.start &&
        length == other_placeholder.length
    end
  end

  class Pair
    attr_reader :text, :i

    def initialize(i, text = '')
      @i = i
      @text = text
    end

    def receive_text(str)
      @text << str
    end

    def type
      raise NotImplementedError
    end

    def copy
      self.class.new(i, text.dup)
    end

    def ==(other_pair)
      i == other_pair.i &&
        text == other_pair.text &&
        type == other_pair.type
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
