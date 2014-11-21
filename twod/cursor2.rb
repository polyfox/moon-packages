class Cursor2 < Moon::DataModel::Metal
  include Movable2
  field :position, type: Moon::Vector2, default: proc{|t|t.new}
end
