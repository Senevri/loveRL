
-- Averages an arbitrary number of angles.
function math.averageAngles(...)
    local x,y = 0,0
    for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
    return math.atan2(y, x)
end


-- Returns the distance between two points.
function math.dist(x1,y1, x2,y2) 
	return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

-- Distance between two 3D points:
function math.dist3d(x1,y1,z1, x2,y2,z2) return ((x2-x1)^2+(y2-y1)^2+(z2-z1)^2)^0.5 end


-- Returns the angle between two points.
function math.getAngle(x1,y1, x2,y2) return (math.halfPI - math.atan2(x2-x1, y2-y1)) end


-- Returns the closest multiple of 'size' (defaulting to 10).
function math.multiple(n, size) size = size or 10 return math.round(n/size)*size end


-- Clamps a number to within a certain range.
function math.clamp(low, n, high) return math.min(math.max(n, low), high) end


-- Normalizes two numbers.
function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end
-- Normalizes a table of numbers.
function math.normalize(t) local n,m = #t,0 for i=1,n do m=m+t[i] end m=1/m for i=1,n do t[i]=t[i]*m end return t end

math.halfPI = math.pi/2

function math.translate(x, y, angle, distance) 
	x = x + distance * math.cos(angle)
	y = y + distance * math.sin(angle)
	return x, y
end

-- Returns 'n' rounded to the nearest 'deci'th.
function math.round(n, deci) deci = 10^(deci or 0) return math.floor(n*deci+.5)/deci end


-- Randomly returns either -1 or 1.
function math.rsign() return math.random(2) == 2 and 1 or -1 end


-- Returns 1 if number is positive, -1 if it's negative, or 0 if it's 0.
function math.sign(n) return n>0 and 1 or n<0 and -1 or 0 end


-- Checks if two line segments intersect. Line segments are given in form of ({x,y},{x,y}, {x,y},{x,y}).
function checkIntersect(l1p1, l1p2, l2p1, l2p2)
    local function checkDir(pt1, pt2, pt3) return math.sign(((pt2.x-pt1.x)*(pt3.y-pt1.y)) - ((pt3.x-pt1.x)*(pt2.y-pt1.y))) end
    return (checkDir(l1p1,l1p2,l2p1) ~= checkDir(l1p1,l1p2,l2p2)) and (checkDir(l2p1,l2p2,l1p1) ~= checkDir(l2p1,l2p2,l1p2))
end

return math
