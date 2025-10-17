------------------------------------------------------------------------
---This library contains a few functions that we're gonna use in several 
---parts of this template.
---We use various functions throughout our games and apps to speed up
---the most common practices. 
---Each template only contains a handful of these (the one useful to it)
---but we're planning on a release that will contain all our functions
---revised and polished up.
---Made by Ragdog Studios SRL in 2013 http://www.ragdogstudios.com
------------------------------------------------------------------------

local app5iveLib = {};

app5iveLib.getSaveValue = function(key)
  if not app5iveLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      app5iveLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  app5iveLib.saveTable = app5iveLib.saveTable or {};
  return app5iveLib.saveTable[key];
end

app5iveLib.setSaveValue = function(key, value, operateSave)
print( "setting saved value")
  if not app5iveLib.saveTable then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "r");
    if file then
      local json = require "json";
      app5iveLib.saveTable = json.decode(file:read("*a"));
      io.close(file);
    end
  end
  app5iveLib.saveTable = app5iveLib.saveTable or {};
  app5iveLib.saveTable[key] = value;
  if operateSave then
    local path = system.pathForFile("savedData.json", system.DocumentsDirectory);
    local file = io.open(path, "w+");
    local json = require "json";
    file:write(json.encode(app5iveLib.saveTable));
    io.close(file);
  end
  return app5iveLib.saveTable[key];
end

app5iveLib.newSimpleButton = function(group, img, width, height)
  local button = display.newImageRect(group or display.getCurrentStage(), img, width, height);
  function button:touch(event)
    if event.phase == "began" then
      display.getCurrentStage():setFocus(self);
      self.isFocus = true;
      if self.touchBegan then
        self:touchBegan();
      end
      return true;
    elseif event.phase == "moved" and self.isFocus then
      local bounds = self.contentBounds;
      if event.x > bounds.xMax or event.x < bounds.xMin or event.y > bounds.yMax or event.y < bounds.yMin then
        self.isFocus = false;
        display.getCurrentStage():setFocus(nil);
        if self.touchEnded then
          self:touchEnded();
        end
      end
      return true;
    elseif event.phase == "ended" and self.isFocus then
      self.isFocus = false;
      display.getCurrentStage():setFocus(nil);
      if self.touchEnded then
        self:touchEnded();
      end
      return true;
    end
  end
  button:addEventListener("touch", button);
  
  return button;
end

app5iveLib.convertRGB = function(r, g, b)
   assert(r and g and b and r <= 255 and r >= 0 and g <= 255 and g >= 0 and b <= 255 and b >= 0, "You must pass all 3 RGB values within a range of 0-255");
   return r/255, g/255, b/255;
end

app5iveLib.convertHexToRGB = function(hexCode)
   assert(#hexCode == 7, "The hex value must be passed in the form of #XXXXXX");
   local hexCode = hexCode:gsub("#","")
   return tonumber("0x"..hexCode:sub(1,2))/255,tonumber("0x"..hexCode:sub(3,4))/255,tonumber("0x"..hexCode:sub(5,6))/255;
end

return app5iveLib;