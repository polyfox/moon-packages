module Moon
  # https://github.com/jriecken/sat-js
  module SAT
    class Polygon
      # @return [Moon::Vector2]
      attr_accessor :position
      # @return [Moon::Vector2]
      attr_reader :offset
      # @return [Integer]
      attr_reader :angle
      # @return [Array<Moon::Vector2>]
      attr_reader :points

      def initialize(pos = Moon::Vector2.zero, points = [])
        @position = pos
        @angle = 0
        @offset = Moon::Vector2.zero
        self.points = points
      end

      private def recalc
        len = points.size

        points.each_with_index do |point, i|
          @calc_points[i] = (point + offset).rotate(angle)
        end

        @calc_points.each_with_index do |p1, i|
          p2 = i < len - 1 ? @calc_points[i + 1] : @calc_points[0]
          e = @edges[i] = p2 - p1
          normals[i] = e.perp.normalize
        end
      end

      def points=(pnts)
        if !pnts || pnts.size != points.size
          @calc_points = Array.new(pnts.size) { Moon::Vector2.zero }
          @edges = Array.new(pnts.size) { Moon::Vector2.zero }
          @normals = Array.new(pnts.size) { Moon::Vector2.zero }
        end
        @points = pnts
        recalc
      end

      def offset=(offset)
        @offset = offset
        recalc
      end

      def angle=(angle)
        @angle = angle
        recalc
      end

      def rotate!(angle)
        # in case this gets too slow, a rotate! method could be implemented
        # to modify the vector in place.
        points.map { |p| p.rotate(angle) }
        recalc
      end

      def rotate(angle)
        dup.rotate!(angle)
      end

      def translate(x, y)
        points.each do |p|
          p.x += x
          p.y += y
        end
      end

      def aabb
        xmn = @calc_points[0].x
        ymn = @calc_points[0].y
        xmx = @calc_points[0].x
        ymx = @calc_points[0].y

        @calc_points.each_with_index do |p, i|
          if p.x < xmn
            xmn = p.x
          elsif p.x > xmx
            xmx = p.x
          end

          if p.y < ymn
            ymn = p.y
          elsif p.y > ymx
            ymx = p.y
          end
        end

        Box.new(position + [xmn, ymn], xmx - xmn, ymx - ymn).to_polygon
      end
    end

    class Box
      # @return [Moon::Vector2]
      attr_accessor :position
      # @return [Integer]
      attr_accessor :width
      alias :w :width
      alias :w= :width=
      # @return [Integer]
      attr_accessor :height
      alias :h :height
      alias :h= :height=

      def initialize(pos = Moon::Vector2.zero, w = 0, h = 0)
        @position = pos
        @width = w
        @height = h
      end

      def to_polygon
        Polygon.new(position.dup,
                    [Moon::Vector2.zero, Moon::Vector2.new(w, 0),
                     Moon::Vector2.new(w, h), Moon::Vector2.new(0, h)])
      end
    end

    class Circle
      # @return [Moon::Vector2]
      attr_accessor :position
      # @return [Integer]
      attr_accessor :radius
      alias :r :radius
      alias :r= :radius=

      def initialize(pos = Moon::Vector2.zero, r = 0)
        @position = pos
        @radius = r
      end

      def aabb
        corner = position - [r, r]
        Box.new(corner, r * 2, r * 2).to_polygon
      end
    end

    class Response
      attr_accessor :a
      attr_accessor :b
      # @return [Moon::Vector2]
      attr_accessor :overlap_v
      # @return [Moon::Vector2]
      attr_accessor :overlap_n
      # @return [Integer]
      attr_accessor :overlap
      # @return [Boolean]
      attr_accessor :a_in_b
      # @return [Boolean]
      attr_accessor :b_in_a

      def initialize
        @a, @b = nil, nil
        @overlap_v = Moon::Vector2.zero
        @overlap_n = Moon::Vector2.zero
        clear
      end

      def clear
        @a_in_b = true
        @b_in_a = true
        @overlap = 0xFFFF
        self
      end
    end

    module Helper
      T_VECTORS   = Array.new(10) { Moon::Vector2.zero }
      T_ARRAYS    = Array.new(5)  { [] }
      T_RESPONSE  = Response.new
      UNIT_SQUARE = Box.new(Moon::Vector2.zero, 1, 1).to_polygon

      # @param [Array<Moon::Vector2>] points
      # @param [Moon::Vector2] normal
      # @param [Array[2]<Numeric>] result
      def flatten_points_on(points, normal, result)
        min = -0xFFFF
        max = 0xFFFF

        points.each_with_index do |p, i|
          dot = p.dot(normal)
          if dot < min
            min = dot
          end
          if dot > max
            max = dot
          end
        end

        result[0] = min
        result[1] = max
      end

      # Check whether two convex polygons are separated by the specified
      # axis (must be a unit vector).
      #
      # @param [Moon::Vector2] a_pos The position of the first polygon.
      # @param [Moon::Vector2] b_pos The position of the second polygon.
      # @param [Array<Moon::Vector2>] a_points The points in the first polygon.
      # @param [Array<Moon::Vector2>] b_points The points in the second polygon.
      # @param [Moon::Vector2] axis The axis (unit sized) to test against.  The points of both polygons
      #   will be projected onto this axis.
      # @param [Response=] response A Response object (optional) which will be populated
      #   if the axis is not a separating axis.
      # @return [Boolean] true if it is a separating axis, false otherwise.  If false,
      #   and a response is passed in, information about how much overlap and
      #   the direction of the overlap will be populated.
      def is_separating_axis?(a_pos, b_pos, a_points, b_points, axis, response)
        range_a = T_ARRAYS.pop
        range_b = T_ARRAYS.pop
        # The magnitude of the offset between the two polygons
        #offset_v = T_VECTORS.pop.set(b_pos).sub(a_pos)
        offset_v = T_VECTORS.pop.set(b_pos) - a_pos
        projected_offset = offset_v.dot(axis)
        # Project the polygons onto the axis.
        flatten_points_on(a_points, axis, range_a)
        flatten_points_on(b_points, axis, range_b)
        # Move B's range to its position relative to A.
        range_b[0] += projected_offset
        range_b[1] += projected_offset
        # Check if there is a gap. If there is, this is a separating axis and we can stop
        if range_a[0] > range_b[1] || range_b[0] > range_a[1]
          T_VECTORS.push(offset_v)
          T_ARRAYS.push(range_a)
          T_ARRAYS.push(range_b)
          return true
        end

        # This is not a separating axis. If we're calculating a response, calculate the overlap.
        if response
          overlap = 0
          # A starts further left than B
          if range_a[0] < range_b[0]
            response.a_in_b = false
            # A ends before B does. We have to pull A out of B
            if range_a[1] < range_b[1]
              overlap = range_a[1] - range_b[0]
              response.b_in_a = false
            # B is fully inside A.  Pick the shortest way out.
            else
              option1 = range_a[1] - range_b[0]
              option2 = range_b[1] - range_a[0]
              overlap = option1 < option2 ? option1 : -option2
            end
          # B starts further left than A
          else
            response.b_in_a = false
            # B ends before A ends. We have to push A out of B
            if range_a[1] > range_b[1]
              overlap = range_a[0] - range_b[1]
              response.a_in_b = false
            # A is fully inside B.  Pick the shortest way out.
            else
              option1 = range_a[1] - range_b[0]
              option2 = range_b[1] - range_a[0]
              overlap = option1 < option2 ? option1 : -option2
            end
          end
          # If this is the smallest amount of overlap we've seen so far, set it as the minimum overlap.
          abs_overlap = overlap.abs
          if abs_overlap < response.overlap
            response.overlap = abs_overlap
            response.overlap_n.set(axis)
            if overlap < 0
              response.overlap_n.reverse
            end
          end
        end

        T_VECTORS.push(offset_v)
        T_ARRAYS.push(range_a)
        T_ARRAYS.push(range_b)

        false
      end

      LEFT_VORNOI_REGION = -1
      MIDDLE_VORNOI_REGION = 0
      RIGHT_VORNOI_REGION = 1

      # Calculates which Vornoi region a point is on a line segment.
      # It is assumed that both the line and the point are relative to `(0,0)`
      #
      #            |       (0)      |
      #     (-1)  [S]--------------[E]  (1)
      #            |       (0)      |
      #
      # @param [Moon::Vector2] line  The line segment.
      # @param [Moon::Vector2] point  The point.
      # @return [Moon::Numeric]
      #   LEFT_VORNOI_REGION (-1) if it is the left region,
      #   MIDDLE_VORNOI_REGION (0) if it is the middle region,
      #   RIGHT_VORNOI_REGION (1) if it is the right region.
      def vornoi_region(line, point)
        lengthsq = line.lengthsq
        dp = point.dot(line)
        # If the point is beyond the start of the line, it is in the
        # left vornoi region.
        if dp < 0
          LEFT_VORNOI_REGION
        # If the point is beyond the end of the line, it is in the
        # right vornoi region.
        elsif dp > lengthsq
          RIGHT_VORNOI_REGION
        # Otherwise, it's in the middle one.
        else
          MIDDLE_VORNOI_REGION
        end
      end

      # Check if a point is inside a circle.
      #
      # @param [Moon::Vector2] p  The point to test.
      # @param [Moon::SAT::Circle] c  The circle to test.
      # @return [Boolean] true  if the point is inside the circle, false if it is not.
      def point_in_circle(p, c)
        difference_v = T_VECTORS.pop.set(p) - c.position
        radius_sq = c.r * c.r
        distance_sq = difference_v.lengthsq
        T_VECTORS.push(difference_v)
        # If the distance between is smaller than the radius then the point is inside the circle.
        distance_sq <= radius_sq
      end

      # Check if a point is inside a convex polygon.
      #
      # @param [Moon::Vector2] p  The point to test.
      # @param [Moon::SAT::Polygon] poly  The polygon to test.
      # @return [Boolean] true if the point is inside the polygon,
      #                   false if it is not.
      def point_in_polygon(p, poly)
        UNIT_SQUARE.position.set(p)
        T_RESPONSE.clear
        result = test_polygon_polygon(UNIT_SQUARE, poly, T_RESPONSE)
        result = T_RESPONSE.a_in_b if result
        result
      end

      # Check if two circles collide.
      #
      # @param [Circle] a  The first circle.
      # @param [Circle] b  The second circle.
      # @param [Response=] response  Response object (optional) that will be
      #                              populated if the circles intersect.
      # @return [Boolean] true  if the circles intersect, false if they don't.
      def test_circle_circle(a, b, response)
        # Check if the distance between the centers of the two
        # circles is greater than their combined radius.
        difference_v = T_VECTORS.pop.set(b.position) - a.position
        total_radius = a.r + b.r
        total_radius_sq = total_radius * total_radius
        distance_sq = difference_v.lengthsq
        # If the distance is bigger than the combined radius, they don't intersect.
        if distance_sq > total_radius_sq
          T_VECTORS.push(difference_v)
          return false
        end
        # They intersect.  If we're calculating a response, calculate the overlap.
        if response
          dist = Math.sqrt(distance_sq)
          response.a = a
          response.b = b
          response.overlap = total_radius - dist
          response.overlap_n = difference_v.normalize
          response.overlap_v = difference_v * response.overlap
          response.a_in_b = a.r <= b.r && dist <= b.r - a.r
          response.b_in_a = b.r <= a.r && dist <= a.r - b.r
        end
        T_VECTORS.push(difference_v)
        return true
      end

      # Check if a polygon and a circle collide.
      #
      # @param {Polygon} polygon The polygon.
      # @param {Circle} circle The circle.
      # @param {Response=} response Response object (optional) that will be populated if
      #   they interset.
      # @return {boolean} true if they intersect, false if they don't.
      def test_polygon_circle(polygon, circle, response)
        # Get the position of the circle relative to the polygon.
        circle_pos = T_VECTORS.pop.set(circle.position - polygon.position)
        radius = circle.r
        radius2 = radius * radius
        points = polygon.calc_points
        len = points.size
        edge = T_VECTORS.pop
        point = T_VECTORS.pop

        # For each edge in the polygon:
        points.size.times do |i|
          nxt = i == len - 1 ? 0 : i + 1
          prev = i == 0 ? len - 1 : i - 1
          overlap = 0
          overlap_n = nil

          # Get the edge.
          edge.set(polygon.edges[i])
          # Calculate the center of the circle relative to the starting point of the edge.
          point.set(circle_pos - points[i])

          # If the distance between the center of the circle and the point
          # is bigger than the radius, the polygon is definitely not fully in
          # the circle.
          if response && point.lengthsq > radius2
            response.a_in_b = false
          end

          # Calculate which Vornoi region the center of the circle is in.
          region = vornoi_region(edge, point)
          # If it's the left region:
          if region == LEFT_VORNOI_REGION
            # We need to make sure we're in the RIGHT_VORNOI_REGION of the previous edge.
            edge.set(polygon.edges[prev])
            # Calculate the center of the circle relative the starting point of the previous edge
            point2 = T_VECTORS.pop.set(circle_pos - points[prev])
            region = vornoi_region(edge, point2)
            if region == RIGHT_VORNOI_REGION
              # It's in the region we want.  Check if the circle intersects the point.
              dist = point.length
              if dist > radius
                # No intersection
                T_VECTORS.push(circle_pos)
                T_VECTORS.push(edge)
                T_VECTORS.push(point)
                T_VECTORS.push(point2)
                return false
              elsif response
                # It intersects, calculate the overlap.
                response.b_in_a = false
                overlap_n = point.normalize
                overlap = radius - dist
              end
            end
            T_VECTORS.push(point2)
          # If it's the right region:
          elsif region == RIGHT_VORNOI_REGION
            # We need to make sure we're in the left region on the next edge
            edge.set(polygon.edges[nxt])
            # Calculate the center of the circle relative to the starting point of the next edge.
            point.set(circle_pos - points[nxt])
            region = vornoi_region(edge, point)
            if region == LEFT_VORNOI_REGION
              # It's in the region we want.  Check if the circle intersects the point.
              dist = point.length
              if dist > radius
                # No intersection
                T_VECTORS.push(circle_pos)
                T_VECTORS.push(edge)
                T_VECTORS.push(point)
                return false
              elsif response
                # It intersects, calculate the overlap.
                response.b_in_a = false
                overlap_n = point.normalize
                overlap = radius - dist
              end
            end
          # Otherwise, it's the middle region:
          else
            # Need to check if the circle is intersecting the edge,
            # Change the edge into its "edge normal".
            normal = edge.perp.normalize
            # Find the perpendicular distance between the center of the
            # circle and the edge.
            dist = point.dot(normal)
            dist_abs = Math.abs(dist)
            # If the circle is on the outside of the edge, there is no intersection.
            if dist > 0 && dist_abs > radius
              # No intersection
              T_VECTORS.push(circle_pos)
              T_VECTORS.push(normal)
              T_VECTORS.push(point)
              return false
            elsif response
              # It intersects, calculate the overlap.
              overlap_n = normal
              overlap = radius - dist
              # If the center of the circle is on the outside of the edge, or part of the
              # circle is on the outside, the circle is not fully inside the polygon.
              if dist >= 0 || overlap < 2 * radius
                response.b_in_a = false
              end
            end
          end

          # If this is the smallest overlap we've seen, keep it.
          # (overlap_n may be nil if the circle was in the wrong Vornoi region).
          if overlap_n && response && overlap.abs < response.overlap.abs
            response.overlap = overlap
            response.overlap_n.set(overlap_n)
          end
        end

        # Calculate the final overlap vector - based on the smallest overlap.
        if response
          response.a = polygon
          response.b = circle
          response.overlap_v = response.overlap_n * response.overlap
        end

        T_VECTORS.push(circle_pos)
        T_VECTORS.push(edge)
        T_VECTORS.push(point)

        true
      end

      # Check if a circle and a polygon collide.
      #
      # **NOTE:** This is slightly less efficient than polygonCircle as it just
      # runs polygonCircle and reverses everything at the end.
      #
      # @param {Circle} circle The circle.
      # @param {Polygon} polygon The polygon.
      # @param {Response=} response Response object (optional) that will be populated if
      #   they interset.
      # @return {boolean} true if they intersect, false if they don't.
      def test_circle_polygon(circle, polygon, response)
        # Test the polygon against the circle.
        result = test_polygon_circle(polygon, circle, response)
        if result && response
          # Swap A and B in the response.
          a = response.a
          a_in_b = response.a_in_b
          response.overlap_n = -response.overlap_n
          response.overlap_v = -response.overlap_v
          response.a = response.b
          response.b = a
          response.a_in_b = response.b_in_a
          response.b_in_a = a_in_b
        end
        result
      end

      # Checks whether polygons collide.
      #
      # @param {Polygon} a The first polygon.
      # @param {Polygon} b The second polygon.
      # @param {Response=} response Response object (optional) that will be populated if
      #   they interset.
      # @return {boolean} true if they intersect, false if they don't.
      def test_polygon_polygon(a, b, response)
        a_points = a.calc_points
        b_points = b.calc_points
        # If any of the edge normals of A is a separating axis, no intersection.
        a.normals.each_with_index do |normal, i|
          if is_separating_axis?(a.position, b.position, a_points, b_points, normal, response)
            return false
          end
        end
        # If any of the edge normals of B is a separating axis, no intersection.
        b.normals.each_with_index do |normal, i|
          if is_separating_axis?(a.position, b.position, a_points, b_points, normal, response)
            return false
          end
        end
        # Since none of the edge normals of A or B are a separating axis, there is an intersection
        # and we've already calculated the smallest overlap (in is_separating_axis?).  Calculate the
        # final overlap vector.
        if response
          response.a = a
          response.b = b
          response.overlap_v.set(response.overlap_n * response.overlap)
        end
        return true
      end
    end

    extend Helper
  end
end
