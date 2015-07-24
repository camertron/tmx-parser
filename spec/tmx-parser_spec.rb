# encoding: UTF-8

require 'spec_helper'

describe TmxParser do
  let(:parser) { TmxParser }
  let(:tuid) { '79b371014a8382a3b6efb86ec6ea97d9' }

  def find_variant(locale, unit)
    unit.variants.find { |v| v.locale == locale }
  end

  context 'with a basic tmx document' do
    let(:document) do
      %Q{
        <tmx version="1.4">
          <body>
            <tu tuid="#{tuid}" segtype="block">
              <prop type="x-segment-id">0</prop>
              <prop type="x-some-property">six.hours</prop>
              <tuv xml:lang="en-US"><seg>6 hours</seg></tuv>
              <tuv xml:lang="de-DE"><seg>6 Stunden</seg></tuv>
            </tu>
          </body>
        </tmx>
      }
    end

    describe '#copy' do
      it 'deep copies the tree' do
        parser.load(document).to_a.tap do |units|
          original_unit = units.first
          unit_copy = original_unit.copy

          expect(unit_copy.tuid).to eq(original_unit.tuid)
          expect(unit_copy.segtype).to eq(original_unit.segtype)
          expect(unit_copy.variants.size).to eq(original_unit.variants.size)

          unit_copy.properties.each_pair.with_index do |(key, prop_value_copy), idx|
            original_prop_value = original_unit.properties[key]
            expect(original_prop_value.value).to eq(prop_value_copy.value)
          end

          unit_copy.variants.each_with_index do |variant_copy, v_idx|
            original_variant = original_unit.variants[v_idx]
            expect(variant_copy.locale).to eq(original_variant.locale)

            variant_copy.elements.each_with_index do |element_copy, e_idx|
              original_element = original_variant.elements[e_idx]
              expect(element_copy).to be_a(original_element.class)
            end
          end
        end
      end
    end

    describe '#==' do
      it 'returns true if the objects (even copies) are equivalent' do
        parser.load(document).to_a.tap do |units|
          expect(units.first).to eq(units.first.copy)
        end
      end

      it 'returns false if the objects are not equivalent' do
        parser.load(document).to_a.tap do |units|
          unit = units.first
          unit_copy = unit.copy

          unit_copy.tuid.replace('foobar')
          expect(unit).to_not eq(unit_copy)
        end
      end
    end

    it 'identifies the tuid and segtype' do
      parser.load(document).to_a.tap do |units|
        expect(units.size).to eq(1)

        units.first.tap do |unit|
          expect(unit.tuid).to eq(tuid)
          expect(unit.segtype).to eq('block')
        end
      end
    end

    it 'identifies the correct variants' do
      parser.load(document).to_a.first.tap do |unit|
        expect(unit.variants.size).to eq(2)
        expect(find_variant('en-US', unit).elements).to eq(['6 hours'])
        expect(find_variant('de-DE', unit).elements).to eq(['6 Stunden'])

        unit.variants.each do |variant|
          expect(variant).to be_a(TmxParser::Variant)
        end
      end
    end

    it 'identifies properties' do
      parser.load(document).to_a.first.tap do |unit|
        expect(unit.properties.size).to eq(2)
        expect(unit.properties).to include('x-segment-id')
        expect(unit.properties).to include('x-some-property')
        expect(unit.properties['x-segment-id'].value).to eq('0')
        expect(unit.properties['x-some-property'].value).to eq('six.hours')
      end
    end
  end

  context 'with a tmx document that contains a property that makes jruby cry' do
    # For some reason, jruby doesn't like square brackets in property values.
    # See: https://github.com/sparklemotion/nokogiri/issues/1261

    let(:document) do
      %Q{
        <tmx version="1.4">
          <body>
            <tu tuid="#{tuid}" segtype="block">
              <prop type="x-segment-id">0</prop>
              <prop type="x-some-property">en:#:daily-data:#:[3]:#:times</prop>
              <tuv xml:lang="en-US"><seg>6 hours</seg></tuv>
              <tuv xml:lang="de-DE"><seg>6 Stunden</seg></tuv>
            </tu>
          </body>
        </tmx>
      }
    end

    it 'identifies the property correctly' do
      parser.load(document).to_a.first.tap do |unit|
        expect(unit.properties).to include('x-some-property')
        expect(unit.properties['x-some-property']).to be_a(TmxParser::PropertyValue)
        expect(unit.properties['x-some-property'].value).to eq(
          'en:#:daily-data:#:[3]:#:times'
        )
      end
    end
  end

  context 'with a tmx document that contains placeholders' do
    let(:document) do
      %Q{
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
      }
    end

    it 'identifies the placeholders' do
      parser.load(document).to_a.first.tap do |unit|
        expect(unit.variants.size).to eq(2)

        find_variant('en-US', unit).tap do |en_variant|
          expect(en_variant.elements.size).to eq(2)

          en_variant.elements.first.tap do |first_element|
            expect(first_element.type).to eq('x-placeholder')
            expect(first_element.text).to eq('{0}')
          end

          en_variant.elements.last.tap do |last_element|
            expect(last_element).to be_a(String)
            expect(last_element).to eq(' sessions')
          end
        end

        find_variant('de-DE', unit).tap do |en_variant|
          expect(en_variant.elements.size).to eq(2)

          en_variant.elements.first.tap do |first_element|
            expect(first_element).to be_a(TmxParser::Placeholder)
            expect(first_element.type).to eq('x-placeholder')
            expect(first_element.text).to eq('{0}')
          end

          en_variant.elements.last.tap do |last_element|
            expect(last_element).to be_a(String)
            expect(last_element).to eq(' Einheiten')
          end
        end
      end
    end
  end

  context 'with a tmx document that contains paired tags' do
    let(:document) do
      %Q{
        <tmx version="1.4">
          <body>
            <tu tuid="#{tuid}" segtype="block">
              <prop type="x-segment-id">0</prop>
              <tuv xml:lang="en-US">
                <seg>Build your healthy habit of daily training with <bpt i="3">&lt;strong&gt;</bpt>email training reminders.<ept i="3">&lt;/strong&gt;</ept></seg>
              </tuv>
              <tuv xml:lang="de-DE">
                <seg><bpt i="3">&lt;strong&gt;</bpt>Mit Erinnerungen per E-Mail<ept i="3">&lt;/strong&gt;</ept> können Sie das tägliche Training zu einer schönen Angewohnheit werden lassen.</seg>
              </tuv>
            </tu>
          </body>
        </tmx>
      }
    end

    it 'identifies the tags' do
      parser.load(document).to_a.first.tap do |unit|
        expect(unit.variants.size).to eq(2)

        find_variant('en-US', unit).tap do |en_variant|
          expect(en_variant.elements.size).to eq(4)

          en_variant.elements[0].tap do |element|
            expect(element).to be_a(String)
            expect(element).to eq('Build your healthy habit of daily training with ')
          end

          en_variant.elements[1].tap do |element|
            expect(element).to be_a(TmxParser::BeginPair)
            expect(element.i).to eq('3')
            expect(element.text).to eq('<strong>')
          end

          en_variant.elements[2].tap do |element|
            expect(element).to be_a(String)
            expect(element).to eq('email training reminders.')
          end

          en_variant.elements[3].tap do |element|
            expect(element).to be_a(TmxParser::EndPair)
            expect(element.i).to eq('3')
            expect(element.text).to eq('</strong>')
          end
        end
      end
    end
  end
end
