def parse_entries(src)
  src.lines.map(&:strip).reject(&:empty?).map do |line|
    x, y = line.split(',', 2).map(&:to_i)
    [x, y]
  end
end

def point_in_edges?(p, poly)
  px, py = p

  poly.each_with_index.any? do |a, i|
    b = poly[(i + 1) % poly.length]

    ax, ay = a
    bx, by = b

    if ax == bx
      # vertical edge
      px == ax &&
        ((ay <= py && py <= by) ||
        (by <= py && py <= ay))
    elsif ay == by
      # horizontal edge
      py == ay &&
        ((ax <= px && px <= bx) ||
        (bx <= px && px <= ax))
    else
      false
    end
  end
end

# for simple polygons with axis-aligned edges only, assuming that vertices on the boundary are inside.
def point_in_area?(point, poly)
  return true if point_in_edges?(point, poly)
  px, py = point

  parity = (poly + [poly.first]).each_cons(2)
    .count { |a, b|
      ax, ay = a
      bx, by = b

      ax == bx && # vertical edges
      ax > px && # which cross the ray
      (ay <= py && py < by || by <= py && py < ay) # to the right of the point
    }
  
  parity % 2 == 1
end

# assuming the polygon's edges and supplied edge are axis-aligned; does not consider collinear intersections
def edge_intersects_area?(edge, poly)
  (e0x, e0y), (e1x, _) = edge
  
  if e0x == e1x
    # vertical edge, check horiz poly edges
    x = e0x
    y0, y1 = edge.map(&:last).minmax
    (poly + [poly.first]).each_cons(2).any? do |l, r|
      lx, ly = l
      rx, ry = r
      
      ly == ry && 
        (lx < x && x < rx || rx < x && x < lx) &&
        y0 < ly && ly < y1
    end
  else
    # horizontal edge, check vertical poly edges
    y = e0y
    x0, x1 = edge.map(&:first).minmax
    (poly + [poly.first]).each_cons(2).any? do |l, r|
      lx, ly = l
      rx, ry = r

      lx == rx &&
        (ly < y && y < ry || ry < y && y < ly) &&
        x0 < lx && lx < x1
    end
  end
end

def part01(data)
  data.combination(2).max_by do |l, r|
    x0, y0 = l
    x1, y1 = r
    [[l, r], ((x1 - x0).abs + 1) * ((y1 - y0).abs + 1)]
  end.(&:last)
end

def part02(data)
  data.combination(2).filter_map do |l, r|
    # a rectangle will be contained inside the area if:
    xl, yl = l
    xr, yr = r
    
    x0, x1 = [xl, xr].minmax
    y0, y1 = [yl, yr].minmax
    
    # (1) all points are inside the region
    points = [[x0, y0], [x0, y1], [x1, y1], [x1, y0]]
    next if points.any? { |p| !point_in_area?(p, data) }
    
    # (2) none of the region's edges intersect it, aside from the rectangle edges
    edges = (points + [points.first]).each_cons(2)
    next if edges.any? { |e| edge_intersects_area?(e, data) }

    [[l, r], (x1 - x0 + 1) * (y1 - y0 + 1)]
  end.max_by(&:last)
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end