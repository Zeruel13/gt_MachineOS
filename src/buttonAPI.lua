local API = {}
button = {}
 
local component = require("component")
local gpu = component.gpu
local event = require("event")

function API.setTable(name, func, xmin, ymin, xmax, ymax, text, colors) -- color is an object { on : 0x000000, off 0xAAAAAA}
  button[name] = {}
  button[name]["text"] = text
  button[name]["func"] = func
  button[name]["active"] = false
  button[name]["xmin"] = xmin
  button[name]["ymin"] = ymin
  button[name]["xmax"] = xmax
  button[name]["ymax"] = ymax
  button[name]["colors"] = colors
end
 
function API.fill(bData)
 
  local yspot = math.floor((bData["ymin"] + bData["ymax"]) /2)
  local xspot = math.floor((bData["xmin"] + bData["xmax"]) /2) - math.floor((string.len(bData["text"])/2))
  local oldColor = gpu.getBackground()
  local curColor = bData["colors"].on
 
  if bData["active"] then
    curColor = bData["colors"].off
  end
  gpu.setBackground(curColor)
  gpu.fill(bData["xmin"], bData["ymin"], bData["xmax"] - bData["xmin"] + 1, bData["ymax"] - bData["ymin"] + 1, " ")
  gpu.set(xspot, yspot, bData["text"])
  gpu.setBackground(oldColor)
end
 
function API.screen()
  for name,data in pairs(button) do
     API.fill(data)
  end
end
function API.toggleButton(name)
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
end
 
function API.checkxy(_, _, x, y, _, _)
	--[[local outputFile = io.open("output.txt", "w") -- open a file for writing, or create it if it doesn't exist
	outputFile:write("x value: "..x,"   y value: "..y) -- write to the file
	outputFile:close() -- close the file to save the changes]]
  for name, data in pairs(button) do
    if y >= data["ymin"] and y <= data["ymax"] then
      if x >= data["xmin"] and x <= data["xmax"] then
		data["func"](data["text"])
        data["func"]()
		data["active"] = true
        return true
      end
    end
  end
  return false
end
 
return API