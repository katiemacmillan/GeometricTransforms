--[[
  * * * * warping.lua * * * *
  The file that contains all of the warping transformations and a wave transformation.
--]]
require "ip"
local color = require "il.color"
local image = require "image"
local interpolate = require "interpolate"
local helpers = require "helpers"

--[[
  Function Name: getPerspectiveDeltas
  
  Author: Katie MacMillan
  
  Description: getPerspectiveDeltas uses the forward perspective mapping to calculate the minimum
  and maximum x and y values in order to retrieve the delta x and y.
  
  Params: a - the x direction scale coefficient
          b - the x direction shear coefficient
          c - the x direction translation coefficient
          d - the y direction shear coefficient
          e - the y direction scale coefficient 
          f - the y direction translation coefficient
          g - the x direction perspective coefficient
          h - the y direction perspective coefficient
          width - the width of the reference image
          height - the height of the reference image
  
  Returns: delta x, delta y, x min and y min
--]]
local function getPerspectiveDeltas(a, b, c, d, e, f, g, h, width, height)
  -- tie point coordinates
  local u = {0, width, width, 0}
  local v = {0, 0, height, height}
  local x = {}
  local y = {}
  
  -- calculate x and y coordinates for reference tie points
  for i = 1, 4 do
    x[i] = (a*u[i] + b*v[i] + c)/(g*u[i] + h*v[i] + 1)
    y[i] = (d*u[i] + e*v[i] + f)/(g*u[i] + h*v[i] + 1)
  end

  -- default min and max to first coordinate set
  local xMin, xMax = x[1], x[1]
  local yMin, yMax = y[1], y[1]
  
  -- find acctual x and y min and max
  for i = 2, 4 do
    if x[i] < xMin then xMin = x[i] end
    if x[i] > xMax then xMax = x[i] end
    if y[i] < yMin then yMin = y[i] end
    if y[i] > yMax then yMax = y[i] end
  end
  
  -- round min and deltas
  xMin = math.floor(xMin + 0.5)
  yMin = math.floor(yMin + 0.5)
  local dX = math.floor(xMax - xMin + 1.5)
  local dY = math.floor(yMax - yMin + 1.5)
  
  return dX, dY, xMin, yMin
end

--[[
  Function Name: getPerspectiveCoefficients
  
  Author: Katie MacMillan
  
  Description: getPerspectiveCoefficients uses an array of user selectedpoints along
  with the reference image height and width to calculate the perspective transformation
  coefficients
  
  Params: q - array of user selected points
          width - width of image
          height - height of image
  
  Returns: a, b, c, d, e, f, g and h
--]]
local function getPerspectiveCoefficients(q, width, height)
  local a, b, c, d, e, f, g, h

  -- calculate h based on reference image dimentions and user points
  h =  (height*q[2].x*q[1].y-height*q[2].x*q[4].y+height*q[3].x*q[1].y-2*height*q[3].x*q[2].y+2*height*q[3].x*q[3].y-height*q[3].x*q[4].y-q[1].x*q[2].y+q[1].x*q[3].y+q[4].x*q[2].y-q[4].x*q[3].y)/(height*(height*q[2].x*q[3].y+height*q[2].x*q[4].y+height*q[3].x*q[2].y+height*q[3].x*q[4].y-q[4].x*q[2].y+q[4].x*q[3].y))
  
  
  -- calculate g based on h, user points and reference image dimentions
  g = (h*height*q[3].x-q[2].x+q[3].x)/(width*(q[3].x+q[2].x))-(h*height*q[4].x-q[1].x+q[4].x)/(height*width*(q[3].x+q[2].x))
  -- calculate remaining coefficients
  c = q[1].x
  f = q[1].y
  e = (q[4].y - q[1].y + h*height*q[4].y)/height
  b = (q[4].x - q[1].x + h*height*q[4].x)/height
  a = (q[2].x - q[1].x + g*width*q[2].x)/width
  d = (q[2].y - q[1].y + g*width*q[2].y)/width

  return a, b, c, d, e, f, g, h
