class Cursor3 < Moon::DataModel::Metal
  field :position, type: Moon::Vector3, default: proc{|t|t.new}
end
