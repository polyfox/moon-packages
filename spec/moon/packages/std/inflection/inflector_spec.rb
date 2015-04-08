require 'std/core_ext/object'
require 'std/core_ext/array'
require 'std/inflector'

describe Moon::Inflector do
  subject(:inf) { Moon::Inflector }

  # pluralize(word, locale = :en)
  context '.pluralize' do
    it 'it should pluralize a word' do
      expect(inf.pluralize 'Mouse').to eq('Mice')
    end
  end

  # singularize(word, locale = :en)
  context '.singularize' do
    it 'it should singularize a word' do
      expect(inf.singularize 'Camels').to eq('Camel')
    end
  end

  # camelize(term, uppercase_first_letter = true)
  context '.camelize' do
    it 'it should camelize a word' do
      expect(inf.camelize 'butch_stewart').to eq('ButchStewart')
    end
  end

  # underscore(camel_cased_word)
  context '.underscore' do
    it 'it should underscore a word' do
      expect(inf.underscore 'DisplayObject').to eq('display_object')
    end
  end

  # humanize(lower_case_and_underscored_word, options = {})
  context '.humanize' do
    it 'it should humanize a word' do
      expect(inf.humanize 'display_object').to eq('Display object')
    end
  end

  # titleize(word)
  context '.titleize' do
    it 'it should titleize a word' do
      expect(inf.titleize 'display_object').to eq('Display Object')
    end
  end

  # tableize(class_name)
  context '.tableize' do
    it 'it should tableize a word' do
      expect(inf.tableize 'display_object').to eq('display_objects')
    end
  end

  # classify(table_name)
  context '.classify' do
    it 'it should classify a word' do
      expect(inf.classify 'display_object').to eq('DisplayObject')
    end
  end

  # dasherize(underscored_word)
  context '.dasherize' do
    it 'it should dasherize a word' do
      expect(inf.dasherize 'display_object').to eq('display-object')
    end
  end

  # demodulize(path)
  context '.demodulize' do
    it 'it should demodulize a word' do
      expect(inf.demodulize 'Moon').to eq('Moon')
      expect(inf.demodulize 'Moon::DisplayObject').to eq('DisplayObject')
    end
  end

  # deconstantize(path)
  context '.deconstantize' do
    it 'it should deconstantize a word' do
      expect(inf.deconstantize 'World::Politics').to eq('World')
      expect(inf.deconstantize 'MY_GREATEST_OBJECT').to eq('')
    end
  end

  # foreign_key(class_name, separate_class_name_and_id_with_underscore = true)
  context '.foreign_key' do
    it 'it should foreign_key a word' do
      expect(inf.foreign_key 'Moon::Vector4').to eq('vector4_id')
    end
  end

  # constantize(camel_cased_word)
  context '.constantize' do
    it 'it should constantize a word' do
      expect(inf.constantize 'Moon').to eq(Moon)
      expect(inf.constantize 'Moon::Inflector').to eq(Moon::Inflector)
    end
  end

  # safe_constantize(camel_cased_word)
  context '.safe_constantize' do
    it 'it should safe_constantize a word' do
      expect(inf.safe_constantize 'SomeModuleThatDoesntExist').to eq(nil)
      expect(inf.safe_constantize 'Moon').to eq(Moon)
      expect(inf.safe_constantize 'Moon::Inflector').to eq(Moon::Inflector)
      expect(inf.safe_constantize 'Object::Array').to eq(Array)
    end
  end

  # ordinal(number)
  context '.ordinal' do
    it 'it should ordinal a word' do
      expect(inf.ordinal 1).to eq('st')
      expect(inf.ordinal 2).to eq('nd')
      expect(inf.ordinal 3).to eq('rd')
      expect(inf.ordinal 11).to eq('th')
    end
  end

  # ordinalize(number)
  context '.ordinalize' do
    it 'it should ordinalize a word' do
      expect(inf.ordinalize 1).to eq('1st')
      expect(inf.ordinalize 2).to eq('2nd')
      expect(inf.ordinalize 3).to eq('3rd')
      expect(inf.ordinalize 13).to eq('13th')
      expect(inf.ordinalize 27).to eq('27th')
    end
  end
end
