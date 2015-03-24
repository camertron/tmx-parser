# encoding: UTF-8

module TmxParser
  class Document

    include Enumerable

    attr_reader :string_or_file_handle, :encoding

    def initialize(string_or_file_handle, encoding = Encoding.default_external)
      @string_or_file_handle = string_or_file_handle
      @encoding = encoding
    end

    def each(&block)
      if block_given?
        listener = Listener.new(&block)
        document = SaxDocument.new(listener)
        parser = Nokogiri::XML::SAX::Parser.new(document, encoding.to_s)
        parser.parse(string_or_file_handle)
      else
        to_enum(__method__)
      end
    end

  end
end
