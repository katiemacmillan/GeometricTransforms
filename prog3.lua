--[[

  * * * * prog3.lua * * * *

Lua Geometric Transforms Demo: Affine transforms, warping, and interpolation
techniques were implemented to show the class.

Authors: Katie MacMillan and Forrest Miller
Class: CSC442/542 Digital Image Processing
Date: 4/24/2017

--]]

-- LuaIP image processing routines
require "ip"   -- this loads the packed distributable
local viz = require "visual"
local il = require "il"
local transforms = require "transforms"
local warps = require "warping"
-- for k,v in pairs( il ) do io.write( k .. "\n" ) end

-- load images listed on command line
local imgs = {...}
for i, fname in ipairs( imgs ) do loadImage( fname ) end

-----------
-- menus --
-----------

local cmarg1 = {name = "color model", type = "string", displaytype = "combo", choices = {"rgb", "yiq", "ihs"}, default = "rgb"}
local cmarg2 = {name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}
local cmarg3 = {name = "interpolation", type = "string", displaytype = "combo", choices = {"nearest neighbor", "bilinear"}, default = "bilinear"}
local function pointSelector( img, pt )
  print(pt)
  --local rgb = img:at( pt.y, pt.x )
  --io.write( ( "point: (%d,%d) = (%d,%d,%d)\n" ):format( pt.x, pt.y, rgb.r, rgb.g, rgb.b ) );
  return img
end

imageMenu("Weiss",
  {
    {"Resize", transforms.scale,
      {{name = "rows", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384},
       {name = "cols", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384}, cmarg3}},
    {"My Rotate", transforms.rotate, {{name = "deg", type = "number", displaytype = "slider", default = 0, min = -360, max = 360}, cmarg3}},
   {"Rotate", il.rotate,
      {{name = "theta", type = "number", displaytype = "slider", default = 0, min = -360, max = 360}, cmarg3}},
   {"Wave", warps.waves},
   {"Perspective Warp", warps.perspective, {{name="quad", type = "quad", default = {{0, 0}, {100, 0}, {100, 100}, {0, 100}}}}},
   {"Bilinear Warp", warps.bilinear, {{name="quad", type = "quad", default = {{0, 0}, {100, 0}, {100, 100}, {0, 100}}}}},
   {"Affine Warp", warps.affineWarp, {{name="quad", type = "quad", default = {{0, 0}, {100, 0}, {100, 100}, {0, 100}}}}},
   {"Affine Transforms", warps.affineTransform, {
       {name="a11", type = "number", default = 1, min = -1000, max = 1000},
       {name="a21", type = "number", default = 0, min = -1000, max = 1000},
       {name="a31", type = "number", default = 0, min = -1000, max = 1000},
       {name="a12", type = "number", default = 0, min = -1000, max = 1000},
       {name="a22", type = "number", default = 1, min = -1000, max = 1000},
       {name="a23", type = "number", default = 0, min = -1000, max = 1000},
       }},
    
  }
)

-- help menu
imageMenu("Help",
  {
    {"Help", viz.imageMessage("Help", "Under the File menu a user can open a new image, save the current image or exit the program.\n\nBy right clicking on the image tab, the user can duplicate or reload the image. The user may also press Ctrl+D to duplicate an image or Crtl+R to reload it.\n\nThere are multiple menus from which to choose. You are able to do some preprocessing with a few point processes. Then edge detectors and other neighborhood processes which have been implemented may be run.\n\nThe user can also add noise to better show the effect of the noise cleaning filters.")},
    {"About", viz.imageMessage("Lua Geometric Transforms" .. viz.VERSION, "Authors: Forrest Miller and Katie MacMillan\nClass: CSC442 Digital Image Processing\nDate: April 24th, 2017")},
  }
)

start()