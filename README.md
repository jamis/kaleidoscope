Kaleidoscope
============

Kaleidoscope is a library for generating [uniform tilings][1] of a plane
using [Wythoff's construction][2] (sometimes called
"Wythoff's kaleidoscopic construction", hence the name of the library).


Overview
--------

The central idea behind Wythoff's construction is the use of right triangles,
which are then tiled to fill the desired area on a plane. If you place a point
(called the "generator point") at the same location within each of the
triangles, and then connect the points between adjacent triangles, you get a
uniform tiling.

Note that there are many tilings that are non-Wythoffian, which means they
cannot be generated using this method, and thus are not supported by
Kaleidoscope.

Kaleidoscope does not, by itself, provide any methods for displaying these
patterns; it merely generates the data structures and hands them to you. It is
up to you to then render the patterns in a format of your choosing (PNG, or
SVG, or whatever you have ready to hand).


Understanding Wythoff's construction
------------------------------------

### Triangles

The triangles are specified by their corners, so that if one corner has an
angle of pi/4, that corner would be given the value of 4. The right angle
itself (pi/2) would be 2. Because the right angle is always present, it's
presence is always implied, and you only need to specify the other two
corners.

There are really only three types of triangles that will uniformly tile a
plane:

* (4,4,2)
* (6,3,2)
* (3,6,2)

While Kaleidoscope lets you provide any triangle specification you like,
the three above will give the best results.

### Generator points

Within the tiling triangle, the "generator point" may be located anywhere.
If you don't specify it, Kaleidoscope will set it to be the incenter of
the triangle, which gives a nice pattern, but you may set it yourself
using two barycentric coordinates, u and v. When u and v sum to 1, they
identify a location on the hypotenuse. When either u or v is 0, they
identify a location on one of the other legs of the triangle. When u and
v sum to less than 1, they identify a point inside the triangle.


Usage
-----

Generating a pattern is as simple as this:

    require 'kaleidoscope'

    pattern = Kaleidoscope::Pattern.new(6, 3)
    pattern.generate! do |point|
      point.x.between?(-5, 5) &&
      point.y.between?(-5, 5)
    end

    pattern.polygons.each do |polygon|
      # do something with each generated polygon
    end

The block given to the #generate! method determines the area of the plane
that will be tiled. Points for which the block returns false will not be
included in the resulting polygon set.


Credits
-------

Huge, huge, HUGE thanks go to [Sam Gratrix][3] for his fantastic 
[Wythoffian Uniform Tilings][4] app (an interactive Javascript app for
displaying these tilings). It's really well done, and it taught me a lot
about how Wythoffian constructions work.


License
-------

This code is released by the author, Jamis Buck, into the public domain. You
are allowed, and even encouraged, to take it and use it however you like,
without restriction.

Please prefer good over evil.


[1]: http://en.wikipedia.org/wiki/Uniform_tiling       "Uniform tiling @ Wikipedia"
[2]: http://en.wikipedia.org/wiki/Wythoff_construction "Wythoff construction @ Wikipedia"
[3]: http://gratrix.net                                "Sam Gratrix"
[4]: http://gratrix.net/tile/index.html                "Wythoffian Uniform Tilings"
