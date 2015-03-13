# encoding: UTF-8

require 'nokogiri'

module TmxParser

  class SaxDocument < Nokogiri::XML::SAX::Document
    include TagNames

    attr_reader :listener

    def initialize(listener)
      @listener = listener
      @capture_stack = [false]
      @text = ''
    end

    def start_element(name, attrs = [])
      case name
        when UNIT_TAG
          listener.unit(
            get_attr('tuid', attrs), get_attr('segtype', attrs)
          )
        when VARIANT_TAG
          locale = get_attr('xml:lang', attrs)
          listener.variant(locale)
        when SEGMENT_TAG
          capture_text
        when PROPERTY_TAG
          capture_text
          listener.property(get_attr('type', attrs))
        when BEGIN_PAIRED_TAG
          capture_text
          listener.begin_paired_tag(get_attr('i', attrs))
        when END_PAIRED_TAG
          capture_text
          listener.end_paired_tag(get_attr('i', attrs))
        when PLACEHOLDER_TAG
          capture_text
          listener.placeholder(get_attr('type', attrs))
      end
    end

    def end_element(name)
      @capture_stack.pop
      send_text
      listener.done(name)
    end

    def characters(str)
      @text += str if @capture_stack.last
    end

    private

    def send_text
      listener.text(@text) unless @text.empty?
      @text = ''
    end

    def capture_text
      send_text
      @capture_stack.push(true)
    end

    def get_attr(name, attrs)
      if found = attrs.find { |a| a.first == name }
        found.last
      end
    end
  end

end
