# encoding: UTF-8

require 'nokogiri'

module TmxParser
  autoload :Document,      'tmx-parser/document'
  autoload :SaxDocument,   'tmx-parser/sax_document'
  autoload :Listener,      'tmx-parser/listener'
  autoload :TagNames,      'tmx-parser/tag_names'
  autoload :Unit,          'tmx-parser/elements'
  autoload :PropertyValue, 'tmx-parser/elements'
  autoload :Variant,       'tmx-parser/elements'
  autoload :Placeholder,   'tmx-parser/elements'
  autoload :BeginPair,     'tmx-parser/elements'
  autoload :EndPair,       'tmx-parser/elements'

  def self.load(string_or_file_handle, encoding = Encoding.default_external)
    Document.new(string_or_file_handle, encoding)
  end
end
