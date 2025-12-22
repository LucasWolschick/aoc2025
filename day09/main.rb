def parse_entries(src)
  src.lines.map(&:strip).reject(&:empty?).map do |line|
    x, y = line.split(',', 2).map(&:to_i)
    [x, y]
  end
end

def point_in_edges?(p, poly)
  poly.each_with_index.any? do |a, i|
    b = poly[(i + 1) % poly.length]

    if a[0] == b[0]
      # vertical edge
      p[0] == a[0] &&
        ((a[1] <= p[1] && p[1] <= b[1]) ||
        (b[1] <= p[1] && p[1] <= a[1]))
    elsif a[1] == b[1]
      # horizontal edge
      p[1] == a[1] &&
        ((a[0] <= p[0] && p[0] <= b[0]) ||
        (b[0] <= p[0] && p[0] <= a[0]))
    else
      false
    end
  end
end

# for simple polygons with axis-aligned edges only, assuming that vertices on the boundary are inside.
def point_in_area?(point, poly)
  return true if point_in_edges?(point, poly)

  parity = (poly + [poly.first]).each_cons(2)
    .count { |a, b| 
      a[0] == b[0] && # vertical edges
      a[0] > point[0] && # which cross the ray
      (a[1] <= point[1] && point[1] < b[1] || b[1] <= point[1] && point[1] < a[1]) # to the right of the point
    }
  
  parity % 2 == 1
end

# assuming the polygon's edges and supplied edge are axis-aligned; does not consider collinear intersections
def edge_intersects_area?(edge, poly)
  e1, e2 = edge
  
  e0x, e0y = e1
  e1x, _ = e2

  if e0x == e1x
    # vertical edge, check horiz poly edges
    x = e0x
    y0, y1 = edge.map(&:last).minmax
    (poly + [poly.first]).each_cons(2).any? do |l, r|
      l[1] == r[1] && 
        (l[0] < x && x < r[0] || r[0] < x && x < l[0]) &&
        y0 < l[1] && l[1] < y1
    end
  else
    # horizontal edge, check vertical poly edges
    y = e0y
    x0, x1 = edge.map(&:first).minmax
    (poly + [poly.first]).each_cons(2).any? do |l, r|
      l[0] == r[0] &&
        (l[1] < y && y < r[1] || r[1] < y && y < l[1]) &&
        x0 < l[0] && l[0] < x1
    end
  end
end

def part01(data)
  data.combination(2).map do |l, r|
    x0, y0 = l
    x1, y1 = r
    [[l, r], ((x1 - x0).abs + 1) * ((y1 - y0).abs + 1)]
  end.max_by(&:last)
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