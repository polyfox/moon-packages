module ES
  class EditorTilePalette < Moon::DataModel::Base
    field :tileset, type: Tileset,   default: proc{|t|t.new}
    array :tiles,   type: Integer
    field :columns, type: Integer,   default: 8

    def rows
      ((tiles.size / columns) + [1, tiles.size % columns].min).to_i
    end
  end
end
