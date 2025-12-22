class Vector3
  attr_accessor :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def magnitude
    (@x**2 + @y**2 + @z**2) ** 0.5
  end

  def +(rhs)
    Vector3.new(@x + rhs.x, @y + rhs.y, @z + rhs.z)
  end

  def -(rhs)
    Vector3.new(@x - rhs.x, @y - rhs.y, @z - rhs.z)
  end
end


def parse(line)
  nums = line.split(',').map(&:strip).map(&:to_i)
  Vector3.new *nums
end

def parse_entries(src)
  connections_src, *rest = src.lines.map(&:strip).reject(&:empty?)
  vertices = rest.map { |line| parse(line) }

  [vertices, connections_src.to_i]
end

def part01(data)
  # compute edge distances
  positions, connections = data
  vertices = (0...positions.length).to_a
  
  all_edges = vertices.product(vertices).select { |l, r| l < r }
  edge_distances = all_edges.map do |l, r|
    [[l, r], (positions[l] - positions[r]).magnitude]
  end
  
  # build graph
  best = edge_distances.sort_by(&:last).take(connections)
  graph = vertices.map {|| []}
  best.each { |edge, _| l, r = edge; graph[l] << r; graph[r] << l }

  # find islands using (some) search
  visited = Set.new []
  parents = {}
  vertices.each do |i|
    queue = [i]
    visited.add(i)

    while u = queue.shift
      graph[u].each do |j|
        next if visited.member?(j)

        visited.add(j)
        parents[j] = u
        queue << j
      end
    end
  end
  
  # identify islands and their sizes
  island_heads = vertices.reject { |v| parents.key? v }

  island_sizes = island_heads.to_h do |v|
    i_visited = Set.new [v]
    i_queue = [v]
    while i = i_queue.shift
      graph[i].each do |j|
        next if i_visited.member?(j)
        i_visited.add(j)
        i_queue << j
      end
    end

    [v, i_visited.length]
  end

  island_sizes.map(&:last).sort.reverse.take(3).reduce(1, &:*)
end

def part02(data)
  # compute edge distances
  positions, _ = data
  vertices = (0...positions.length).to_a
  
  all_edges = vertices.product(vertices).select { |l, r| l < r }
  edge_distances = all_edges.map do |l, r|
    [[l, r], (positions[l] - positions[r]).magnitude]
  end.sort_by(&:last)
  
  # build graph
  groups = vertices.each_with_index.to_h
  group_count = groups.length
  graph = vertices.map {|| []}

  while group_count > 1
    edge, _ = edge_distances.shift

    i, j = edge
    graph[i] << j
    graph[j] << i

    if groups[i] != groups[j]
      other_color = groups[j]
      groups.each do |v, color|
        groups[v] = groups[i] if color == other_color
      end
      group_count -= 1
    end
  end

  edge.map { |v| positions[v].x }.reduce(1, &:*)
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end