require 'std/core_ext/array'
require 'std/inflector'
require 'std/inflector/core_ext/string'
require 'std/mixins/prototype'
require 'std/mixins/serializable'
require 'data_model/field'
require 'data_model/fields'

class MyFieldsObject
  include Moon::DataModel::Fields

  field :thing, default: nil
end

describe MyFieldsObject do

end
