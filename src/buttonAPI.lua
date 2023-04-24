local API = {}
button = {}
 
local component = require("component")
local gpu = component.gpu
local event = require("event")

function API.setTable(name, func, xmin, ymin, xmax, ymax, text, textColor, backgroundColor, isEnabled)
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
  button[name]["isEnabled"] = isEnabled or true
end
 
function API.fill(bData)

	-- If a button is not enabled, nothing should be done for that button
	if not bData["isEnabled"] then
		return
	end

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


function API.screen(buttonName)
  if buttonName then
	-- When API.screen is called with a specific buttonName as an argument, it updates only the button with the given name. 
    API.fill(button[buttonName]) 
  else
	-- When API.screen is called with no argument, it updates all of the buttons on the screen. 
    for name,data in pairs(button) do
      API.fill(data)
    end
  end
end

function API.printButtons()
	for name, data in pairs(button) do
		print(name)
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

function API.waitForButtonPress(buttonName)
  while true do
    local _, _, x, y = event.pull("touch")
    for name, data in pairs(button) do
      if x >= data["xmin"] and x <= data["xmax"] and y >= data["ymin"] and y <= data["ymax"] then 
        if name == buttonName then
          data["func"](data["text"])
          -- register checkxy again
          event.listen("touch", API.checkxy)
          return -- exit the function when the expected button is pressed
        end
      end
    end
  end
end
 
function API.checkxy(_, _, x, y, _, _)
  for name, data in pairs(button) do
    if data.isEnabled and y >= data["ymin"] and y <= data["ymax"] then
      if x >= data["xmin"] and x <= data["xmax"] then
        data["func"](data["text"])
      end
    end
  end
end


 --data["func"]()
 --data["active"] = true
 
return API
