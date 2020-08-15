MLib
====

__MLib__ is a math and shape-intersection detection library written in Lua. It's aim is to be __robust__ and __easy to use__.

__NOTE:__ 
- I am (slowly) working on completely rewriting this in order to be easier to use and less bug-prone. You can check out the progress [here](../../tree/dev).
- I am currently slowing development of MLib while moving over to helping with [CPML](https://github.com/excessive/cpml). To discuss this, please comment [here](../../issues/12).

If you are looking for a library that handles updating/collision responses for you, take a look at [hxdx](https://github.com/adonaac/hxdx). It uses MLib functions as well as Box2d to handle physics calculations. 

## Downloading
You can download the latest __stable__ version of MLib by downloading the latest [release](../../releases/).
You can download the latest __working__ version of MLib by downloading the latest [commit](../../commits/master/). Documentation will __only__ be updated upon releases, not upon commits.

## Implementing
To use MLib, simply place [mlib.lua](mlib.lua) inside the desired folder in your project. Then use the `require 'path.to.mlib'` to use any of the functions.

## Examples
If you don't have [LÖVE](https://love2d.org/) installed, you can download the .zip of the demo from the [Executables](Examples/Executables) folder and extract and run the .exe that way.
You can see some examples of the code in action [here](Examples).
All examples are done using the *awesome* engine of [LÖVE](https://love2d.org/).
To run them properly, download the [.love file](Examples/LOVE) and install LÖVE to your computer.
After that, make sure you set .love files to open with "love.exe".
For more, see [here](https://love2d.org/).

## When should I use MLib?
- If you need to know exactly where two objects intersect.
- If you need general mathematical equations to be done.
- If you need very precise details about point intersections.

## When should I __not__ use MLib?
- All of the objects in a platformer, or other game, for instance, should not be registered with MLib. Only ones that need very specific information.
- When you don't need precise information/odd shapes.

## Specs
#### For Windows
If you run Windows and have Telescope in `%USERPROFILE%\Documents\GitHub` (you can also manually change the path in [test.bat](test.bat)) you can simply run [test.bat](test.bat) and it will display the results, and then clean up after it's finished.

#### Default
Alternatively, you can find the tests [here](spec.lua). Keep in mind that you may need to change certain semantics to suit your OS.
You can run them via [Telescope](https://github.com/norman/telescope/) and type the following command in the command-line of the root folder:
```
tsc -f specs.lua
```
If that does not work, you made need to put a link to Lua inside of the folder for `telescope` and run the following command:
```
lua tsc -f specs.lua
```
If you encounter further errors, try to run the command line as an administrator (usually located in `C:\Windows\System32\`), then right-click on `cmd.exe` and select `Run as administrator`, then do
```
cd C:\Path\to\telescope\
```
And __then__ run one of the above commands. If none of those work, just take my word for it that all the tests pass and look at this picture.
![Success](Reference Pictures/Success.png)

## Functions
- [mlib.line](#mlibline)
  - [mlib.line.checkPoint](#mliblinecheckpoint)
  - [mlib.line.getClosestPoint](#mliblinegetclosestpoint)
  - [mlib.line.getYIntercept](#mliblinegetintercept)
  - [mlib.line.getIntersection](#mliblinegetintersection)
  - [mlib.line.getLength](#mliblinegetlength)
  - [mlib.line.getMidpoint](#mliblinegetmidpoint)
  - [mlib.line.getPerpendicularSlope](#mliblinegetperpendicularslope)
  - [mlib.line.getSegmentIntersection](#mliblinegetsegmentintersection)
  - [mlib.line.getSlope](#mliblinegetslope)
- [mlib.segment](#mlibsegment)
  - [mlib.segment.checkPoint](#mlibsegmentcheckpoint)
  - [mlib.segment.getPerpendicularBisector](#mlibsegmentgetperpendicularbisector)
  - [mlib.segment.getIntersection](#mlibsegmentgetintersection)
- [mlib.polygon](#mlibpolygon)
  - [mlib.polygon.checkPoint](#mlibpolygoncheckpoint)
  - [mlib.polygon.getCentroid](#mlibpolygongetcentroid)
  - [mlib.polygon.getCircleIntersection](#mlibpolygongetcircleintersection)
  - [mlib.polygon.getLineIntersection](#mlibpolygongetlineintersection)
  - [mlib.polygon.getPolygonArea](#mlibpolygongetpolygonarea)
  - [mlib.polygon.getPolygonIntersection](#mlibpolygongetpolygonintersection)
  - [mlib.polygon.getSegmentIntersection](#mlibpolygongetsegmentintersection)
  - [mlib.polygon.getSignedPolygonArea](#mlibpolygongetsignedpolygonarea)
  - [mlib.polygon.getTriangleHeight](#mlibpolygongettriangleheight)
  - [mlib.polygon.isCircleInside](#mlibpolygoniscircleinside)
  - [mlib.polygon.isCircleCompletelyInside](#mlibpolygoniscirclecompletelyinside)
  - [mlib.polygon.isPolygonInside](#mlibpolygonispolygoninside)
  - [mlib.polygon.isPolygonCompletelyInside](#mlibpolygonispolygoncompletelyinside)
  - [mlib.polygon.isSegmentInside](#mlibpolygonissegmentinside)
  - [mlib.polygon.isSegmentCompletelyInside](#mlibpolygonissegmentcompletelyinside)
- [mlib.circle](#mlibcircle)
  - [mlib.circle.checkPoint](#mlibcirclecheckpoint)
  - [mlib.circle.getArea](#mlibcirclegetarea)
  - [mlib.circle.getCircleIntersection](#mlibcirclegetcircleintersection)
  - [mlib.circle.getCircumference](#mlibcirclegetcircumference)
  - [mlib.circle.getLineIntersection](#mlibcirclegetlineintersection)
  - [mlib.circle.getSegmentIntersection](#mlibcirclegetsegmentintersection)
  - [mlib.circle.isCircleCompletelyInside](#mlibcircleiscirclecompletelyinside)
  - [mlib.circle.isCircleCompletelyInsidePolygon](#mlibcircleiscirclecompletelyinsidepolygon)
  - [mlib.circle.isPointOnCircle](#mlibcircleispointoncircle)
  - [mlib.circle.isPolygonCompletelyInside](#mlibcircleispolygoncompletelyinside)
- [mlib.statistics](#mlibstatistics)
  - [mlib.statistics.getCentralTendency](#mlibstatisticsgetcentraltendency)
  - [mlib.statistics.getDispersion](#mlibstatisticsgetdispersion)
  - [mlib.statistics.getMean](#mlibstatisticsgetmean)
  - [mlib.statistics.getMedian](#mlibstatisticsgetmedian)
  - [mlib.statistics.getMode](#mlibstatisticsgetmode)
  - [mlib.statistics.getRange](#mlibstatisticsgetrange)
  - [mlib.statistics.getStandardDeviation](#mlibstatisticsgetstandarddeviation)
  - [mlib.statistics.getVariance](#mlibstatisticsgetvariance)
  - [mlib.statistics.getVariationRatio](#mlibstatisticsgetvariationratio)
- [mlib.math](#mlibmath)
  - [mlib.math.getAngle](#mlibmathgetangle)
  - [mlib.math.getPercentage](#mlibmathgetpercentage)
  - [mlib.math.getPercentOfChange](#mlibmathgetpercentofchange)
  - [mlib.math.getQuadraticRoots](#mlibmathgetquadraticroots)
  - [mlib.math.getRoot](#mlibmathgetroot)
  - [mlib.math.getSummation](#mlibmathgetsummation)
  - [mlib.math.isPrime](#mlibmathisprime)
  - [mlib.math.round](#mlibmathround)
- [Aliases](#aliases)

#### mlib.line
- Deals with linear aspects, such as slope and length.

##### mlib.line.checkPoint
- Checks if a point lies on a line.
- Synopsis:
  - `onPoint = mlib.line.checkPoint( px, px, x1, y1, x2, y2 )`
- Arguments:
  - `px`, `py`: Numbers. The x and y coordinates of the point being tested.
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates of the line being tested.
- Returns:
  - `onPoint`: Boolean.
    - `true` if the point is on the line.
	- `false` if it does not.
- Notes:
  - You cannot use the format `mlib.line.checkPoint( px, px, slope, intercept )` because this would lead to errors on vertical lines.

##### mlib.line.getClosestPoint
- Gives the closest point to a line.
- Synopses:
  - `cx, cy = mlib.line.getClosestPoint( px, py, x1, y1, x2, y2 )`
  - `cx, cy = mlib.line.getClosestPoint( px, py, slope, intercept )`
- Arguments:
  - `x`, `y`: Numbers. The x and y coordinates of the point.
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates on the line.
  - `slope`, `intercept`:
    - Numbers. The slope and y-intercept of the line.
	- Booleans (`false`). The slope and y-intercept of a vertical line.
- Returns:
  - `cx`, `cy`: Numbers. The closest points that lie on the line to the point.

##### mlib.line.getYIntercept
- Gives y-intercept of the line.
- Synopses:
  - `intercept, isVertical = mlib.line.getYIntercept( x1, y1, x2, y2 )`
  - `intercept, isVertical = mlib.line.getYIntercept( x1, y1, slope )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates that lie on the line.
  - `slope`:
    - Number. The slope of the line.
- Returns:
  - `intercept`:
    - Number. The y-intercept of the line.
    - Number. The `x1` coordinate of the line if the line is vertical.
  - `isVertical`:
    - Boolean. `true` if the line is vertical, `false` if the line is not vertical.

##### mlib.line.getIntersection
- Gives the intersection of two lines.
- Synopses:
  - `x, y = mlib.line.getIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )`
  - `x, y = mlib.line.getIntersection( slope1, intercept1, x3, y3, x4, y4 )`
  - `x, y = mlib.line.getIntersection( slope1, intercept1, slope2, intercept2 )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates that lie on the first line.
  - `x3`, `y3`, `x4`, `y4`: Numbers. Two x and y coordinates that lie on the second line.
  - `slope1`, `intercept1`:
    - Numbers. The slope and y-intercept of the first line.
	- Booleans (`false`). The slope and y-intercept of the first line (if the first line is vertical).
  - `slope2`, `intercept2`:
    - Numbers. The slope and y-intercept of the second line.
	- Booleans (`false`). The slope and y-intercept of the second line (if the second line is vertical).
- Returns:
  - `x`, `y`:
    - Numbers. The x and y coordinate where the lines intersect.
	- Boolean:
	  - `true`, `nil`: The lines are collinear.
	  - `false`, `nil`: The lines are parallel and __not__ collinear.

##### mlib.line.getLength
- Gives the distance between two points.
- Synopsis:
  - `length = mlib.line.getLength( x1, y1, x2, y2 )
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
- Returns:
  - `length`: Number. The distance between the two points.

##### mlib.line.getMidpoint
- Gives the midpoint of two points.
- Synopsis:
  - `x, y = mlib.line.getMidpoint( x1, y1, x2, y2 )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
- Returns:
  - `x`, `y`: Numbers. The midpoint x and y coordinates.

##### mlib.line.getPerpendicularSlope
- Gives the perpendicular slope of a line.
- Synopses:
  - `perpSlope = mlib.line.getPerpendicularSlope( x1, y1, x2, y2 )`
  - `perpSlope = mlib.line.getPerpendicularSlope( slope )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
  - `slope`: Number. The slope of the line.
- Returns:
  - `perpSlope`:
    - Number. The perpendicular slope of the line.
	- Boolean (`false`). The perpendicular slope of the line (if the original line was horizontal).

##### mlib.line.getSegmentIntersection
- Gives the intersection of a line segment and a line.
- Synopses:
  - `x1, y1, x2, y2 = mlib.line.getSegmentIntersection( x1, y1, x2, y2, x3, y3, x4, y4 )`
  - `x1, y1, x2, y2 = mlib.line.getSegmentIntersection( x1, y1, x2, y2, slope, intercept )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates that lie on the line segment.
  - `x3`, `y3`, `x4`, `y4`: Numbers. Two x and y coordinates that lie on the line.
  - `slope`, `intercept`:
    - Numbers. The slope and y-intercept of the the line.
	- Booleans (`false`). The slope and y-intercept of the line (if the line is vertical).
- Returns:
  - `x1`, `y1`, `x2`, `y2`:
    - Number, Number, Number, Number.
	  - The points of the line segment if the line and segment are collinear.
	- Number, Number, Boolean (`nil`), Boolean (`nil`).
	  - The coordinate of intersection if the line and segment intersect and are not collinear.
	- Boolean (`false`), Boolean (`nil`), Boolean (`nil`),
	  - Boolean (`nil`). If the line and segment don't intersect.

##### mlib.line.getSlope
- Gives the slope of a line.
- Synopsis:
  - `slope = mlib.line.getSlope( x1, y1, x2, y2 )
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
- Returns:
  - `slope`:
    - Number. The slope of the line.
	- Boolean (`false`). The slope of the line (if the line is vertical).

#### mlib.segment
- Deals with line segments.

##### mlib.segment.checkPoint
- Checks if a point lies on a line segment.
- Synopsis:
  - `onSegment = mlib.segment.checkPoint( px, py, x1 y1, x2, y2 )`
- Arguments:
  - `px`, `py`: Numbers. The x and y coordinates of the point being checked.
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
- Returns:
  - `onSegment`: Boolean.
    - `true` if the point lies on the line segment.
	- `false` if the point does not lie on the line segment.

##### mlib.segment.getPerpendicularBisector
- Gives the perpendicular bisector of a line.
- Synopsis:
  - `x, y, slope = mlib.segment.getPerpendicularBisector( x1, y1, x2, y2 )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
- Returns:
  - `x`, `y`: Numbers. The midpoint of the line.
  - `slope`:
    - Number. The perpendicular slope of the line.
	- Boolean (`false`). The perpendicular slope of the line (if the original line was horizontal).

##### mlib.segment.getIntersection
- Checks if two line segments intersect.
- Synopsis:
  - `cx1, cy1, cx2, cy2 = mlib.segment.getIntersection( x1, y1, x2, y2, x3, y3 x4, y4 )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates of the first line segment.
  - `x3`, `y3`, `x4`, `y4`: Numbers. Two x and y coordinates of the second line segment.
- Returns:
  - `cx1`, `cy1`, `cx2`, `cy2`:
    - Number, Number, Number, Number.
	  - The points of the resulting intersection if the line segments are collinear.
	- Number, Number, Boolean (`nil`), Boolean (`nil`).
	  - The point of the resulting intersection if the line segments are not collinear.
	- Boolean (`false`), Boolean (`nil`), Boolean (`nil`) , Boolean (`nil`).
	  - If the line segments don't intersect.

#### mlib.polygon
- Handles aspects involving polygons.

##### mlib.polygon.checkPoint
- Checks if a point is inside of a polygon.
- Synopses:
  - `inPolygon = mlib.polygon.checkPoint( px, py, vertices )`
  - `inPolygon = mlib.polygon.checkPoint( px, py, ... )`
- Arguments:
  - `px`, `py`: Numbers. The x and y coordinate of the point being checked.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the point is inside the polygon.
	- `false` if the point is not inside the polygon.

##### mlib.polygon.getCentroid
- Returns the centroid of the polygon.
- Synopses:
  - `cx, cy = mlib.polygon.getCentroid( vertices )`
  - `cx, cy = mlib.polygon.getCentroid( ... )`
- Arguments:
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `cx`, `cy`: Numbers. The x and y coordinates of the centroid.

##### mlib.polygon.getCircleIntersection
- Returns the coordinates of where a circle intersects a polygon.
- Synopses:
  - `intersections = mlib.polygon.getCircleIntersection( cx, cy, radius, vertices )`
  - `intersections = mlib.polygon.getCircleIntersection( cx, cy, radius, ... )
- Arguments:
  - `cx`, `cy`: Number. The coordinates of the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `intersections`: Table. Contains the intersections and type.
- Example:
```lua
local tab = _.polygon.getCircleIntersection( 5, 5, 1, 4, 4, 6, 4, 6, 6, 4, 6 )
for i = 1, # tab do
	print( i .. ':', unpack( tab[i] ) )
end
-- 1: 	tangent		5		4
-- 2: 	tangent		6 		5
-- 3: 	tangent 	5		6
-- 4: 	tagnent 	4		5
```
- For more see [mlib.circle.getSegmentIntersection](#mlibcirclegetsegmentintersection) or the [specs](spec.lua# L676)

##### mlib.polygon.getLineIntersection
- Returns the coordinates of where a line intersects a polygon.
- Synopses:
  - `intersections = mlib.polygon.getLineIntersection( x1, y1, x2, y2, vertices )`
  - `intersections = mlib.polygon.getLineIntersection( x1, y1, x2, y2, ... )
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `intersections`: Table. Contains the intersections.
- Notes:
  - With collinear lines, they are actually broken up. i.e. `{ 0, 4, 0, 0 }` would become `{ 0, 4 }, { 0, 0 }`.

##### mlib.polygon.getPolygonArea
- Gives the area of a polygon.
- Synopses:
  - `area = mlib.polygon.getArea( vertices )`
  - `area = mlib.polygon.getArea( ... )
- Arguments:
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `area`: Number. The area of the polygon.

##### mlib.polygon.getPolygonIntersection
- Gives the intersection of two polygons.
- Synopsis:
  - `intersections = mlib.polygon.getPolygonIntersections( polygon1, polygon2 )`
- Arguments:
  - `polygon1`: Table. The vertices of the first polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `polygon2`: Table. The vertices of the second polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
- Returns:
  - `intersections`: Table. A table of the points of intersection.

##### mlib.polygon.getSegmentIntersection
- Returns the coordinates of where a line segmeing intersects a polygon.
- Synopses:
  - `intersections = mlib.polygon.getSegmentIntersection( x1, y1, x2, y2, vertices )`
  - `intersections = mlib.polygon.getSegmentIntersection( x1, y1, x2, y2, ... )
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `intersections`: Table. Contains the intersections.
- Notes:
  - With collinear line segments, they are __not__ broken up. See the [specs](spec.lua# L508) for more.

##### mlib.polygon.getSignedPolygonArea
- Gets the signed area of the polygon. If the points are ordered counter-clockwise the area is positive. If the points are ordered clockwise the number is negative.
- Synopses:
  - `area = mlib.polygon.getLineIntersection( vertices )`
  - `area = mlib.polygon.getLineIntersection( ... )
- Arguments:
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `area`: Number. The __signed__ area of the polygon. If the points are ordered counter-clockwise the area is positive. If the points are ordered clockwise the number is negative.

##### mlib.polygon.getTriangleHeight
- Gives the height of a triangle.
- Synopses:
  - `height = mlib.polygon.getTriangleHeigh( base, x1, y1, x2, y2, x3, y3 )`
  - `height = mlib.polygon.getTriangleHeight( base, area )`
- Arguments:
  - `base`: Number. The length of the base of the triangle.
  - `x1`, `y1`, `x2`, `y2`, `x3`, `y3`: Numbers. The x and y coordinates of the triangle.
  - `area`: Number. The regular area of the triangle. __Not__ the signed area.
- Returns:
  - `height`: Number. The height of the triangle.

##### mlib.polygon.isCircleInside
- Checks if a circle is inside the polygon.
- Synopses:
  - `inPolygon = mlib.polygon.isCircleInside( cx, cy, radius, vertices )`
  - `inPolygon = mlib.polygon.isCircleInside( cx, cy, radius, ... )`
- Arguments:
  - `cx`, `cy`: Numbers. The x and y coordinates for the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the circle is inside the polygon.
	- `false` if the circle is not inside the polygon.
- Notes:
  - Only returns true if the center of the circle is inside the circle.

##### mlib.polygon.isCircleCompletelyInside
- Checks if a circle is completely inside the polygon.
- Synopses:
  - `inPolygon = mlib.polygon.isCircleCompletelyInside( cx, cy, radius, vertices )`
  - `inPolygon = mlib.polygon.isCircleCompletelyInside( cx, cy, radius, ... )`
- Arguments:
  - `cx`, `cy`: Numbers. The x and y coordinates for the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the circle is __completely__ inside the polygon.
	- `false` if the circle is not inside the polygon.

##### mlib.polygon.isPolygonInside
- Checks if a polygon is inside a polygon.
- Synopsis:
  - `inPolygon = mlib.polygon.isPolygonInside( polygon1, polygon2 )`
- Arguments:
  - `polygon1`: Table. The vertices of the first polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `polygon2`: Table. The vertices of the second polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the `polygon2` is inside of `polygon1`.
	- `false` if `polygon2` is not inside of `polygon2`.
- Notes:
  - Returns true as long as any of the line segments of `polygon2` are inside of the `polygon1`.

##### mlib.polygon.isPolygonCompletelyInside
- Checks if a polygon is completely inside a polygon.
- Synopsis:
  - `inPolygon = mlib.polygon.isPolygonCompletelyInside( polygon1, polygon2 )`
- Arguments:
  - `polygon1`: Table. The vertices of the first polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `polygon2`: Table. The vertices of the second polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the `polygon2` is __completely__ inside of `polygon1`.
	- `false` if `polygon2` is not inside of `polygon2`.

##### mlib.polygon.isSegmentInside
- Checks if a line segment is inside a polygon.
- Synopses:
  - `inPolygon = mlib.polygon.isSegmentInside( x1, y1, x2, y2, vertices )`
  - `inPolygon = mlib.polygon.isSegmentInside( x1, y1, x2, y2, ... )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. The x and y coordinates of the line segment.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the line segment is inside the polygon.
	- `false` if the line segment is not inside the polygon.
- Note:
  - Only one of the points has to be in the polygon to be considered 'inside' of the polygon.
  - This is really just a faster version of [mlib.polygon.getPolygonIntersection](#mlibpolygongetpolygonintersection) that does not give the points of intersection.

##### mlib.polygon.isSegmentCompletelyInside
- Checks if a line segment is completely inside a polygon.
- Synopses:
  - `inPolygon = mlib.polygon.isSegmentCompletelyInside( x1, y1, x2, y2, vertices )`
  - `inPolygon = mlib.polygon.isSegmentCompletelyInside( x1, y1, x2, y2, ... )`
- Arguments:
  - `x1`, `y1`, `x2`, `y2`: Numbers. The x and y coordinates of the line segment.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the line segment is __completely__ inside the polygon.
	- `false` if the line segment is not inside the polygon.

#### mlib.circle
- Handles aspects involving circles.

##### mlib.circle.checkPoint
- Checks if a point is on the inside or on the edge the circle.
- Synopsis:
  - `inCircle = mlib.circle.checkPoint( px, px, cx, cy, radius )`
- Arguments:
  - `px`, `py`: Numbers. The x and y coordinates of the point being tested.
  - `cx`, `cy`: Numbers. The x and y coordinates of the center of the circle.
  - `radius`: Number. The radius of the circle.
- Returns:
  - `inCircle`: Boolean.
    - `true` if the point is inside or on the circle.
	- `false` if the point is outside of the circle.

##### mlib.circle.getArea
- Gives the area of a circle.
- Synopsis:
  - `area = mlib.circle.getArea( radius )`
- Arguments:
  - `radius`: Number. The radius of the circle.
- Returns:
  - `area`: Number. The area of the circle.

##### mlib.circle.getCircleIntersection
- Gives the intersections of two circles.
- Synopsis:
  - `intersections = mlib.circle.getCircleIntersection( c1x, c1y, radius1, c2x, c2y, radius2 )
- Arguments:
  - `c1x`, `c1y`: Numbers. The x and y coordinate of the first circle.
  - `radius1`: Number. The radius of the first circle.
  - `c2x`, `c2y`: Numbers. The x and y coordinate of the second circle.
  - `radius2`: Number. The radius of the second circle.
- Returns:
  - `intersections`: Table. A table that contains the type and where the circle collides. See the [specs](spec.lua# L698) for more.

##### mlib.circle.getCircumference
- Returns the circumference of a circle.
- Synopsis:
  - `circumference = mlib.circle.getCircumference( radius )`
- Arguments:
  - `radius`: Number. The radius of the circle.
- Returns:
  - `circumference`: Number. The circumference of a circle.

##### mlib.circle.getLineIntersection
- Returns the intersections of a circle and a line.
- Synopsis:
  - `intersections = mlib.circle.getLineIntersections( cx, cy, radius, x1, y1, x2, y2 )`
- Arguments:
  - `cx`, `cy`: Numbers. The x and y coordinates for the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `x1`, `y1`, `x2`, `y2`: Numbers. Two x and y coordinates the lie on the line.
- Returns:
  - `intersections`: Table. A table with the type and where the intersections happened. Table is formatted:
    - `type`, `x1`, `y1`, `x2`, `y2`
	  - String (`'secant'`), Number, Number, Number, Number
	    - The numbers are the x and y coordinates where the line intersects the circle.
	  - String (`'tangent'`), Number, Number, Boolean (`nil`), Boolean (`nil`)
	    - `x1` and `x2` represent where the line intersects the circle.
	  - Boolean (`false`), Boolean (`nil`), Boolean (`nil`), Boolean (`nil`), Boolean (`nil`)
	    - No intersection.
    - For more see the [specs](spec.lua# L660).

##### mlib.circle.getSegmentIntersection
- Returns the intersections of a circle and a line segment.
- Synopsis:
  - `intersections = mlib.circle.getSegmentIntersections( cx, cy, radius, x1, y1, x2, y2 )`
- Arguments:
  - `cx`, `cy`: Numbers. The x and y coordinates for the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `x1`, `y1`, `x2`, `y2`: Numbers. The two x and y coordinates of the line segment.
- Returns:
  - `intersections`: Table. A table with the type and where the intersections happened. Table is formatted:
    - `type`, `x1`, `y1`, `x2`, `y2`
	  - String (`'chord'`), Number, Number, Number, Number
	    - The numbers are the x and y coordinates where the line segment is on both edges of the circle.
	  - String (`'enclosed'`), Number, Number, Number, Number
	    - The numbers are the x and y coordinates of the line segment if it is fully inside of the circle.
	  - String (`'secant'`), Number, Number, Number, Number
	    - The numbers are the x and y coordinates where the line segment intersects the circle.
	  - String (`'tangent'`), Number, Number, Boolean (`nil`), Boolean (`nil`)
	    - `x1` and `x2` represent where the line segment intersects the circle.
	  - Boolean (`false`), Boolean (`nil`), Boolean (`nil`), Boolean (`nil`), Boolean (`nil`)
	    - No intersection.
    - For more see the [specs](spec.lua# L676).

##### mlib.circle.isCircleCompletelyInside
- Checks if one circle is completely inside of another circle.
- Synopsis:
  - `completelyInside = mlib.circle.isCircleCompletelyInside( c1x, c1y, c1radius, c2x, c2y, c2radius )`
- Arguments:
  - `c1x`, `c1y`: Numbers. The x and y coordinates of the first circle.
  - `c1radius`: Number. The radius of the first circle.
  - `c2x`, `c2y`: Numbers. The x and y coordinates of the second circle.
  - `c2radius`: Number. The radius of the second circle.
- Returns:
  - `completelyInside`: Boolean.
    - `true` if circle1 is inside of circle2.
	- `false` if circle1 is not __completely__ inside of circle2.

##### mlib.circle.isCircleCompletelyInsidePolygon
- Checks if a circle is completely inside the polygon.
- Synopses:
  - `inPolygon = mlib.polygon.isCircleCompletelyInside( cx, cy, radius, vertices )`
  - `inPolygon = mlib.polygon.isCircleCompletelyInside( cx, cy, radius, ... )`
- Arguments:
  - `cx`, `cy`: Numbers. The x and y coordinates for the center of the circle.
  - `radius`: Number. The radius of the circle.
  - `vertices`: Table. The vertices of the polygon in the format `{ x1, y1, x2, y2, x3, y3, ... }`
  - `...`: Numbers. The x and y coordinates of the polygon. (Same as using `unpack( vertices )`)
- Returns:
  - `inPolygon`: Boolean.
    - `true` if the circle is __completely__ inside the polygon.
	- `false` if the circle is not inside the polygon.

##### mlib.circle.isPointOnCircle
- Checks if a point is __exactly__ on the edge of the circle.
- Synopsis:
  - `onCircle = mlib.circle.checkPoint( px, px, cx, cy, radius )`
- Arguments:
  - `px`, `py`: Numbers. The x and y coordinates of the point being tested.
  - `cx`, `cy`: Numbers. The x and y coordinates of the center of the circle.
  - `radius`: Number. The radius of the circle.
- Returns:
  - `onCircle`: Boolean.
    - `true` if the point is on the circle.
	- `false` if the point is on the inside or outside of the circle.
- Notes:
  - Will return false if the point is inside __or__ outside of the circle.

##### mlib.circle.isPolygonCompletelyInside
- Checks if a polygon is completely inside of a circle.
- Synopsis:
  - `completelyInside = mlib.circle.isPolygonCompletelyInside( circleX, circleY, circleRadius, vertices )`
  - `completelyInside = mlib.circle.isPolygonCompletelyInside( circleX, circleY, circleRadius, ... )`
- Arguments:
  - `circleX`, `circleY`: Numbers. The x and y coordinates of the circle.
  - `circleRadius`: Number. The radius of the circle.
  - `vertices`: Table. A table containing all of the vertices of the polygon.
  - `...`: Numbers. All of the points of the polygon.
- Returns:
  - `completelyInside`: Boolean.
    - `true` if the polygon is inside of the circle.
	- `false` if the polygon is not __completely__ inside of the circle.

#### mlib.statistics
- Handles statistical aspects of math.

##### mlib.statistics.getCentralTendency
- Gets the central tendency of the data.
- Synopses:
  - `modes, occurrences, median, mean = mlib.statistics.getCentralTendency( data )`
  - `modes, occurrences, median, mean = mlib.statistics.getCentralTendency( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `modes, occurrences`: Table, Number. The modes of the data and the number of times it occurs. See [mlib.statistics.getMode](#mlibstatisticsgetmode).
  - `median`: Number. The median of the data set.
  - `mean`: Number. The mean of the data set.

##### mlib.statistics.getDispersion
- Gets the dispersion of the data.
- Synopses:
  - `variationRatio, range, standardDeviation = mlib.statistics.getDispersion( data )`
  - `variationRatio, range, standardDeviation = mlib.statistics.getDispersion( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `variationRatio`: Number. The variation ratio of the data set.
  - `range`: Number. The range of the data set.
  - `standardDeviation`: Number. The standard deviation of the data set.

##### mlib.statistics.getMean
- Gets the arithmetic mean of the data.
- Synopses:
  - `mean = mlib.statistics.getMean( data )`
  - `mean = mlib.statistics.getMean( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `mean`: Number. The arithmetic mean of the data set.

##### mlib.statistics.getMedian
- Gets the median of the data set.
- Synopses:
  - `median = mlib.statistics.getMedian( data )`
  - `median = mlib.statistics.getMedian( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `median`: Number. The median of the data.

##### mlib.statistics.getMode
- Gets the mode of the data set.
- Synopses:
  - `mode, occurrences = mlib.statistics.getMode( data )`
  - `mode, occurrences = mlib.statistics.getMode( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `mode`: Table. The mode(s) of the data.
  - `occurrences`: Number. The number of time the mode(s) occur.

##### mlib.statistics.getRange
- Gets the range of the data set.
- Synopses:
  - `range = mlib.statistics.getRange( data )`
  - `range = mlib.statistics.getRange( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `range`: Number. The range of the data.

##### mlib.statistics.getStandardDeviation
- Gets the standard deviation of the data.
- Synopses:
  - `standardDeviation = mlib.statistics.getStandardDeviation( data )`
  - `standardDeviation = mlib.statistics.getStandardDeviation( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `standardDeviation`: Number. The standard deviation of the data set.

##### mlib.statistics.getVariance
- Gets the variation of the data.
- Synopses:
  - `variance = mlib.statistics.getVariance( data )`
  - `variance = mlib.statistics.getVariance( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `variance`: Number. The variation of the data set.

##### mlib.statistics.getVariationRatio
- Gets the variation ratio of the data.
- Synopses:
  - `variationRatio = mlib.statistics.getVariationRatio( data )`
  - `variationRatio = mlib.statistics.getVariationRatio( ... )`
- Arguments:
  - `data`: Table. A table containing the values of data.
  - `...`: Numbers. All of the numbers in the data set.
- Returns:
  - `variationRatio`: Number. The variation ratio of the data set.

#### mlib.math
- Miscellaneous functions that have no home.

##### mlib.math.getAngle
- Gets the angle between three points.
- Synopsis:
  - `angle = mlib.math.getAngle( x1, y1, x2, y2, x3, y3 )`
- Arguments:
  - `x1`, `y1`: Numbers. The x and y coordinates of the first point.
  - `x2`, `y2`: Numbers. The x and y coordinates of the vertex of the two points.
  - `x3`, `y3`: Numbers. The x and y coordinates of the second point.

##### mlib.math.getPercentage
- Gets the percentage of a number.
- Synopsis:
  - `percentage = mlib.math.getPercentage( percent, number )`
- Arguments:
  - `percent`: Number. The decimal value of the percent (i.e. 100% is 1, 50% is .5).
  - `number`: Number. The number to get the percentage of.
- Returns:
  - `percentage`: Number. The `percent`age or `number`.

##### mlib.math.getPercentOfChange
- Gets the percent of change from one to another.
- Synopsis:
  - `change = mlib.math.getPercentOfChange( old, new )`
- Arguments:
  - `old`: Number. The original number.
  - `new`: Number. The new number.
- Returns:
  - `change`: Number. The percent of change from `old` to `new`.

##### mlib.math.getQuadraticRoots
- Gets the quadratic roots of the the equation.
- Synopsis:
  - `root1, root2 = mlib.math.getQuadraticRoots( a, b, c )`
- Arguments:
  - `a`, `b`, `c`: Numbers. The a, b, and c values of the equation `a * x ^ 2 + b * x ^ 2 + c`.
- Returns:
  - `root1`, `root2`: Numbers. The roots of the equation (where `a * x ^ 2 + b * x ^ 2 + c = 0`).

##### mlib.math.getRoot
- Gets the `n`th root of a number.
- Synopsis:
  - `x = mlib.math.getRoot( number, root )`
- Arguments:
  - `number`: Number. The number to get the root of.
  - `root`: Number. The root.
- Returns:
  - `x`: The `root`th root of `number`.
- Example:
```lua
local a = mlib.math.getRoot( 4, 2 ) -- Same as saying 'math.pow( 4, .5 )' or 'math.sqrt( 4 )' in this case.
local b = mlib.math.getRoot( 27, 3 )

print( a, b ) --> 2, 3
```
  - For more, see the [specs](spec.lua# L860).

##### mlib.math.getSummation
- Gets the summation of numbers.
- Synopsis:
  - `summation = mlib.math.getSummation( start, stop, func )`
- Arguments:
  - `start`: Number. The number at which to start the summation.
  - `stop`: Number. The number at which to stop the summation.
  - `func`: Function. The method to add the numbers.
    - Arguments:
	  - `i`: Number. Index.
	  - `previous`: Table. The previous values used.
- Returns:
  - `Summation`: Number. The summation of the numbers.
  - For more, see the [specs](spec.lua# L897).

##### mlib.math.isPrime
- Checks if a number is prime.
- Synopsis:
  - `isPrime = mlib.math.isPrime( x )`
- Arguments:
  - `x`: Number. The number to check if it's prime.
- Returns:
  - `isPrime`: Boolean.
    - `true` if the number is prime.
	- `false` if the number is not prime.

##### mlib.math.round
- Rounds a number to the given decimal place.
- Synopsis:
  - `rounded = mlib.math.round( number, [place] )
- Arguments:
  - `number`: Number. The number to round.
  - `place (1)`: Number. The decimal place to round to. Defaults to 1.
- Returns:
  - The rounded number.
  - For more, see the [specs](spec.lua# L881).

#### Aliases
| Alias                                         | Corresponding Function                                                            |
| ----------------------------------------------|:---------------------------------------------------------------------------------:|
| milb.line.getDistance                         | [mlib.line.getLength](#mliblinegetlength)                                         |
| mlib.line.getCircleIntersection               | [mlib.circle.getLineIntersection](#mlibcirclegetlineintersection)                 |
| milb.line.getPolygonIntersection              | [mlib.polygon.getLineIntersection](#mlibpolygongetlineintersection)               |
| mlib.line.getLineIntersection                 | [mlib.line.getIntersection](#mliblinegetintersection)                             |
| mlib.segment.getCircleIntersection            | [mlib.circle.getSegmentIntersection](#mlibcirclegetsegmentintersection)           |
| milb.segment.getPolygonIntersection           | [mlib.pollygon.getSegmentIntersection](#mlibpollygongetsegmentintersection)       |
| mlib.segment.getLineIntersection              | [mlib.line.getSegmentIntersection](#mliblinegetsegmentintersection)               |
| mlib.segment.getSegmentIntersection           | [mlib.segment.getIntersection](#mlibsegmentgetintersection)                       |
| milb.segment.isSegmentCompletelyInsideCircle  | [mlib.circle.isSegmentCompletelyInside](#mlibcircleissegmentcompletelyinside)     |
| mlib.segment.isSegmentCompletelyInsidePolygon | [mlib.polygon.isSegmentCompletelyInside](#mlibpolygonissegmentcompletelyinside)   |
| mlib.circle.getPolygonIntersection            | [mlib.polygon.getCircleIntersection](#mlibpolygongetcircleintersection)           |
| mlib.circle.isCircleInsidePolygon             | [mlib.polygon.isCircleInside](#mlibpolygoniscircleinside)                         |
| mlib.circle.isCircleCompletelyInsidePolygon   | [mlib.polygon.isCircleCompletelyInside](#mlibpolygoniscirclecompletelyinside)     |
| mlib.polygon.isCircleCompletelyOver           | [mlib.circleisPolygonCompletelyInside](#mlibcircleispolygoncompletelyinside)      |

## License
A math library made in Lua
copyright (C) 2014 Davis Claiborne
This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.
You should have received a copy of the GNU General Public License along
with this program; if not, write to the Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
Contact me at davisclaib at gmail.com
