require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function bilinear( img, q )
  local width, height = img.width, img.height
  local xMin, xMax, yMin, yMax = q[1].x, q[1].x, q[1].y, q[1].y
  for i =2, 4 do
    if q[i].x < xMin then xMin = q[i].x end
    if q[i].x > xMax then xMax = q[i].x end
    if q[i].y < yMin then yMin = q[i].y end
    if q[i].y > yMax then yMax = q[i].y end
  end
  -- find distance between x' and y' min and max
  local deltaX = xMax-xMin
  local deltaY = yMax-yMin
  
  local deltaX1, deltaX2, deltaX3, deltaY1, deltaY2, deltaY3
  deltaX1 = q[2].x - q[3].x
  deltaX2 = q[4].x - q[3].x
  deltaX3 = q[1].x - q[2].x + q[3].x - q[4].x
  deltaY1 = q[2].y - q[3].y
  deltaY2 = q[4].y - q[3].y
  deltaY3 = q[1].y - q[2].y + q[3].y - q[4].y
  -- create new image based on x' and y' size
  local newImg = image.flat(deltaX, deltaY ,225)
    -- calculate a - f
  local a,b,c,d,e,f,g,h
  if (deltaX3 == 0 and deltaY3 == 0) then
    g = ((deltaX3*deltaY2)-(deltaY3*deltaX2))/((deltaX1*deltaY2)-(deltaY1*deltaX2))
    h = ((deltaX1*deltaY3)-(deltaY1*deltaX3))/((deltaX1*deltaY2)-(deltaY1*deltaX2))
    b = (q[4].x - q[1].x + (h * q[4].x))/height
    e = (q[4].y - q[1].y + (h * q[4].y))/height
  else
    g = 0
    h = 0
    b = (q[3].x - q[2].x)/height
    e = (q[3].y - q[2].y)/height
  end
    a = (q[2].x - q[1].x + (g * q[2].x))/width
    c = q[1].x
    d = (q[2].y - q[1].y + (g * q[2].y))/width
    f = q[1].y
  -- since z' is 0 
  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u = (1/(a-g*x)) * ( (x-c) + ((h*x - b)*(y-f)/(e-h*y)))/(1-(((h*x-b)*(g*y-d))/((a-g*x)*(e-h*y))))
      local v = (y-d*u-f+g*u*y)/(e-h*y)
      --local u = x*(e - (h*f)) + y*((c*h) - b) + ((b*f) - (c*e))
      --local v = x*((f*g) - d) + y*(a-(c*g)) + ((c*d) - (a*f))
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).r, newImg:at(y,x).g, newImg:at(y,x).b = interpolate.bilinear(img, u, v)        
      end
      
    end
  end
  

  return newImg
end
local function bilinear2( img, q )
  local width, height = img.width, img.height
  
  -- Find min and max for x' and y' coordinates
  local xMin, xMax, yMin, yMax = q[1].x, q[1].x, q[1].y, q[1].y
  for i =2, 4 do
    if q[i].x < xMin then xMin = q[i].x end
    if q[i].x > xMax then xMax = q[i].x end
    if q[i].y < yMin then yMin = q[i].y end
    if q[i].y > yMax then yMax = q[i].y end
  end
  -- find distance between x' and y' min and max
  local deltaX = xMax-xMin
  local deltaY = yMax-yMin
  
  -- create new image based on x' and y' size
  local newImg = image.flat(deltaY, deltaX ,0)
  
  -- calculate a - f
  local a,b,c,d,e,f
  
  
  
  -- since z' is 0 
  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      --local u = (x*((e*i)-(f*h)) + y*((f*g)-(d*i)) + ((d*h)-(e*g)))
      --local v = (x*((c*g)-(b*i)) + y*((a*i)-(c*g)) + ((b*g)-(a*h)))
      local u = ((x-c+xMin)/a)-((b*(y-f+yMin))/(e*a))-((1-(b*x))/e)
      local v = (y-(d*x)-f+yMin)/e
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(x,y).r, newImg:at(x,y).g, newImg:at(x,y).b = interpolate.bilinear(img, u, v)        
      end
      
    end
  end
  

  return newImg
end
function warp()
end
function swirl()
end
function waves(img)
  local height, width = img.height, img.width
  local newImg = img:clone()

  for r = 0, width - 1 do
    for c = 0, height - 1 do
      local x = r-20*math.sin(2*math.pi*c/128)
      if (x >=0 and x < width) then
        newImg:at(c,r).r, newImg:at(c,r).g, newImg:at(c,r).b = interpolate.bilinear(img, x, c)
      end
    end
  end
  return newImg
end

return {
  bilinear = bilinear,
  waves = waves,
}
