class String
  def pluralize(locale = :en)
    Moon::Inflector.pluralize(self, locale)
  end

  def singularize(locale = :en)
    Moon::Inflector.singularize(self, locale)
  end

  def camelize(uppercase_first_letter = true)
    Moon::Inflector.camelize(self, uppercase_first_letter)
  end

  def underscore
    Moon::Inflector.underscore(self)
  end

  def humanize(options = {})
    Moon::Inflector.humanize(self, options)
  end

  def titleize
    Moon::Inflector.titleize(self)
  end

  def tableize
    Moon::Inflector.tableize(self)
  end

  def classify
    Moon::Inflector.classify(self)
  end

  def dasherize
    Moon::Inflector.dasherize(self)
  end

  def demodulize
    Moon::Inflector.demodulize(self)
  end

  def deconstantize
    Moon::Inflector.deconstantize(self)
  end

  def foreign_key(separate_class_name_and_id_with_underscore = true)
    Moon::Inflector.foreign_key(self, separate_class_name_and_id_with_underscore)
  end

  def constantize
    Moon::Inflector.constantize(self)
  end

  def safe_constantize
    Moon::Inflector.safe_constantize(self)
  end
end
