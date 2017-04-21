require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function getDeltas (q)
  local xMin, xMax, yMin, yMax = q[1].x, q[2].x, q[1].y, q[4].y
  if q[4].x < xMin then xMin = q[4].x end
  if q[3].x > xMax then xMax = q[3].x end
  if q[2].y < yMin then yMin = q[2].y end
  if q[3].y > yMax then yMax = q[3].y end
  return xMax - xMin, yMax - yMin
end
local function translateCoords (x, y, width, height)
  return x+(width/2), y+(height/2)
end

local function getPerspectiveCoefficients(q, width, height)
  local a,b,c,d,e,f,g,h

  h = (-1/4*width)*(((q[1].x - q[2].x - q[4].x)/q[3].x)+((q[1].y - q[2].y - q[4].y)/q[3].y) - 2)
  g = (q[3].y - q[1].y + h*height*q[3].y)/height
  a = (q[2].x - q[1].x + g*width*q[2].x)/width
  b = (q[4].x - q[1].x + h*height*q[4].x)/height
  c = q[1].x
  a = (q[2].y - q[1].y + g*width*q[2].y)/width
  b = (q[4].y - q[1].y + h*height*q[4].y)/height
  c = q[1].y

  return a,b,c,d,e,f,g,h
end

local function getAffineCoefficients(q, width, height)
  local a1,b1,d1,e1,a2,b2,d2,e2,c,f
  -- coefficients for upper triangle
  a1 = (q[2].x-q[1].x)/width
  b1 = (q[3].x-q[2].x)/height
  d1 = (q[2].y-q[1].y)/width
  e1 = (q[3].y-q[2].y)/height

  -- coefficients for lower triangle
  a2 = (q[3].x-q[4].x)/width
  b2 = (q[4].x-q[1].x)/height
  d2 = (q[3].y-q[4].y)/width
  e2 = (q[4].y-q[1].y)/height

  c = q[1].x
  f = q[1].y
  return a1,b1,d1,e1,a2,b2,d2,e2,c,f
end

local function getAffineWarpUV(x, y, a, b, c, d, e, f)
  local u, v
  u = (x*e) - (y*b) + ((b*f) - (c*e))
  v = (-d*x) +(y*a) + ((c*d) - (f*a))
  u = u/(a*e - b*d)
  v = v/(a*e - b*d)
  return u, v
end

local function affineWarp( img, q )
  local width, height = img.width, img.height
  -- find distance between x' and y' min and max
  local deltaX, deltaY = getDeltas(q)
  -- generate new image
  local newImg = image.flat(deltaX, deltaY, 0)
  -- calculate m and b
  local lineM = (q[3].y - q[1].y)/(q[3].x - q[1].x)
  local lineB =  q[3].y - (q[3].x*lineM)
  local a1,b1,d1,e1,a2,b2,d2,e2,c,f = getAffineCoefficients(q, width, height)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      -- displace coordinates for resulting image
      x, y = translateCoords(x, y, -deltaX, -deltaY)
      -- check for upper or lower triangle and apply coefficients
      if ((lineM * x)+lineB >= y) then
        u,v = getAffineWarpUV(x, y, a1, b1, c, d1, e1, f)
      else
        u,v = getAffineWarpUV(x, y, a2, b2, c, d2, e2, f)
      end
      -- translate origin to center
      u, v = translateCoords(u, v, width, height)
      -- translate back in result image
      x, y = translateCoords(x, y, deltaX, deltaY)
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end
    end
  end
  return newImg
end
local function affineTransform( img, a, b, c, d, e, f )

  local width, height = img.width, img.height
  local px = 0-(width/2)
  local py = 0-(height/2)

  local pu = (0/e) - (0*b) + ((b*f) - (c/e))
  local pv = (-d*0) +(0/a) + ((c*d) - (f/a))
  pu = pu + (width/2)
  pv = pv + (height/2)

  local deltaX = (a*img.width) + (b*img.height) + c
  local deltaY = (d*img.width) + (e*img.height) + f

  -- create new image based on x' and y' size
  local newImg = image.flat(deltaX, deltaY ,0)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      x = x-(deltaX/2)
      y = y-(deltaY/2)

      -- inverse transform matrix multiply
      u = (x*e) - (y*b) + ((b*f) - (c*e))
      v = (-d*x) +(y*a) + ((c*d) - (f*a))

      -- divide by determinant
      u = u/(a*e - b*d)
      v = v/(a*e - b*d)
      -- center origin
      u = u + (width/2)
      v = v + (height/2)

      -- translate back in result image
      x = x+(deltaX/2)
      y = y+(deltaY/2)
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end
    end
  end


  return newImg
end

function perspective(img, q)
  local width, height = img.width, img.height
  local deltaX, deltaY = getDeltas(q)
  local newImg = image.flat(deltaX, deltaY, 0)
  local a,b,c,d,e,f,g,h = getPerspectiveCoefficients(q, width, height)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      -- displace coordinates for resulting image
      x = x-(deltaX/2)
      y = y-(deltaY/2)

      -- translate origin to center
      u = u + (width/2)
      v = v + (height/2)

      -- translate back in result image
      x = x+(deltaX/2)
      y = y+(deltaY/2)
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end

    end
  end

  return newImg
end

function waves(img)
  local height, width = img.height, img.width
  local newImg = img:clone()

  for x = 0, width - 1 do
    for y = 0, height - 1 do
      local u = x-20*math.sin(2*math.pi*y/128)

      if (math.floor(u) >=0 and math.ceil(u) < width) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, y)}
      else
        newImg:at(y,x).rgb = {240, 240, 240}
      end

    end
  end

  return newImg
end

return {
  affineTransform = affineTransform,
  perspective = perspective,
  affineWarp = affineWarp,
  waves = waves,
}