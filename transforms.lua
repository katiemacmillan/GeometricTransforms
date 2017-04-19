require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function scale( img, rows, cols, interp )
  local scaleX, scaleY
  
  scaleX = rows/img.width
  scaleY = cols/img.height
  
  local height, width = img.height, img.width
  local newImg = image.flat(cols, rows ,0)

  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      if interp == "nearest neighbor" then
        newImg:at(c,r).r, newImg:at(c,r).g, newImg:at(c,r).b = interpolate.neighbor(img, r/scaleX, c/scaleY)
      else
        newImg:at(c,r).r, newImg:at(c,r).g, newImg:at(c,r).b = interpolate.bilinear(img, r/scaleX, c/scaleY)
      end
    end
  end
  
  return newImg
end

local function findNewSize(h, w, deg)
  local newH, newW
  local rad = deg * (math.pi / 180)
  local rad2 = (deg - 90) * (math.pi /180)
  
  if deg < 90 then
    newW = (w * math.cos(rad)) + (h * math.sin(rad))
    newH = (w * math.sin(rad)) +(h * math.cos(rad))
  elseif deg > 90 then
    newW = (h * math.cos(rad2)) + (w * math.sin(rad2))
    newH = (h * math.sin(rad2)) + (w * math.cos(rad2))
  else
    newW = h
    newH = w
  end
  
  return math.ceil(newH), math.ceil(newW)
end

local function rotate( img, deg, interp )
  local rad = deg * (math.pi / 180)
  local rows, cols = findNewSize(img.height, img.width, deg)  
  local newImg = image.flat(cols, rows, 0)
  local x, y
  
  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      --set the fill to the background color
      newImg:at(r,c).r =  240
      newImg:at(r,c).g =  240
      newImg:at(r,c).b =  240
    end
  end
  
  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      x = math.sin(rad)*r + math.cos(rad)*c
      y = math.cos(rad)*r - math.sin(rad)*c
            
      if x >= 0 and x < img.width and y >= 0 and y < img.height then
      if interp == "nearest neighbor" then
        --does not work properly at all
        newImg:at(r,c).r, newImg:at(r,c).g, newImg:at(r,c).b = interpolate.neighbor(img, x, y)
      else
        newImg:at(r,c).r, newImg:at(r,c).g, newImg:at(r,c).b = interpolate.bilinear(img, x, y)
      end
      end
    end
  end
  
  return newImg
end

local function warp( img, x, y )
end

return {
  scale = scale,
  rotate = rotate,
  warp = warp,
}