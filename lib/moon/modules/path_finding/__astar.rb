__END__
module PathFinding
  module AStar
    # Initializes Astar for a map and an actor
    def self.init(map, actor)
      self.map = map
      self.actor = actor
      self.move_cache = {}
    end

    # The default heuristic for A*, tries to come close to the straight path
    def self.heuristic_closer_path(sx, sy, cx, cy, tx, ty)
      #if util.is_hex?
      #  h = core.fov.distance(cx, cy, tx, ty)
      #else
        # Chebyshev  distance
        h = math.max(math.abs(tx - cx), math.abs(ty - cy))
      #end

      # tie-breaker rule for straighter paths
      dx1 = cx - tx
      dy1 = cy - ty
      dx2 = sx - tx
      dy2 = sy - ty
      h + 0.01*math.abs(dx1*dy2 - dx2*dy1)
    end

    # The a simple heuristic for A*, using distance
    def self.heuristicDistance(sx, sy, cx, cy, tx, ty)
      core.fov.distance(cx, cy, tx, ty)
    end

    def self.to_single(x, y)
      x + y * self.map.w
    end

    def self.to_double(c)
      y = math.floor(c / self.map.w)
      return c - y * self.map.w, y
    end

    def self.createPath(came_from, cur)
      if not came_from[cur] then return end
      rpath, path = {}, {}
      while came_from[cur] do
        x, y = self.to_double(cur)
        rpath[rpath.size+1] = {x=x,y=y}
        cur = came_from[cur]
      end

      for i = rpath, 1, -1 do path[#path+1] = rpath[i] end
      return path
    end

    # Compute path from sx/sy to tx/ty
    # @param sx the start coord
    # @param sy the start coord
    # @param tx the end coord
    # @param ty the end coord
    # @param use_has_seen if true the astar wont consider non-has_seen grids
    # @param add_check a def that checks each x/y coordinate and returns true if the coord is valid
    # @return either nil if no path or a list of nodes in the form { {x=...,y=...}, {x=...,y=...}, ..., {x=tx,y=ty}}
    def self.calc(sx, sy, tx, ty, use_has_seen, heuristic, add_check, forbid_diagonals)
      heur = heuristic or self.heuristic_closer_path
      w, h = self.map.w, self.map.h
      start = self.to_single(sx, sy)
      stop = self.to_single(tx, ty)
      open = {[start]=true}
      closed = {}
      g_score = {[start] = 0}
      h_score = {[start] = heur(self, sx, sy, sx, sy, tx, ty)}
      f_score = {[start] = heur(self, sx, sy, sx, sy, tx, ty)}
      came_from = {}

      cache = self.map._fovcache.path_caches[self.actor.getPathString()]
      checkPos
      if cache then
        if not (self.map.isBound(tx, ty) and ((use_has_seen and not self.map.has_seens(tx, ty)) or not cache.get(tx, ty))) then
          print("Astar fail. destination unreachable")
          return nil
        end
        checkPos = def(node, nx, ny)
          nnode = self.to_single(nx, ny)
          if not closed[nnode] and self.map.isBound(nx, ny) and ((use_has_seen and not self.map.has_seens(nx, ny)) or not cache.get(nx, ny)) and (not add_check or add_check(nx, ny)) then
            tent_g_score = g_score[node] + 1 # we can adjust here for difficult passable terrain
            tent_is_better = false
            if not open[nnode] then open[nnode] = true; tent_is_better = true
            elseif tent_g_score < g_score[nnode] then tent_is_better = true
            end

            if tent_is_better then
              came_from[nnode] = node
              g_score[nnode] = tent_g_score
              h_score[nnode] = heur(self, sx, sy, tx, ty, nx, ny)
              f_score[nnode] = g_score[nnode] + h_score[nnode]
            end
          end
        end
      else
        if not (self.map.isBound(tx, ty) and ((use_has_seen and not self.map.has_seens(tx, ty)) or not self.map.checkEntity(tx, ty, Map.TERRAIN, "block_move", self.actor, nil, true))) then
          print("Astar fail. destination unreachable")
          return nil
        end
        checkPos = def(node, nx, ny)
          nnode = self.to_single(nx, ny)
          if not closed[nnode] and self.map.isBound(nx, ny) and ((use_has_seen and not self.map.has_seens(nx, ny)) or not self.map.checkEntity(nx, ny, Map.TERRAIN, "block_move", self.actor, nil, true)) and (not add_check or add_check(nx, ny)) then
            tent_g_score = g_score[node] + 1 # we can adjust here for difficult passable terrain
            tent_is_better = false
            if not open[nnode] then open[nnode] = true; tent_is_better = true
            elseif tent_g_score < g_score[nnode] then tent_is_better = true
            end

            if tent_is_better then
              came_from[nnode] = node
              g_score[nnode] = tent_g_score
              h_score[nnode] = heur(self, sx, sy, tx, ty, nx, ny)
              f_score[nnode] = g_score[nnode] + h_score[nnode]
            end
          end
        end
      end

      while next(open) do
        # Find lowest of f_score
        node, lowest = nil, 999999999999999
        n, _ = next(open)
        while n do
          if f_score[n] < lowest then node = n; lowest = f_score[n] end
          n, _ = next(open, n)
        end

        if node == stop then return self.createPath(came_from, stop) end

        open[node] = nil
        closed[node] = true
        x, y = self.to_double(node)

        # Check sides
        for _, coord in pairs(util.adjacentCoords(x, y, forbid_diagonals)) do
          checkPos(node, coord[1], coord[2])
        end
      end
    end
  end
end
