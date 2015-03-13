# encoding: UTF-8

module TmxParser
  class Document

    include Enumerable

    attr_reader :string_or_file_handle

    def initialize(string_or_file_handle)
      @string_or_file_handle = string_or_file_handle
    end

    def each(&block)
      if block_given?
        listener = Listener.new(&block)
        document = SaxDocument.new(listener)
        parser = Nokogiri::XML::SAX::Parser.new(document)
        parser.parse(string_or_file_handle)
      else
        to_enum(__method__)
      end
    end

  end
end
