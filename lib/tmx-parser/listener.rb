# encoding: UTF-8

module TmxParser

  class Listener
    include TagNames

    attr_reader :units, :proc

    def initialize(&block)
      @stack = []
      @proc = block
    end

    def unit(tuid, segtype)
      @current_unit = Unit.new(tuid, segtype)
    end

    def variant(locale)
      variant = Variant.new(locale)
      current_unit.variants << variant
      stack.push(variant)
    end

    def property(name)
      val = PropertyValue.new
      current_unit.properties[name] = val
      stack.push(val)
    end

    def text(str)
      if last = stack.last
        last.receive_text(str)
      end
    end

    def done(tag_name)
      if tag_name == UNIT_TAG
        proc.call(current_unit)
      else
        if tag_name_for(stack.last) == tag_name
          stack.pop
        end
      end
    end

    def placeholder(type)
      placeholder = Placeholder.new(type)
      current_unit.variants.last.elements << placeholder
      stack.push(placeholder)
    end

    def begin_paired_tag(i)
      begin_pair = BeginPair.new(i)
      current_unit.variants.last.elements << begin_pair
      stack.push(begin_pair)
    end

    def end_paired_tag(i)
      end_pair = EndPair.new(i)
      current_unit.variants.last.elements << end_pair
      stack.push(end_pair)
    end

    private

    def tag_name_for(obj)
      case obj
        when Variant       then VARIANT_TAG
        when PropertyValue then PROPERTY_TAG
        when Placeholder   then PLACEHOLDER_TAG
        when BeginPair     then BEGIN_PAIRED_TAG
        when EndPair       then END_PAIRED_TAG
      end
    end

    attr_reader :current_unit, :stack

  end
end
