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
return {
  getDeltas = getDeltas,
  translateCoords = translateCoords
}