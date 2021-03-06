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
-----------
-- menus --
-----------

local cmarg1 = {name = "color model", type = "string", displaytype = "combo", choices = {"rgb", "yiq", "ihs"}, default = "rgb"}
local cmarg2 = {name = "color model", type = "string", displaytype = "combo", choices = {"yiq", "yuv", "ihs"}, default = "yiq"}
local cmarg3 = {name = "interpolation", type = "string", displaytype = "combo", choices = {"nearest neighbor", "bilinear"}, default = "bilinear"}

imageMenu("Geometric Tranforms",
  {
    {"Resize", transforms.scale,
      {{name = "cols", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384},
       {name = "rows", type = "number", displaytype = "spin", default = 1024, min = 1, max = 16384}, cmarg3}},
    {"Rotate", transforms.rotate,
      {{name = "deg", type = "number", displaytype = "slider", default = 0, min = -360, max = 360}, cmarg3}},
    {"Wave", warps.waves},
    {"Perspective Warp", warps.perspective, {{name="quad", type = "quad", default = {{0, 0}, {100, 0}, {100, 100}, {0, 100}}}}},
    {"Affine Warp", warps.affineWarp, {{name="quad", type = "quad", default = {{0, 0}, {100, 0}, {100, 100}, {0, 100}}}}},
    {"Affine Transforms", warps.affineTransform, {
      {name="       x scale", type = "number", default = 1, min = -1000, max = 1000},
      {name="       x shear", type = "number", default = 0, min = -1000, max = 1000},
      {name=" x translation", type = "number", default = 0, min = -1000, max = 1000},
      {name="       y shear", type = "number", default = 0, min = -1000, max = 1000},
      {name="       y scale", type = "number", default = 1, min = -1000, max = 1000},
      {name=" y translation", type = "number", default = 0, min = -1000, max = 1000},
    }},
  }
)

-- help menu
imageMenu("Help",
  {
    {"Help", viz.imageMessage("Help", "Under the File menu a user can open a new image, save the current image or exit the program.\n\nBy right clicking on the image tab, the user can duplicate or reload the image. The user may also press Ctrl+D to duplicate an image or Crtl+R to reload it.\n\nThere is a Geometric Transforms menu that holds all the functions developed for this demo.")},
    {"About", viz.imageMessage("Lua Geometric Transforms" .. viz.VERSION, "Authors: Forrest Miller and Katie MacMillan\nClass: CSC442 Digital Image Processing\nDate: April 24th, 2017")},
  }
)

start()