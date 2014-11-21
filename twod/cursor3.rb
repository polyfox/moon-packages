class Cursor3 < Moon::DataModel::Metal
  include Movable3
  field :position, type: Moon::Vector3, default: proc{|t|t.new}
end
