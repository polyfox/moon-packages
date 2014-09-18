Data Model
==========

Be sure to set a validator before using DataModel using:
```
# soft validator
Moon::DataModel::Field.validator = Moon::DataModel::Validators::Soft

# verbose validator
Moon::DataModel::Field.validator = Moon::DataModel::Validators::Verbose

# null validator
Moon::DataModel::Field.validator = Moon::DataModel::Validators::Null
```
