# let's do it with matrices >:)
require "matrix"

def parse_entries(src)
  source_src, *splits_srcs = src.lines
  source = source_src.index("S")
  splits = splits_srcs.map do |split_src|
    split_src.each_char.with_index.filter_map { |c, i| i if c == "^" }
  end.reject(&:empty?)
  [source, splits]
end

def build_splits_matrix(splits, n)
  mat = Matrix.I(n)

  # NB: offsets below will always be inside bounds for the inputs
  # we're solving.
  splits.each do |split|
    mat[split, split] -= 1
    mat[split - 1, split] += 1
    mat[split + 1, split] += 1
  end

  mat
end

def premultiply_splits(n, splits_list)
  splits_list.reduce(Matrix.I(n)) do |acc, split_list|
     build_splits_matrix(split_list, n) * acc
  end
end

def compute_beams(start_pos, splits_list)
  n = splits_list.flatten.max + 2
  mat = premultiply_splits(n, splits_list)
  vec = Matrix.column_vector( 
    Array.new(n) { |row, _| row == start_pos ? 1 : 0 }
  )
  mat * vec
end

def count_splits_merging(start_pos, splits_list)
  n = splits_list.flatten.max + 2
  vec = Matrix.build(n, 1) { |row, _| row == start_pos ? 1 : 0 }

  splits = 0
  splits_list.each do |split_list|
    before_count = vec.sum
    vec = build_splits_matrix(split_list, n) * vec
    after_count = vec.sum
    splits += after_count - before_count
    vec = vec.map { |e| e > 1 ? 1 : e }
  end

  splits
end

def part01(data)
  source, splits = data
  count_splits_merging(source, splits)
end

def part02(data)
  source, splits = data
  compute_beams(source, splits).sum
end

if __FILE__ == $0
  src = File.read ARGV[0]
  input = parse_entries(src)
  puts "P1: #{part01 input}"
  puts "P2: #{part02 input}"
end