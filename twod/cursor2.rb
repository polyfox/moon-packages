class Cursor2 < Moon::DataModel::Metal
  field :position, type: Moon::Vector2, default: proc{|t|t.new}
end
