require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"
local function scale( img, rows, cols )
  local scaleX, scaleY
  scaleX = cols/img.width
  scaleY = rows/img.height
  local height, width = img.height, img.width
  local newImg = image.flat(cols,rows,0)

  for r = 0, rows - 2 do
    for c = 0, cols - 2 do
      newImg:at(c,r).r, newImg:at(c,r).g, newImg:at(c,r).b = interpolate.bilinear(img, c/scaleX, r/scaleY)
    end
  end
  return newImg
end
local function rotate( img, deg )
end
local function warp( img, x, y )
end

return {
  scale = scale,
  rotate = rotate,
  warp = warp,
}
