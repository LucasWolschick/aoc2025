# todo: there's probably a better graph-theoretical way of doing this
# this also seems solvable with matrices

class Maze
  attr_reader :width, :height

  def initialize(src)
    src = src.strip
    lines = src.lines.map(&:strip)

    @width = lines[0].length
    @height = lines.length
    @data = lines.map { |line| line.chars.map { |c| c == '@' } }
  end

  def occupied?(x, y)
    bounded?(x, y) && @data[y][x]
  end

  def bounded?(x, y)
    0 <= x && x < @width && 0 <= y && y < @height
  end

  def set!(x, y)
    @data[y][x] = true if bounded?(x, y)
  end

  def unset!(x, y)
    @data[y][x] = false if bounded?(x, y)
  end

  def all_cells
    (0...@width).to_a.product((0...@height).to_a).map { |x, y| MazeCell.new(self, x, y) }
  end

  def neighbors(x, y)
    [
      [x - 1, y - 1], [x, y - 1], [x + 1, y - 1],
      [x - 1, y], [x + 1, y],
      [x - 1, y + 1], [x, y + 1], [x + 1, y + 1],
    ].map { |i, j| MazeCell.new(self, i, j) }
  end
end

class MazeCell
  attr_reader :maze, :x, :y

  def initialize(maze, x, y)
    @x = x
    @y = y
    @maze = maze
  end

  def occupied?
    @maze.occupied?(@x, @y)
  end

  def bounded?
    @maze.bounded?(@x, @y)
  end

  def neighbors
    @maze.neighbors(@x, @y)
  end

  def set!
    @maze.set!(@x, @y)
  end

  def unset!
    @maze.unset!(@x, @y)
  end
end

def find_removable_rolls(maze)
  maze.all_cells.select { |cell| cell.occupied? && cell.neighbors.count(&:occupied?) < 4 }
end

def parse_entries(src)
  Maze.new(src)
end

def part01(data)
  find_removable_rolls(data).count
end

def part02(data)
  removed = 0
  rolls = find_removable_rolls(data)
  until rolls.empty?
    rolls.each(&:unset!)
    removed += rolls.length
    rolls = find_removable_rolls(data)
  end
  removed
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end