local color = require "il.color"
local function nearestNeighbor( img, x, y )
end
local function bilinear( img, x, y )
  local x1, x2, y1, y2;
  x1 = math.floor(x)
  x2 = math.ceil(x)
  y1 = math.floor(y)
  y2 = math.ceil(y)
  if x2 >= img.width then x2 = img.width - 1 end
  if y2 >= img.height then y2 = img.height - 1 end
  
  local weightX1 = (x-x1)/(x2-x1)
  local weightX2 = (x2-x)/(x2-x1)
  local weightY1 = (y-y1)/(y2-y1)
  local weightY2 = (y2-y)/(y2-y1)
  
  local p1, p2, p3, p4
  p1 = img:at(x1,y1)
  p2 = img:at(x2,y1)
  p3 = img:at(x1,y2)
  p4 = img:at(x2,y2)

  local r1r, r2r, r1g, r2g, r1b, r2b
  r1r = weightX2*p1.r + weightX1*p2.r
  r1g = weightX2*p1.g + weightX1*p2.g
  r1b = weightX2*p1.b + weightX1*p2.b

  r2r = weightX2*p3.r + weightX1*p4.r
  r2g = weightX2*p3.g + weightX1*p4.g
  r2b = weightX2*p3.b + weightX1*p4.b
  
  local r, g, b
  r = weightY2*r1r + weightY1*r2r
  g = weightY2*r1g + weightY1*r2g
  b = weightY2*r1b + weightY1*r2b
  
  return r, g, b
end
local function bicubic( img, x, y )
end

return {
  neighbor = nearestNeighbor,
  bilinear = bilinear,
  bicubic = bicubic,
}
