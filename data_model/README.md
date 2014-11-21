Data Model
==========

Be sure to set a Type Validator before using DataModel:
```ruby
# soft validator
Moon::DataModel::Field.type_validator = Moon::DataModel::TypeValidators::Soft

# verbose validator
Moon::DataModel::Field.type_validator = Moon::DataModel::TypeValidators::Verbose

# null validator
Moon::DataModel::Field.type_validator = Moon::DataModel::TypeValidators::Null
```
