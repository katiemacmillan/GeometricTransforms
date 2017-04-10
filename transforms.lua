require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

local function scale( img, rows, cols )
  local scaleX, scaleY
  scaleX = rows/img.width
  scaleY = cols/img.height
  print("Rows: " .. rows .."     Cols:  " .. cols)
  print("yScale " .. scaleY .."     xScale:  " .. scaleX)
  local height, width = img.height, img.width
  local newImg = image.flat(cols, rows ,0)

  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      newImg:at(r,c).r, newImg:at(r,c).g, newImg:at(r,c).b = interpolate.neighbor(img, r/scaleX, c/scaleY)
    end
  end
  return newImg
end

local function rotate( img, deg )
  local rad = deg * (math.pi / 180)
  local rows = img.height --calculate with degree?
  local cols = img.width -- calculate with degree?
  local newImg = image.flat(cols, rows, 0)
  local newX, newY
  
  for r = 0, rows - 1 do
    for c = 0, cols - 1 do
      --set the fill to the background color
      newImg:at(c,r).r =  240
      newImg:at(c,r).g =  240
      newImg:at(c,r).b =  240
    end
  end
  
  for r = 0, rows - 1 do
    for c = 0, cols -1 do
      newX = math.cos(rad)*c - math.sin(rad)*r
      newY = math.sin(rad)*c + math.cos(rad)*r
      
      --newImg:at(c,r).r, newImg:at(c,r).g, newImg:at(c,r).b = interpolate.bilinear(img, newX, newY)
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