end

--[[
  Function Name: getPerspectiveWarp
  
  Author: Katie MacMillan
  
  Description: getPerspectiveWarpUV utilizes the perspective transform coefficeints
  along with a given x,y position to computer the inverse perspective transform.
  This will generate a u,v position in the reference image, which is returned.
  
  Params: x - the x coordinate in the output image
          y - the y coordinate in the output image
          a - the x direction scale coefficient
          b - the x direction shear coefficient
          c - the x direction translation coefficient
          d - the y direction shear coefficient
          e - the y direction scale coefficient 
          f - the y direction translation coefficient
          g - the x direction perspective coefficient
          h - the y direction perspective coefficient 
  
  Returns: u and v
--]]
local function getPerspectiveWarpUV(x, y, a, b, c, d, e, f, g, h)
  local xp, yp, wp, u, v
  
  u = (((x-c)*(e-h*y))  + ((h*x - b)*(y-f)))/(((a-g*x)*(e-h*y)) - ((h*x - b)*(g*y - d)))
  v= (y - f + g*u*y - d*u)/(e - h*y)
  
  return u, v
end

--[[
  Function Name: getAffineCoefficients
  
  Author: Katie MacMillan
  
  Description: getAffineCoefficients uses an array of points and the image
  height and width to calculate the coefficients for the affine warp transform.
  
  Params: q - array of points
          width - width of image
          height - height of image
  
  Returns: a1, b1, d1, e1, a2, b2, d2, e2, c and f
--]]
local function getAffineCoefficients(q, width, height)
  local a1,b1,d1,e1,a2,b2,d2,e2,c,f
  
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
  
  return a1,b1,d1,e1,a2,b2,d2,e2,c,f
end

--[[
  Function Name: getAffineWarp
  
  Author: Katie MacMillan
  
  Description: getAffineWarpUV utilizes an inverted affine transform
  function to map an input x,y coordiante from the output image to
  a u,v coordinate in the referance image
  
  Params: x - the x coordinate in the output image
          y - the y coordinate in the output image
          a - the x direction scale coefficient
          b - the x direction shear coefficient
          c - the x direction translation coefficient
          d - the y direction shear coefficient
          e - the y direction scale coefficient 
          f - the y direction translation coefficient
  
  Returns: new u and v
--]]
local function getAffineWarpUV(x, y, a, b, c, d, e, f)
  local u, v  
  -- inverse matrix equations
  u = (x*e) - (y*b) + ((b*f) - (c*e))
  v = (-d*x) +(y*a) + ((c*d) - (f*a))

  -- divide by determinant
  u = u/(a*e - b*d)
  v = v/(a*e - b*d)

  return u, v
end

--[[
  Function Name: affineWarp
  
  Author: Katie MacMillan
  
  Description: affineWarp uses basic affine transform functions
  to allow a user to define an arbitrary quadrilateral to fit
  a referance image into. This function splits the referance
  image into two triangles which are then mapped to corresponding
  triangles in the user selected quadrilateral
  
  Params: img - image to warp
          q   - array of points
  
  Returns: the transformed image
--]]
local function affineWarp( img, q )
  local width, height = img.width, img.height
  
  -- find distance between x' and y' min and max
  local deltaX, deltaY = helpers.getDeltas(q)
  -- generate new image
  local newImg = image.flat(deltaX, deltaY, 240)
  
  -- calculate m and b for dividing triangle line
  local lineM = (q[3].y - q[1].y)/(q[3].x - q[1].x)
  local lineB =  q[3].y - (q[3].x*lineM)
  -- get coefficients
  local a1,b1,d1,e1,a2,b2,d2,e2,c,f = getAffineCoefficients(q, width, height)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v      
      -- displace coordinates for resulting image
      x, y = helpers.translateCoords(x, y, -deltaX, -deltaY)
      
      -- check for upper or lower triangle and apply coefficients
      if ((lineM * x)+lineB >= y) then
        u,v = getAffineWarpUV(x, y, a1, b1, c, d1, e1, f)
      else
        u,v = getAffineWarpUV(x, y, a2, b2, c, d2, e2, f)
      end
      
      -- translate origin to center
      u, v = helpers.translateCoords(u, v, width, height)      
      x, y = helpers.translateCoords(x, y, deltaX, deltaY)
      
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        -- get intensity
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end
    end
  end
  
  return newImg
