# coding: utf-8

require 'spec_helper'

describe ActiveInteraction do
  context 'I18n.load_path' do
    it 'contains localization file paths at the beginning' do
      expect(
        I18n.load_path.first
      ).to match %r{active_interaction/locale/en.yml\z}
    end
  end
end

I18nInteraction = Class.new(TestInteraction) do
  hash :a do
    hash :x
  end
end

describe I18nInteraction do
  include_context 'interactions'

  TYPES = ActiveInteraction::Filter
    .const_get(:CLASSES)
    .map { |slug, _| slug.to_s }

  shared_examples 'translation' do
    context 'types' do
      TYPES.each do |type|
        it "has a translation for #{type}" do
          key = "#{described_class.i18n_scope}.types.#{type}"
          expect { I18n.translate(key, raise: true) }.to_not raise_error
        end
      end
    end

    context 'error messages' do
      let(:translation) { I18n.translate(key, type: type, raise: true) }
      let(:type) { I18n.translate("#{described_class.i18n_scope}.types.hash") }

      shared_examples 'translations' do |key, value|
        context key.inspect do
          let(:key) { "#{described_class.i18n_scope}.errors.messages.#{key}" }

          before { inputs[:a] = value }

          it 'has a translation' do
            expect { translation }.to_not raise_error
          end

          it 'returns the translation' do
            expect(outcome.errors[:a]).to include translation
          end
        end
      end

      include_examples 'translations', :invalid_type, Object.new
      include_examples 'translations', :missing, nil
    end
  end

  context 'english' do
    include_examples 'translation'

    before do
      @locale = I18n.locale
      I18n.locale = :en
    end

    after { I18n.locale = @locale }
  end

  context 'hsilgne' do
    include_examples 'translation'

    before do
      I18n.backend.store_translations('hsilgne',
        active_interaction: {
          errors: {
            messages: {
              invalid: 'is invalid'.reverse,
              invalid_type: "%{type} #{'is not a valid'.reverse}",
              missing: 'missing'.reverse
            }
          },
          types: TYPES.each_with_object({}) { |e, a| a[e] = e.reverse }
        }
      )

      @locale = I18n.locale
      I18n.locale = 'hsilgne'
    end

    after { I18n.locale = @locale }
  end
end
