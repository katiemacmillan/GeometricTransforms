require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"
local helpers = require "helpers"

local function scale( img, rows, cols, interp )
  local scaleX, scaleY

  scaleX = rows/img.width
  scaleY = cols/img.height

  local height, width = img.height, img.width
  local newImg = image.flat(rows, cols , 240)

  for x = 0, rows - 1 do
    for y = 0, cols - 1 do
      if interp == "nearest neighbor" then
        newImg:at(y,x).rgb = {interpolate.neighbor(img, x/scaleX, y/scaleY)}
      else
        newImg:at(y,x).rgb = {interpolate.bilinear(img, x/scaleX, y/scaleY)}
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
  local newImg = image.flat(cols, rows, 240)
  local x, y

  for x = 0, rows - 1 do
    for y = 0, cols - 1 do
      x, y = helpers.translateCoords(x, y, -rows, -cols)
      u = math.sin(rad)*y + math.cos(rad)*x
      v = math.cos(rad)*y - math.sin(rad)*x
      u, v = helpers.translateCoords(u, v, rows, cols)
      x, y = helpers.translateCoords(x, y, rows, cols)
      if u >= 0 and u < img.width and v >= 0 and v < img.height then
        if interp == "nearest neighbor" then
          newImg:at(y,x).rgb = {interpolate.neighbor(img, u, v)}
        else
          newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
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