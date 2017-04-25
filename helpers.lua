--[[
  * * * * helpers.lua * * * *
  A helper file that seperates the translate and delta functions into their own file.
--]]

--[[
  Function Name: getDeltas
  
  Author: Katie MacMillan
  
  Description: getDeltas finds the difference between the min and max x's and y's
  
  Params: q - set of 4 coordinates user specifies
  
  Returns: deltas of x and y
--]]
local function getDeltas (q)
  local xMin, xMax, yMin, yMax = q[1].x, q[2].x, q[1].y, q[4].y
  
  if q[4].x < xMin then xMin = q[4].x end
  if q[3].x > xMax then xMax = q[3].x end
  if q[2].y < yMin then yMin = q[2].y end
  if q[3].y > yMax then yMax = q[3].y end
  
  return math.floor(xMax - xMin + 1.5), math.floor(yMax - yMin + 1.5), math.floor(xMin+0.5), math.floor(yMin+0.5)
end

--[[
  Function Name: translateCoords
  
  Author: Katie MacMillan
  
  Description: translateCoords translates the current x and y by half of the
  image height and width
  
  Params: x      - the current x location
          y      - the current y location
          width  - the width of the image
          height - the height of the image
  
  Returns: the new x and y values
--]]
local function translateCoords (x, y, width, height)
  return x+(width/2), y+(height/2)
end

--[[
  Function Name: findNewSize
  
  Author: Forrest Miller
  
  Description: findNewSize uses the existing height and width and the degree
  that the user wants to rotate by and calculates the new image height and width.
  
  Params: h   - the current image height
          w   - the current image width
          deg - the degree we are rotating by
  
  Returns: the new height and width
--]]
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

return {
  getDeltas = getDeltas,
  translateCoords = translateCoords,
  findNewSize = findNewSize
}