require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function bilinear( img, q )
  local width, height = img.width, img.height
  local newImg = image.flat(width, height ,0)
  local a,b,c,d,e,f,g,h
  a = (q[2].x - q[1].x)/width
  b = (q[4].x - q[1].x)/height
  c = q[1].x
  d = (q[2].y - q[1].y)/width
  e = (q[4].y - q[1].y)/height
  f = q[1].y
  g = 0
  h = 0
  i = 1
  
  for r = 0, img.width-1 do
    for c = 0, img.height-1 do
      local x = ((e*i)-(f*h))*r + ((f*g)-(d*i))*c
      local y = ((c*h)-(b*i))*r + ((a*i)-(c*g))*c
      
      if (math.floor(x) >= 0 or math.floor(y) >= 0) then
        newImg:at(r,c).r, newImg:at(r,c).g, newImg:at(r,c).b = interpolate.bilinear(img, x, y)        
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

  for r = 0, height - 1 do
    for c = 0, width - 1 do
      local x = r-20*math.sin(2*math.pi*c/128)
      newImg:at(r,c).r, newImg:at(r,c).g, newImg:at(r,c).b = interpolate.neighbor(img, x, c)
    end
  end
  
  return newImg
end

return {
  bilinear = bilinear,
  waves = waves,
}