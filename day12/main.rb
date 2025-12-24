class PieceData
  attr_reader :id, :data, :w, :h

  def initialize(id, data)
    @id = id
    @data = data.freeze
    @w = data[0].length
    @h = data.length
    @area = data.sum { |row| row.sum { |column| column ? 1 : 0 }}
    freeze
  end

  def area
    @area
  end
end

# rot is cw
class Piece
  attr_reader :data, :rot
  attr_accessor :x, :y, :hflip

  def initialize(data)
    @data = data
    @x = 0
    @y = 0
    @rot = 0
    @hflip = false
  end

  def rot=(value)
    @rot = value % 4
  end

  def to_local(x, y)
    tx, ty = x - @x, y - @y

    case [@hflip, @rot]
    when [0, 0] then [tx, ty]
    when [0, 1] then [ty, @data.h-1-tx]
    when [0, 2] then [@data.w-1-tx, @data.h-1-ty]
    when [0, 3] then [@data.h-1-ty, tx]

    when [1, 0] then [@data.w-1-tx, ty]
    when [1, 1] then [ty, tx]
    when [1, 2] then [tx, @data.h-1-ty]
    when [1, 3] then [@data.w-1-ty, @data.h-1-tx]
    end
  end

  def [](x, y)
    tx, ty = to_local(x, y)
    0 <= tx && tx < @data.w && 0 <= ty && ty < @data.h && @data.data[ty][tx]
  end

  def to_s(char = "#")
    (0...@data.h).map do |y|
      (0...@data.w).map do |x|
        self[@x + x, @y + y] ? char : "."
      end.join
    end.join("\n")
  end
end

class PuzzleData
  attr_reader :width, :height, :requirements

  def initialize(width, height, requirements)
    @width = width
    @height = height
    @requirements = requirements.freeze
    freeze
  end
end

def parse_piece(id, piece_src)
  PieceData.new(id, piece_src.lines[1..].map(&:strip).reject(&:empty?).map { |line| line.chars.map { |char| char == '#'} })
end

def parse_puzzle(puzzle_src)
  dims, reqs = puzzle_src.split(": ", 2)
  w, h = dims.split("x", 2).map(&:to_i)
  reqs = reqs.split.map(&:to_i)
  PuzzleData.new(w, h, reqs)
end

def parse_entries(src)
  chunks = src.strip.split("\n\n")
  *pieces, puzzles = chunks
  pieces = pieces.each_with_index.map { |piece, id| parse_piece(id, piece) }
  puzzles = puzzles.lines.filter_map { |puzzle| parse_puzzle(puzzle.strip) if !puzzle.strip.empty? }
  [pieces, puzzles]
end

def as_bitmask(piece, w, h)
  num = 0
  0.upto(piece.data.w - 1).each do |x|
    0.upto(piece.data.h - 1).each do |y|
      tx = piece.x + x
      ty = piece.y + y
      i = ty*w + tx
      num |= (1 << i) if piece[tx, ty]
    end
  end
  num
end

def precompute_placement_masks(pieces, max_w, max_h)
  xs = (0...(max_w - 2)).to_a
  ys = (0...(max_h - 2)).to_a
  rots = [0, 1, 2, 3]
  flips = [0, 1]

  memo = Hash.new { |h, k| h[k] = Set.new }

  pieces.each do |piece_type|
    xs.product(ys, rots, flips).each do |x, y, rot, flip|
      piece = Piece.new(piece_type)
      piece.x = x
      piece.y = y
      piece.rot = rot
      piece.hflip = flip
  
      memo[piece_type] << as_bitmask(piece, max_w, max_h)
    end
  end
  memo
end

def try_solve(board, requirements, piece_placements)
  return true if requirements.empty?
  new_placements = {}
  req, req_i = requirements.each_with_index.min_by do |r, _|
    new_placements[r] = piece_placements[r].select { |m| (board & m) == 0 }
    new_placements[r].length
  end
  rest = requirements[...req_i] + requirements[req_i+1...]
  valid = new_placements[req].select { |m| (board & m) == 0 }
  return false if valid.empty?
  valid.any? do |placement|
    next if (board & placement) != 0
    try_solve_memo(board | placement, rest, new_placements)
  end
end

def try_solve_memo(board, requirements, piece_placements)
  @cache ||= {}
  key = [board, requirements.map(&:id).tally.sort].flatten
  return @cache[key] if @cache.key? (key)
  @cache[key] = try_solve(board, requirements, piece_placements)
end

def solve_puzzle(piece_types, piece_placements, puzzle)
  requirements = []

  puzzle.requirements.each_with_index do |count, piece_i|
    requirements += Array.new(count) { piece_types[piece_i] }
  end

  try_solve_memo(0, requirements, piece_placements.clone)
end

def part01(data)
  piece_types, puzzles = data

  max_w = puzzles.map(&:width).max
  max_h = puzzles.map(&:height).max

  puts "precomputing masks"
  piece_placements = precompute_placement_masks(piece_types, max_w, max_h)
  puts "total length: #{piece_placements.values.flatten.map(&:length).sum}"

  puzzles.select do |puzzle| 
    # prune based on area
    required_area = puzzle.requirements.zip(piece_types).sum { |r, t| r * t.area }
    available_area = puzzle.width * puzzle.height
    required_area <= available_area
  end.select do |puzzle|
    p solve_puzzle(piece_types, piece_placements, puzzle)
  end.count
end

def part02(data)
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end