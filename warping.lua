require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"

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
  waves = waves,
}