end

--[[
  Function Name: affineTransform
  
  Author: Katie MacMillan
  
  Description: affineTransform allows the user to arbitrarily
  set transformation matrix variables and then performs the
  corresponding tranformation by translating the center of
  both the referance and output images to the origin, doing
  the transformations, and translating the image back to the
  original position.
  
  Params: img - the original reference image
          a - the x direction scale coefficient
          b - the x direction shear coefficient
          c - the x direction translation coefficient
          d - the y direction shear coefficient
          e - the y direction scale coefficient 
          f - the y direction translation coefficient
  
  Returns: the transformed image
--]]
local function affineTransform( img, a, b, c, d, e, f )

  local width, height = img.width, img.height
  -- calculate output image dimentions based on tie points
  local deltaX = (a*img.width) + (b*img.height) + c
  local deltaY = (d*img.width) + (e*img.height) + f

  -- create new image based on x' and y' size
  local newImg = image.flat(deltaX, deltaY, 240)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      -- move output image center to origin
      helpers.translateCoords(x, y, -deltaX, -deltaY)

      u, v = getAffineWarpUV(x, y, a, b, c, d, e, f)
      
      -- center origin
      helpers.translateCoords(u, v, width,height)
      -- translate back in result image
      helpers.translateCoords(x, y, deltaX, deltaY)
      
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end
    end
  end

  return newImg
end

--[[
  Function Name: perspective
  
  Author: Katie MacMillan
  
  Description: perspective allows the user to warp an image by
  altering the perspective it is viewed at. Image corners that are
  stretched away from the image center are warped to appear farther
  away from the user, causing a tilting effect in the image.
  
  Params: img - the original image
          q   - an array of user selected image translation points

  
  Returns: the transformed image
--]]
function perspective(img, q)
  local width, height = img.width, img.height
  -- calculate transform coefficients
  local a, b, c, d, e, f, g, h = getPerspectiveCoefficients(q, width, height)
  -- get new image dimentions
  local deltaX,deltaY, xMin, yMin = getPerspectiveDeltas(a, b, c, d, e, f, g, h, width, height)
  --create new image
  local newImg = image.flat(deltaX, deltaY, 240)

  for x = 0, deltaX-1 do
    for y = 0, deltaY-1 do
      local u,v
      u,v = getPerspectiveWarpUV(x, y, a, b, c, d, e, f, g, h)
      
      if (math.floor(u) >= 0 and math.floor(v) >= 0 and math.ceil(u) < width and math.ceil(v) < height) then
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, v)}
      end
    end
  end
  
  return newImg
end

--[[
  Function Name: waves
  
  Author: Katie MacMillan
  
  Description: waves uses an inverse mapping of a wave function
  to warp an image giving it a sinusoidal shape
  
  Params: img - the original image
  
  Returns: the distorted image

--]]
function waves(img)
  local height, width = img.height, img.width
  local newImg = img:clone()

  for x = 0, width - 1 do
    for y = 0, height - 1 do
      -- calculate u displacement (v does not change)
      local u = x-20*math.sin(2*math.pi*y/128)

      if (math.floor(u) >=0 and math.ceil(u) < width) then
        -- set pixel color
        newImg:at(y,x).rgb = {interpolate.bilinear(img, u, y)}
      else
        -- set pixel to background color
        newImg:at(y,x).rgb = {240, 240, 240}
      end
    end
  end

  return newImg
end

return {
  affineTransform = affineTransform,
  perspective = perspective,
  affineWarp = affineWarp,
  waves = waves,
}