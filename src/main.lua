--gt_machineOS created by: Zeruel
--Ver 1.0

--Border code originally by Krakaen to use in 'OPENCOMPUTER AUTOMATION PROGRAM'
--buttonAPI ported to OC by MoparDan originally created by DireWolf 20 for ComputerCraft

--components to require
local component = require("component")
local event = require("event")
local gpu = component.gpu

--require the buttonAPI module from buttonAPI.lua
API = require("buttonAPI")

--load the files that store machines / tank addresses
local machines_chunk = loadfile("addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("addressList/tanks.lua")
local tanks = tanks_chunk()
local pinnedMachines_chunk = loadfile("addressList/pinnedMachines.lua")
local pinnedMachines = pinnedMachines_chunk()
local energy_chunk = loadfile("addressList/energy.lua")
local energy = energy_chunk()
local energyFiles = require("energyFiles")

--initializes some colors to use 
local colors = {
	blue = 0x0047AB,
	purple = 0x884EA0,
	red = 0xC14141,
	green = 0xDA841,
	black = 0x000000,
	white = 0xFFFFFF,
	orange = 0xF28C28,
	yellow = 0xFFBF00,
	lightGreen = 0x90EE90,
	cyan = 0x00FFFF,
	turq = 0x008B8B
}

--function to print colored text	
function printColoredText(x, y, text, color)
  local oldColor = gpu.getForeground()
  gpu.setForeground(color)
  gpu.set(x, y, text)
  gpu.setForeground(oldColor)
end

--function to set background colors
function setBackgroundColor(x, y, width, height, text, color)
	local oldBackground = gpu.getBackground()
	gpu.setBackground(color)
	gpu.fill(x, y, width, height, text)
	gpu.setBackground(oldBackground)
end


--User must put in addresses before continuing 
local startProg = true
if (#machines == 0 or #tanks == 0 or #pinnedMachines == 0) then
	startProg = false
end

--if the number of machines is less than twelve, set finish to twelve. 
if #machines < 13 then
	finish = #machines
else
	finish = 12
end


--initalizes screenOuter table to add entries to later
local screenOuter = {}

--adds all the borders to the screenOuter table	
function setScreenOuter()
	screenOuter["multiblockInformation"] = { x = 3, y = 2, width = 85, height= 35, title = "  Multiblock Information  "}
	screenOuter["pinnedMachines"] = { x = 92, y = 2, width = 66, height = 20, title = "  Pinned Machines  "}
	screenOuter["fluidLevels"] = { x = 92, y = 24, width = 66, height= 13, title = "  Fluid Levels  "}
	screenOuter["energy"] = { x = 3, y = 40, width = 155, height= 9, title = "  Energy Levels  "}
end

  
-- set size of the screen for lvl 3 and clear the screen
gpu.setResolution(160,50)
gpu.setBackground(colors.black)	
gpu.fill(1, 1, 132, 38, " ")	


--calls the setScreenOuter function. 
setScreenOuter()

--this functions prints the Outer Borders (blue). It passes the Name through it so it know which border to make. 	
function printBordersOuter(screenOuterName)
	
	--gets the properties of the correct border
	local sO = screenOuter[screenOuterName]

	-- set border
	gpu.setBackground(colors.blue)
	gpu.fill(sO.x, sO.y, sO.width, 1, " ")
	gpu.fill(sO.x, sO.y, 1, sO.height, " ")
	gpu.fill(sO.x, sO.y + sO.height, sO.width, 1, " ")
	gpu.fill(sO.x + sO.width, sO.y, 1, sO.height + 1, " ")
  
	-- set title
	gpu.setBackground(colors.black)
	gpu.set(sO.x + 4, sO.y, sO.title)
	gpu.setForeground(colors.white)
	
end

-- get the dimensions of the pinnedMachines section. 
local pinnedMachineX = screenOuter["pinnedMachines"].x + 2
local pinnedMachineY = screenOuter["pinnedMachines"].y + 1

-- indent the text by 2 spaces from the left side of the section
local fluidLevelX = screenOuter["fluidLevels"].x + 2 
-- start the text at the top of the section
local fluidLevelY = screenOuter["fluidLevels"].y + 1 

--initiazling variables. 
local screenInner = {}
local machineXOffset = 40
local machineYOffset = 5
local machinexStart = 7
local machineyStart = 4
local function setScreenInner(currentMachineName, i)

	screenInner[i] =  {
	
	title = " "..tostring(currentMachineName).." ",
	width = 33,
	height = 4,
	x = machinexStart + machineXOffset * ((i - 1) // 6 % 2),
	y = machineyStart + machineYOffset * ((i - 1) % 6)
	
	}
	
end

for i = 1, #machines do
	local machine = machines[i]
	local currentMachineName = machine.name
	setScreenInner(currentMachineName, i)
end
	
local function drawBorder(x, y, width, height)

  gpu.setForeground(colors.yellow)
  -- top and bottom lines
	gpu.fill(x, y, width, 1, "─")
	gpu.fill(x, y+height, width, 1, "─")

  -- left and right lines
	gpu.fill(x, y, 1, height, "│")
	gpu.fill(x+width, y, 1, height, "│")

  -- corners
  gpu.set(x, y, "╭")
  gpu.set(x+width, y, "╮")
  gpu.set(x, y+height, "╰")
  gpu.set(x+width, y+height, "╯")

  gpu.setForeground(colors.white)
end

-- Define the width and height of the buttons
local buttonWidth = 4
local buttonHeight = 2

-- Define the horizontal spacing between buttons
local buttonSpacing = 1

local function drawButton(x, y)
  -- Draw the border
  drawBorder(x, y, buttonWidth, buttonHeight)

  -- Add any additional content to the button
  -- (e.g. text, icons, etc.)
  -- ...
end

local function printBordersInner(i)

	local sI = screenInner[i]
	drawBorder(sI.x, sI.y, sI.width, sI.height)
	printColoredText(sI.x + 2, sI.y, sI.title, colors.purple)

end
  
  
--these two for loops iterates through the tables screenOuter and sceenInner and displays all the sections for each. 
--i.e. This will print the borders and the titles of the borders. 
for name, data in pairs(screenOuter) do
	printBordersOuter(name)
end
  
for name, data in pairs(screenInner) do
	printBordersInner(name)
end

local machinePrintPage = 1
local machineStartBorder = (machinePrintPage - 1) * 12 + 1
local machineFinishBorder = math.min(machinePrintPage * 12, #machines) 

for i = machineStartBorder, machineFinishBorder do
	printBordersInner(i) 
end

--this function correctly prints fluid level sensor information
function getFluidLevels(output)
	fluidLevel = string.match(output , "§e.*$")
	fluidLevel = string.gsub(fluidLevel, "§e", "")
	fluidLevel = string.gsub(fluidLevel, " L§r", "")
	fluidMax = string.match(output, "%§e(.*)")
	fluidMax = string.gsub(fluidMax, " L§r", "")
    return fluidLevel.." / "..fluidMax.." mb"
end


local tankFluidLevels = {}
for i, tank in ipairs(tanks) do
    found = false
    for g, machine in ipairs(machines) do
        if(tank.name == machine.name) then
            found = true
            break
        end
    end
    if not found then
        tankName = tank.name
        -- Add the tank to the new array
        table.insert(tankFluidLevels, {
            id = component.get(tank.id),
            name = tankName
        })
    end
end

--gets the number of pages needed for multiblockInformation
local machineNumPage = math.ceil(#machines/12)
local machineSetPage = machineNumPage

--gets the number of pages needed for fluid Levels
local fluidNumPage = math.ceil(#tankFluidLevels/8)
local fluidSetPage = fluidNumPage

--this function is running multiple times then multiple times
function createMachineButtons (machinePGX, i)
	API.setTable("machinePage"..i, pageMachineButton, machinePGX+1, 35, machinePGX+3, 35, tostring(machineSetPage), {on = colors.black, off = colors.yellow})
	machineSetPage = machineSetPage -1
end

--this function is running multiple times then multiple times
function createFluidButtons (fluidPGX, i)
	API.setTable("fluidPage"..i, pageFluidButton, fluidPGX+1, 35, fluidPGX+3, 35, tostring(fluidSetPage), {on = colors.black, off = colors.yellow})
	fluidSetPage = fluidSetPage -1
end

local fluidYValue = 0

local function printTankInfo(tank, tankName)
	gpu.set(fluidLevelX, fluidLevelY+fluidYValue, tankName..": "..getFluidLevels(tank.getSensorInformation()[4]))
end

local fluidPrintPage = 1
local fluidStartBorder = (fluidPrintPage - 1) * 8 + 1
local fluidFinishBorder = math.min(fluidPrintPage * 8, #tankFluidLevels) 

--this function will be called everytime a button is hit.  
function pageMachineButton(text)

		machinePrintPage = text
		
		machineStartBorder = (machinePrintPage - 1) * 12 + 1
		machineFinishBorder = math.min(machinePrintPage * 12, #machines)

		--clear the area where the Multiblock Information is set 
		gpu.fill(5, 3, 82, 31, " ")
		
		--prints the name of each border 
		for i = machineStartBorder, machineFinishBorder do
			printBordersInner(i)
		end
		
end
	
function pageFluidButton(text)

		fluidYValue = 0

		fluidPrintPage = text
		
		fluidStartBorder = (fluidPrintPage - 1) * 8 + 1
		fluidFinishBorder = math.min(fluidPrintPage * 8, #tankFluidLevels)

		--clear the area where the Multiblock Information is set 
		gpu.fill(93, 25, 64, 9, " ")
		
		-- Iterate through the tankFluidLevels array and call printTankInfo
		for i = fluidStartBorder, fluidFinishBorder do
			local tank = tankFluidLevels[i]
			printTankInfo(component.proxy(tank.id), tank.name)
			fluidYValue = fluidYValue + 1
		end
		
end

local machinePGX = 80
for i = 1, machineNumPage do
  -- Calculate the x coordinate of the button
  local buttonX = machinePGX - (i-1) * (buttonWidth + buttonSpacing)

  -- Draw the button at the specified coordinates
  drawButton(buttonX, 34)
  
  -- Create the button
  createMachineButtons(buttonX, i)
  
end

local fluidPGX = 152
for i = 1, fluidNumPage do

  -- Calculate the x coordinate of the button
  local buttonX = fluidPGX - (i-1) * (buttonWidth + buttonSpacing)

  -- Draw the button at the specified coordinates
  drawButton(buttonX, 34)
  
  -- Create the button
  createFluidButtons(buttonX, i)
  
end
	
--API.screen is used to iterate through all the buttons and fill the table in buttonAPI
API.screen()

--This checks if a user touches the screen then calls API.checkxy
event.listen("touch", API.checkxy)

	--this variable decides what y-level to print out each machine's information. This goes up by 5 after each iteration
	local xVar = 2
	
	--this function prints all the MultiBlock Information. 
	local function printMachineMethods(machine, i)
	
		--if i is greater than 6, it needs to print on the right side. Change the X value to 39. 
		--also subtracts 6 to start at the top as i is multiple for the y value in gpu.set
		if(i>6) then
			i = i-6
			xVar = 42
		end
			
		--if the number of problems is equal to 0
		if (string.match(tostring(machine.getSensorInformation()[5]), "§c(%d+)")) == "0" then
			if (machine.isWorkAllowed()) == true then
				if(machine.isMachineActive()) == true then
					gpu.setForeground(colors.green)
					gpu.set(7+xVar, i*5,"Machine go Brrrrrrr")

					gpu.setForeground(colors.white)
					gpu.set(7+xVar, i*5+1,(string.gsub(machine.getSensorInformation()[1], "§.","")))
				else
					gpu.setForeground(colors.orange)
					gpu.set(7+xVar, i*5,"Machine Status: IDLE")
					gpu.setForeground(colors.white)
					
				end	
			else
					gpu.setForeground(colors.red)
					gpu.set(7+xVar, i*5,"Machine processing disabled!!")
					gpu.setForeground(colors.white)
					
			end
		--if the number of problem isn't equal to 0 
		else
					gpu.setForeground(colors.red)
					gpu.set(7+xVar, i*5,"MACHINE HAS PROBLEMS!!!")
					gpu.setForeground(colors.white)
					
		end
	end
	
	--function to print the tanks information. 
	local function printMachineTankInfo(tank, i)
		gpu.set(7+xVar, i*5+2, getFluidLevels(tank.getSensorInformation()[4]))
	end

function comma_value(amount)
    local formatted = tostring(amount)
    local k
    while true do  
        formatted, k = formatted:gsub("^(%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function formatTime(time)

  if not time or time == math.huge or time == -math.huge then
    return "N/A"
  end
  
  local weeks = math.floor(time / 604800)
  local days = math.floor((time % 604800) / 86400)
  local hours = math.floor((time % 86400) / 3600)
  local minutes = math.floor((time % 3600) / 60)
  
  local output = ""
  
  if weeks > 0 then
    output = string.format("%d week%s", weeks, weeks > 1 and "s" or "")
    if days > 0 or hours > 0 or minutes > 0 then
      output = output .. ", "
    end
  end
  
  if days > 0 then
    output = output .. string.format("%d day%s", days, days > 1 and "s" or "")
    if hours > 0 or minutes > 0 then
      output = output .. ", "
    end
  end
  
  if hours > 0 then
    output = output .. string.format("%d hour%s", hours, hours > 1 and "s" or "")
    if minutes > 0 and (weeks > 0 or days > 0 or hours > 0) then
      output = output .. ", "
    end
  end
  
  if minutes > 0 then
    output = output .. string.format("%d minute%s", minutes, minutes > 1 and "s" or "")
	end
	
  if output == "" then
    output = "Less than one minute"
  end
  
  return output
end

drawBorder(6, 42, 149, 3)	

local counter = 0
local timeToFillAVG = 0
local netEnergyAVG = 0
local LSC = component.proxy(component.get(energy[1].id))
local timeToFill = 0
local energyMax = math.floor(string.gsub(LSC.getSensorInformation()[3], "([^0-9]+)", "") + 0)

--everything inside this while loop will run every 0.5 seconds by os.sleep(0.5)
local function loop()

	--code for adding problems up. problems wille be printed at the end 
	local problems = 0
	gpu.set(7, 35, "                         ")
	for i, machine in ipairs (machines) do
		if (component.proxy(component.get(machine.id)).isWorkAllowed()) == false or string.match(tostring(component.proxy(component.get(machine.id)).getSensorInformation()[5]), "§c(%d+)")  ~= "0" then
			problems = problems + 1
		end
	end

	--This is so finish will be the print the last element in machine 
	if #machines < finish then
			finish = #machines
	end
	
	fluidYValue = 0
		-- Iterate through the tankFluidLevels array and call printTankInfo
	for i = fluidStartBorder, fluidFinishBorder do
		local tank = tankFluidLevels[i]
		printTankInfo(component.proxy(tank.id), tank.name)
		fluidYValue = fluidYValue + 1
	end
	
	
	--get the name of the machine at the start - finish index for the machines table. 
	for i = machineStartBorder, machineFinishBorder do
		
		machine = machines[i]
		currentMachineName = machine.name

		--i need to be a value of 1-12 as that's how many machines can be printed at once
		--since there's multiple pages, it divides by 12 then gets the remainder
		i = i%12
		--if there is no remainder, the value is a multiple of 12 and should be printed at the 12th spot
		if i == 0 then
		i = 12
		end

		--this prints all the multiblock information
		printMachineMethods(component.proxy(component.get(machine.id)), i)
		
		--this prints the tank fluid level for each multiblock
		for g, tank in ipairs(tanks) do
			if tank.name == currentMachineName then
				printMachineTankInfo(component.proxy(component.get(tank.id)), i)
			end

		end
			
	end
	
	--Once the # of problems is added up, print it
	gpu.set(7, 35, "Number of Problems: "..problems)
	
	local energyInfo = energyFiles.getEnergyInformation(LSC, energyMax, colors, timeToFillAVG, netEnergyAVG)
	timeToFillAVG = energyInfo.timeToFillAVG
	netEnergyAVG = energyInfo.netEnergyAVG
    
	gpu.fill(6,46, 95,1, " ")
	gpu.fill(6, 47, 60, 1, " ")
	
	setBackgroundColor(7, 43, 148, 2, " ", colors.turq)
	setBackgroundColor(7, 43, energyInfo.progressBar, 2, " ", colors.cyan)
	
	printColoredText(6, 46, "Net Energy: "..comma_value(energyInfo.netEnergy).."eu/t", energyInfo.netEnergyColor)
	gpu.set(6, 47, "Energy Level: "..comma_value(energyInfo.energyLevel).." / "..comma_value(energyMax).."eu")
	gpu.set(75, 46, (string.format("%.2f", energyInfo.percent).."%"))

	if counter == 15 then
		energyFiles.displayEnergyInfo(energyInfo, netEnergyAVG, timeToFillAVG, colors)
		counter = 0
		timeToFillAVG = 0
		netEnergyAVG = 0
	end
	
		counter = counter + 1

  -- Wait 0.5 seconds before checking the status again
  os.sleep(0.5)

--end of the while loop
end

while startProg do
	loop()
end

gpu.set(6, 7, "To get started, connect some adapters to your machines / tanks.")
gpu.set(6, 8, "This message will disappear when at least one address is present in each:")
gpu.set(6, 9, "machines.lua, tanks.lua, and pinnedMachines.lua") 


gpu.set(6, 12, "After connecting machines and adapter, run gtMachineList.lua")
gpu.set(6, 13, "To make life easier, record the results in a text file using: ")
gpu.set(6, 15, "gtMachineList.lua > Output.txt")
gpu.set(6, 17, "The text file will be in the same directory as this program.")
