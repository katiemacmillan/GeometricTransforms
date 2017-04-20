require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function affineWarp( img, q )
  local width, height = img.width, img.height

  -- Find min and max for x' and y' coordinates
  local xMin, xMax, yMin, yMax = q[1].x, q[2].x, q[1].y, q[4].y
  if q[4].x < xMin then xMin = q[4].x end
  if q[3].x > xMax then xMax = q[3].x end
  if q[2].y < yMin then yMin = q[2].y end
  if q[3].y > yMax then yMax = q[3].y end

  -- find distance between x' and y' min and max
  local deltaX = xMax-xMin
  local deltaY = yMax-yMin

  -- calculate m and b
  local lineM = (q[3].y - q[1].y)/(q[3].x - q[1].x)
  local lineB =  q[3].y - (q[3].x*lineM)

  -- generate new image
  local newImg = image.flat(deltaX, deltaY, 0)

  local a,b,c,d,e,f
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


  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      -- displace coordinates for resulting image
      x = x-(deltaX/2)
      y = y-(deltaY/2)

      -- check for upper or lower triangle and apply coefficients
      if ((lineM * x)+lineB >= y) then
        u = (x*e1) - (y*b1) + ((b1*f) - (c*e1))
        v = (-d1*x) +(y*a1) + ((c*d1) - (f*a1))
        u = u/(a1*e1 - b1*d1)
        v = v/(a1*e1 - b1*d1)
      else

        u = (x*e2) - (y*b2) + ((b2*f) - (c*e2))
        v = (-d2*x) +(y*a2) + ((c*d2) - (f*a2))
        u = u/(a2*e2 - b2*d2)
        v = v/(a2*e2 - b2*d2)
      end
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
local function bilinear( img, q )
end
function perspective(img, q)
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
  affineTransform = affineTransform,
  perspective = perspective,
  affineWarp = affineWarp,
  waves = waves,
}
