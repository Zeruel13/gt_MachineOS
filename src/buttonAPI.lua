local API = {}
button = {}
 
local component = require("component")
local gpu = component.gpu
local event = require("event")

function API.setTable(name, func, xmin, ymin, xmax, ymax, text, textColor, backgroundColor) -- color is an object { on : 0x000000, off 0xAAAAAA}
  button[name] = {}
  button[name]["text"] = text
  button[name]["func"] = func
  button[name]["active"] = false
  button[name]["xmin"] = xmin
  button[name]["ymin"] = ymin
  button[name]["xmax"] = xmax
  button[name]["ymax"] = ymax
  button[name]["textColor"] = textColor
  button[name]["backgroundColor"] = backgroundColor
end
 
function API.fill(bData)
 
  local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
  local xspot = math.floor((bData["xmin"] + bData["xmax"]) /2) - math.floor((string.len(bData["text"])/2))
  local oldBackgroundColor = gpu.getBackground()
  local oldTextColor = gpu.getForeground()
  local curBackgroundColor = bData["backgroundColor"].on
 
  if bData["active"] then
    curBackgroundColor = bData["backgroundColor"].off
  end
  gpu.setBackground(curBackgroundColor)
  gpu.setForeground(bData["textColor"])
  gpu.fill(bData["xmin"], bData["ymin"], bData["xmax"] - bData["xmin"] + 1, bData["ymax"] - bData["ymin"] + 1, " ")
  gpu.set(xspot, yspot, bData["text"])
  gpu.setBackground(oldBackgroundColor)
  gpu.setForeground(oldTextColor)
end
 
function API.screen()
  for name,data in pairs(button) do
     API.fill(data)
  end
end

--[[function API.toggleButton(name)
  button[name]["active"] = not button[name]["active"]
  buttonStatus = button[name]["active"]
  API.screen()
end     

function API.flash(name,length)
  API.toggleButton(name)
  API.screen()
  os.sleep(length)
  API.toggleButton(name)
  API.screen()
end]]
 
function API.checkxy(_, _, x, y, _, _)
  for name, data in pairs(button) do
    if y >= data["ymin"] and y <= data["ymax"] then
      if x >= data["xmin"] and x <= data["xmax"] then
		data["func"](data["text"])
        --data["func"]()
		--data["active"] = true
      end
    end
  end
end
 
return API