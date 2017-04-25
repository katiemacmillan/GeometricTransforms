--[[
  * * * * transforms.lua * * * *
  The class that holds the main transform functions: scale and rotate.
--]]
require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"
local helpers = require "helpers"

--[[
  Function Name: scale
  
  Author: Katie MacMillan
  
  Description: scale takes an initial image and resizes it to a specified height
  and width with a given interpolation.
  
  Params: img    - initial image
          rows   - new height
          cols   - new width
          interp - type of interpolation the user wants to use
  
  Returns: new scaled image
--]]
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

--[[
  Function Name: rotate
  
  Author: Forrest Miller
  
  Description: rotate takes an image and rotates it by a specified degree using
  the interpolation specified.
  
  Params: img    - initial image
          deg    - degree the user wants to rotate
          interp - type of interpolation the user wants to use
  
  Returns: new image
--]]
local function rotate( img, deg, interp )
  local rad = deg * (math.pi / 180)
  local rows, cols = helpers.findNewSize(img.height, img.width, deg)  
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

return {
  scale = scale,
  rotate = rotate,
}