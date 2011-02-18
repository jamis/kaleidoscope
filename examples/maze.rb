require 'kaleidoscope'
require 'chunky_png'

# controls the size of the canvas
size = 600

# controls how many cells are fit onto the canvas
radius = 12

# determines which maze is drawn. redundant, by default,
# but done so you can see which seed drew the maze, and
# also to allow you to set the seed yourself.

seed = rand(0xFFFFFFFF)
srand(seed)

offset = size / 2
scale = offset / radius

png = ChunkyPNG::Image.new(size, size, ChunkyPNG::Color::WHITE)
black = ChunkyPNG::Color.rgb(0,0,0)
red = ChunkyPNG::Color.rgb(255,0,0)
gray = ChunkyPNG::Color.rgb(200,200,200)

puts "generating lattice (this will take a while...)"
radius_squared = radius * radius

#pattern = Kaleidoscope::Pattern.new(6, 3, 0.35, 0.65)
pattern = Kaleidoscope::Pattern.new(6, 3)

pattern.generate! { |pt| pt.x * pt.x + pt.y * pt.y < radius_squared }

puts "building maze"
list = [pattern.polygons.detect { |poly| poly.inside? }]
graph = Hash.new { |h,k| h[k] = [] }
visited, removed = {}, {}

min_y, max_y = 200, -200
min_poly = max_poly = nil
min_edge = max_edge = nil

while list.any?
  index = rand(2) == 0 ? rand(list.length) : list.length-1

  poly = list[index]

  # look for min/max y values on the outer boundaries, so we can
  # open entrance/exit points.
  if poly.inside?
    poly.edges.each do |e|
      next if poly.neighbor_via(e).inside?

      if e.p1.y < min_y || e.p2.y < min_y
        min_y = [e.p1.y, e.p2.y].min
        min_poly, min_edge = poly, e
      end

      if e.p1.y > max_y || e.p2.y > max_y
        max_y = [e.p1.y, e.p2.y].max
        max_poly, max_edge = poly, e
      end
    end
  end

  visited[poly] = true
  carved = false

  poly.edges.shuffle.each do |edge|
    next if removed[edge]
    neighbor = poly.neighbor_via(edge)
    next if visited[neighbor] || !neighbor.inside?

    visited[neighbor] = true
    removed[edge] = true

    graph[poly] << neighbor
    graph[neighbor] << poly

    list << neighbor
    carved = true
    break
  end

  list.delete_at(index) unless carved
end

removed[min_edge] = true
removed[max_edge] = true

puts "computing solution"
solution = [[min_poly, graph[min_poly].dup]]

loop do
  current, neighbors = solution.last
  break if current == max_poly

  if neighbors.any?
    neighbor = neighbors.pop
    solution.push [neighbor, graph[neighbor].dup - [current]]
  else
    solution.pop
    abort "no solution!" if solution.empty?
  end
end

puts "drawing maze"

fix = proc { |pt| [offset + (pt.x * scale).to_i, offset + (pt.y * scale).to_i] }

drawn = {}
pattern.polygons.each do |poly|
  next unless poly.inside?

  poly.edges.each do |edge|
    next if drawn[edge] || removed[edge]
    drawn[edge] = true

    x1, y1 = fix[edge.p1]
    x2, y2 = fix[edge.p2]

    png.line x1, y1, x2, y2, black
  end
end

puts "drawing solution"

current = solution.first[0]
x1, y1 = fix[current.center]

solution[1..-1].each do |poly, list|
  x2, y2 = fix[poly.center]
  png.line x1, y1, x2, y2, red
  x1, y1 = x2, y2
end

puts "drawing endpoints"
x1, y1 = fix[min_poly.center]
png.rect x1-2, y1-2, x1+2, y1+2, red
x1, y1 = fix[max_poly.center]
png.rect x1-2, y1-2, x1+2, y1+2, red

puts "saving to `maze.png'"
png.save "maze.png"

puts "done (seed %d)" % seed
