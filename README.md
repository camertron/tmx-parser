tmx-parser
=================

Parser for the Translation Memory eXchange (.tmx) file format.

## Installation

`gem install tmx-parser`

## Usage

```ruby
require 'tmx-parser'
```

## Functionality

Got a .tmx file you need to parse? Just use the `TmxParser#load` method. It'll return an enumerable `TmxParser::Document` object for your iterating pleasure:

```ruby
doc = TmxParser.load(File.open('path/to/my.tmx'))
doc.each do |unit|
  ...
end
```

You can also pass a string to `#load`:

```ruby
doc = TmxParser.load(File.read('path/to/my.tmx'))
```

The parser works in a streaming fashion, meaning it tries not to hold the entire source document in memory all at once. It will instead yield each translation unit incrementally.

## Translation Units

Translation units are simple Ruby objects that contain properties (tmx `<prop>` elements) and variants (tmx `tuv` elements). You can also retrieve the tuid (translation unit id) and segtype (segment type). Given this document:

```xml
<tmx version="1.4">
  <body>
    <tu tuid="79b371014a8382a3b6efb86ec6ea97d9" segtype="block">
      <prop type="x-segment-id">0</prop>
      <prop type="x-some-property">six.hours</prop>
      <tuv xml:lang="en-US"><seg>6 hours</seg></tuv>
      <tuv xml:lang="de-DE"><seg>6 Stunden</seg></tuv>
    </tu>
  </body>
</tmx>
```

Here's what you can do:

```ruby
doc.each do |unit|
  unit.tuid     # => "79b371014a8382a3b6efb86ec6ea97d9"
  unit.segtype  # => "block"

  unit.properties.keys                   # => ["x-segment-id", "x-some-property"]
  unit.properties['x-segment-id'].value  # => "0"

  variant = unit.variants.first
  variant.locale    # => "en-US"
  variant.elements  # => ["6 hours"]
end
```

## Placeholders

Let's consider a different document:

```xml
<tmx version="1.4">
  <body>
    <tu tuid="#{tuid}" segtype="block">
      <prop type="x-segment-id">0</prop>
      <tuv xml:lang="en-US">
        <seg><ph type="x-placeholder">{0}</ph> sessions</seg>
      </tuv>
      <tuv xml:lang="de-DE">
        <seg><ph type="x-placeholder">{0}</ph> Einheiten</seg>
      </tuv>
    </tu>
  </body>
</tmx>
```

The placeholders will be added to the variant's `elements` array:

```ruby
doc.each do |unit|
  variant = unit.variants.first
  variant.elements  # => ["#<TmxParser::Placeholder:0x5ad5be4a @text="{0}", @type="x-placeholder">", " sessions"]
end
```

Begin paired tags (tmx `bpt` elements) and end paired tags (tmx `ept` elements) are handled the same way.

## See Also

* TMX file format: [http://www.gala-global.org/oscarStandards/tmx/tmx14b.html](http://www.gala-global.org/oscarStandards/tmx/tmx14b.html)

## Requirements

No external requirements.

## Running Tests

`bundle exec rspec` should do the trick :)

## Authors

* Cameron C. Dutro: http://github.com/camertron
