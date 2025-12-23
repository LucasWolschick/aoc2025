class PieceData
  attr_reader :data, :w, :h

  def initialize(data)
    @data = data.freeze
    @w = data[0].length
    @h = data.length
    freeze
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

  def overlaps?(rhs)
    (0...@data.h).each do |y|
      (0...@data.w).each do |x|
        return true if self[@x + x, @y + y] && rhs[@x + x, @y + y]
      end
    end
    return false
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

def parse_piece(piece_src)
  PieceData.new(piece_src.lines[1..].map(&:strip).reject(&:empty?).map { |line| line.chars.map { |char| char == '#'} })
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
  pieces = pieces.map { |piece| parse_piece(piece) }
  puzzles = puzzles.lines.filter_map { |puzzle| parse_puzzle(puzzle.strip) if !puzzle.strip.empty? }
  [pieces, puzzles]
end

def try_solve(pieces, fixed_pieces, puzzle)
  return true if pieces.empty?

  # assuming all pieces are 3x3
  xs = (0...(puzzle.width - 2)).to_a
  ys = (0...(puzzle.height - 2)).to_a
  rots = [0, 1, 2, 3]
  flips = [0, 1]

  p, *rest = pieces
  xs.product(ys, rots, flips).any? do |x, y, rot, flip|
    piece = p.clone
    piece.x = x
    piece.y = y
    piece.rot = rot
    piece.hflip = flip

    next if fixed_pieces.any? { |fixed| fixed.overlaps?(piece) }
    
    try_solve(rest, fixed_pieces + [piece], puzzle)
  end
end

def solve_puzzle(piece_types, puzzle)
  # state space for a piece is (w - 2) * (h - 2) * 8
  pieces = []

  puzzle.requirements.each_with_index do |count, piece_i|
    pieces += Array.new(count) { Piece.new(piece_types[piece_i]) }
  end

  try_solve(pieces, [], puzzle)
end

def part01(data)
  pieces, puzzles = data
  puzzles.select { |puzzle| p solve_puzzle(pieces, puzzle) }.count
end

def part02(data)
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end