require 'kaleidoscope'
require 'chunky_png'

def fill_poly(png, edges, color)
  ys = edges.map { |e| [e[0][1], e[1][1]] }.flatten
  min_y, max_y = ys.min, ys.max

  min_y.upto(max_y-1) do |y|
    intersections = []
    edges.each do |p1, p2|
      if (p1[1] < y && p2[1] >= y) || (p2[1] < y && p1[1] >= y)
        intersections << (p1[0] + (y - p1[1]).to_f / (p2[1] - p1[1]) * (p2[0] - p1[0])).to_i
      end
    end

    intersections.sort!
    0.step(intersections.length-1, 2) do |i|
      intersections[i].upto(intersections[i+1]) do |x|
        png.set_pixel(x, y, color)
      end
    end
  end
end

# controls the size of the canvas
size = 600

# controls how many cells are fit onto the canvas
radius = 12

offset = size / 2
scale = offset / radius

png = ChunkyPNG::Image.new(size, size, ChunkyPNG::Color::WHITE)
black = ChunkyPNG::Color.rgb(0, 0, 0)
colors = [
  ChunkyPNG::Color.rgb(0xa4, 0x61, 0xe1),
  ChunkyPNG::Color.rgb(0xbf, 0xb6, 0xd5),
  ChunkyPNG::Color.rgb(0x64, 0x51, 0xc3),
]

pattern = Kaleidoscope::Pattern.new(6, 3, 0.35, 0.65)

puts "generating"
radius_squared = radius * radius
pattern.generate! { |pt| pt.x * pt.x + pt.y * pt.y < radius_squared }

puts "drawing"

fix = proc { |pt| [offset + (pt.x * scale).to_i, offset + (pt.y * scale).to_i] }

pattern.polygons.each do |poly|
  next unless poly.inside?
  edges = poly.edges.map { |e| [fix[e.p1], fix[e.p2]] }
  fill_poly(png, edges, colors[poly.color])
end

pattern.edges.each do |edge|
  next unless edge.inside?

  x1, y1 = fix[edge.p1]
  x2, y2 = fix[edge.p2]

  png.line x1, y1, x2, y2, black
end

puts "saving to `pattern.png'"
png.save "pattern.png"
