-- gt_machineOS created by: Zeruel
-- Ver 1.0

-- Border code originally by Krakaen to use in 'OPENCOMPUTER AUTOMATION PROGRAM'
-- buttonAPI ported to OC by MoparDan originally created by DireWolf 20 for ComputerCraft

-- TODO list
-- Change to update every 1 second (when a button is pressed, it should refresh on the screen right away
-- Clean up loop (double check fluid and machine handling)
-- Comment code
-- Filter by IDLE, processing disabled, problems
-- add button to turn off and on machine
-- Try to break code
-- Add handling for when user first starts program

-- Future:
-- Info panel

-- Components to require
local component = require("component")
local event = require("event")
local gpu = component.gpu

-- Require the API from buttonAPI.lua and utils from utils.lua
local API = require("buttonAPI")
local utils = require("utils")

-- Load the files that store machines / tank addresses
local machines_chunk = loadfile("addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("addressList/tanks.lua")
local tanks = tanks_chunk()
local pinnedMachines_chunk = loadfile("addressList/pinnedMachines.lua")
local pinnedMachines = pinnedMachines_chunk()
local energy_chunk = loadfile("addressList/energy.lua")
local energy = energy_chunk()
local energyFiles = require("energyFiles")


-- Define the width and height of the buttons
local buttonWidth = 4
local buttonHeight = 2

-- Define the horizontal spacing between buttons
local buttonSpacing = 1

local function drawButton(x, y)
  -- Draw the border
  utils.drawBorder(x, y, buttonWidth, buttonHeight)
end

-- User must put in addresses before continuing 
local startProg = true
if (#machines == 0 or #tanks == 0 or #pinnedMachines == 0) then
	startProg = false
end

-- Initalizes screenOuter table to add entries to later
local screenOuter = {}

-- Adds all the borders to the screenOuter table	
function setScreenOuter()
	screenOuter["multiblockInformation"] = { x = 3, y = 2, width = 85, height= 35, title = "  Multiblock Information  "}
	screenOuter["controlPanel"] = { x = 92, y = 12, width = 66, height = 10, title = "  Control Panel  "}
	screenOuter["fluidLevels"] = { x = 92, y = 24, width = 66, height= 13, title = "  Fluid Levels  "}
	screenOuter["energy"] = { x = 3, y = 40, width = 155, height= 9, title = "  Energy Levels  "}
end
  
-- Set size of the screen for lvl 3 and clear the screen
gpu.setResolution(160,50)
gpu.setBackground(utils.colors.black)	
gpu.fill(1, 1, 132, 38, " ")	

-- Calls the setScreenOuter function. 
setScreenOuter()

-- Prints the Outer Borders (blue). It passes the Name through it so it know which border to make. 	
function printBordersOuter(screenOuterName)
	
	-- Gets the properties of the correct border
	local sO = screenOuter[screenOuterName]

	-- Set border
	gpu.setBackground(utils.colors.blue)
	gpu.fill(sO.x, sO.y, sO.width, 1, " ")
	gpu.fill(sO.x, sO.y, 1, sO.height, " ")
	gpu.fill(sO.x, sO.y + sO.height, sO.width, 1, " ")
	gpu.fill(sO.x + sO.width, sO.y, 1, sO.height + 1, " ")
  
	-- Set title
	gpu.setBackground(utils.colors.black)
	gpu.set(sO.x + 4, sO.y, sO.title)
	gpu.setForeground(utils.colors.white)
	
end

-- Get the dimensions of the pinnedMachines section. 
local pinnedMachineX = screenOuter["controlPanel"].x + 2
local pinnedMachineY = screenOuter["controlPanel"].y + 1

penguin = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠴⠒⠒⠒⠶⢤⣄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠈⠙⢦⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢳⡀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢸⠁⠀⠀⣠⠖⠛⠛⠲⢤⠀⠀⠀⣰⠚⠛⢷⠀⠀⠀⠀
⠀⠀⠀⠀⠀⣿⠀⠀⣸⠃⠀⠀⢀⣀⠈⢧⣠⣤⣯⢠⣤⠘⣆⠀⠀⠀
⠀⠀⠀⠀⠀⣿⠀⠀⡇⠀⠀⠀⠻⠟⠠⣏⣀⣀⣨⡇⠉⢀⣿⠀⠀⠀
⠀⠀⠀⠀⢀⡟⠀⠀⠹⡄⠀⠀⠀⠀⠀⠉⠑⠚⠉⠀⣠⡞⢿⠀⠀⠀
⠀⠀⠀⢀⡼⠁⠀⠀⠀⠙⠳⢤⡄⠀⠀⠀⠀⠀⠀⠀⠁⠙⢦⠳⣄⠀
⠀⠀⢀⡾⠁⠀⠀⠀⠀⠀⠤⣏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⠃⠙⡆
⠀⠀⣼⠁⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⠀⠀⠀⠀⠀⠀⠀⢠⡏⠀⠀⡇
⠀⠀⣏⠀⠀⠀⠀⠲⣄⡀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠀⢸⠀⢀⡼⠁
⢀⡴⢿⠀⠀⠀⠀⠀⢸⠟⢦⡀⠀⢀⡇⠀⠀⠀⠀⠀⠀⠘⠗⣿⠁⠀
⠸⣦⡘⣦⠀⠀⠀⠀⣸⣄⠀⡉⠓⠚⠀⠀⠀⠀⠀⠀⠀⠀⡴⢹⣦⡀
⠀⠀⠉⠛⠳⢤⣴⠾⠁⠈⠟⠉⣇⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⣠⠞⠁
⠀⠀⠀⠀⠀⠀⠙⢧⣀⠀⠀⣠⠏⠀⠀⢀⣀⣠⠴⠛⠓⠚⠋⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠉⠙⠋⠉⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

titleCard = [[                                                                                                     
        _     __  __            _     _             ____   _____ 
       | |   |  \/  |          | |   (_)           / __ \ / ____|
   __ _| |_  | \  / | __ _  ___| |__  _ _ __   ___| |  | | (___  
  / _` | __| | |\/| |/ _` |/ __| '_ \| | '_ \ / _ \ |  | |\___ \ 
 | (_| | |_  | |  | | (_| | (__| | | | | | | |  __/ |__| |____) |
  \__, |\__| |_|  |_|\__,_|\___|_| |_|_|_| |_|\___|\____/|_____/ 
   __/ | ______                                                  
  |___/ |______|                                                                                                                                                                                                                                                                                                        
]]

utils.printAsciiArt(pinnedMachineX - 2, pinnedMachineY - 12, titleCard)
gpu.set(pinnedMachineX + 35, pinnedMachineY - 2, "Created by: Zeruel    Ver 1.0 ")

-- Indent the text by 2 spaces from the left side of the section
local fluidLevelX = screenOuter["fluidLevels"].x + 2 
-- Start the text at the top of the section
local fluidLevelY = screenOuter["fluidLevels"].y + 2

-- Initiazling variables for the dimension of the MultiBlock borders. 
local screenInner = {}
local machineXOffset = 40
local machineYOffset = 5
local machinexStart = 7
local machineyStart = 4
local function setScreenInner(currentMachineName, i)

	-- At index i, set the width, height, and X/Y depending on the index 
	screenInner[i] =  {
	
	title = " "..tostring(currentMachineName).." ",
	width = 37,
	height = 4,
	machineX = machinexStart + machineXOffset * ((i - 1) // 6 % 2),
	machineY = machineyStart + machineYOffset * ((i - 1) % 6)
	
	}
	
end

-- machineTankList stores tank information if there is a multiblock with the same name
machineTankList = {}

for i = 1, #machines do

	-- Calls setScreenInner which adds all the machines to screenInner
	local machine = machines[i]
	local currentMachineName = machine.name
	setScreenInner(currentMachineName, i)
	
	-- If the tank name and machine name match, add it to machineTankList at index i 
	for g, tank in ipairs(tanks) do
		if tank.name == currentMachineName then
			machineTankList[i] = tank.id
		end
	end
	
end

-- Draws the border and text for the inner borders
local function printBordersInner(i)
	local sI = screenInner[i]
	utils.drawBorder(sI.machineX, sI.machineY, sI.width, sI.height)
	utils.printColoredText(sI.machineX + 2, sI.machineY, sI.title, utils.colors.purple)
end
  
-- This loops through screenOuter and calls printBorderOuter
-- i.e. This will print the borders and the titles of the borders. 
for name, data in pairs(screenOuter) do
	printBordersOuter(name)
end

-- These four variables decide what page to print, how many machines per page, and what machines to start and stop printing on that page
local machinePrintPage = 1
local machinesPerPage = 12
local machineStartBorder = (machinePrintPage - 1) * machinesPerPage + 1
local machineFinishBorder = math.min(machinePrintPage * machinesPerPage, #machines) 

-- This loops through start and finish border and calls printBorderInner
-- i.e. This will print the borders and the titles of the borders. 
for i = machineStartBorder, machineFinishBorder do
	printBordersInner(i) 
end

-- Correctly prints fluid levels from sensor information
function getFluidLevels(output)
    fluidLevel = string.match(output , "§a(%d[%d,]*) L§r")
    fluidMax = string.match(output, "§e(%d[%d,]*) L§r")
    return fluidLevel.." / "..fluidMax.." mb"
end

-- For loop to iterate through all entries in tanks.lua and if there isn't a machine matching the same name, it adds it to tankFluidLevels
-- This is for the Fluid Levels border 
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

-- Gets the number of pages needed for multiblockInformation
local machineNumPage = math.ceil(#machines/machinesPerPage)
local machineSetPage = machineNumPage

-- Gets the number of pages needed for fluid Levels
local tanksPerPage = 10
local fluidNumPage = math.ceil(#tankFluidLevels/tanksPerPage)
local fluidSetPage = fluidNumPage

-- Create a page containing multiblocks 
local function createMachineButtons (machinePGX, i)
	API.setTable("machinePage"..i, pageMachineButton, machinePGX+1, 35, machinePGX+3, 35, tostring(machineSetPage), utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow})
	machineSetPage = machineSetPage -1
end

-- Create a page containing tanks
local function createFluidButtons (fluidPGX, i)
	API.setTable("fluidPage"..i, pageFluidButton, fluidPGX+1, 35, fluidPGX+3, 35, tostring(fluidSetPage), utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow})
	fluidSetPage = fluidSetPage -1
end

-- When the user goes to a new page, the button to turn on/off the machine has to be removed so a new one can be added
-- Remove all buttons with control in their name
local function removeMachineControlButtons()
  for name, data in pairs(button) do
    if string.find(name, "Control") then
      button[name] = nil
    end
  end
end

-- Create a button that turns on/off a machine
local function createMachineControlButton(machine, i, x, y)
	local buttonLabel = machine.isWorkAllowed() and "[ON]" or "[OFF]"
	local buttonColor = machine.isWorkAllowed() and utils.colors.green or utils.colors.red
	local xValue = machine.isWorkAllowed() and 32 or 31
	API.setTable("Control"..i, function() machine.setWorkAllowed(not machine.isWorkAllowed()) end, x + xValue, y + 1, x + 36, y + 1, buttonLabel, buttonColor, {on = utils.colors.black, off = utils.colors.yellow})
end
	
-- Prints all the MultiBlock Information. 
local function printMachineMethods(machine, i)

	-- Clearing the machine method area 
	gpu.fill(screenInner[i].machineX + 2, screenInner[i].machineY + 1, 35, 3, " ")
		
	-- Machine Control button
	local machineStatus = machine.isWorkAllowed()
	createMachineControlButton(machine, i, screenInner[i].machineX, screenInner[i].machineY, machineStatus)

	-- If the number of problems is equal to 0
	if (string.match(tostring(machine.getSensorInformation()[5]), "§c(%d+)")) == "0" then
		if (machine.isWorkAllowed()) == true then
			if(machine.isMachineActive()) == true then
				utils.printColoredText(screenInner[i].machineX + 2, screenInner[i].machineY + 1,"Machine go Brrrrrrr", utils.colors.green)
				gpu.set(screenInner[i].machineX + 2, screenInner[i].machineY + 2,(string.gsub(machine.getSensorInformation()[1], "§.","")))
			else
			utils.printColoredText(screenInner[i].machineX + 2, screenInner[i].machineY + 1,"Machine Status: IDLE", utils.colors.orange)
			end	
		else
			utils.printColoredText(screenInner[i].machineX + 2, screenInner[i].machineY + 1,"Processing Disabled!", utils.colors.red)					
		end
	-- If the number of problem isn't equal to 0 
	else
		utils.printColoredText(screenInner[i].machineX + 2, screenInner[i].machineY + 1,"MACHINE HAS PROBLEMS!!!", utils.colors.red)				
	end
	
end
	
-- Print the tanks information. 
local function printMachineTankInfo(tank, i)
	gpu.set(screenInner[i].machineX + 2, screenInner[i].machineY + 3, getFluidLevels(tank.getSensorInformation()[4]))
end

-- When a page button is pressed in the MultiBlock Information section
-- note: can't be local, is used by buttonAPI.lua
function pageMachineButton(text)
	
		machinePrintPage = text
		
		machineStartBorder = (machinePrintPage - 1) * machinesPerPage + 1
		machineFinishBorder = math.min(machinePrintPage * machinesPerPage, #machines)

		-- Clear the area where the Multiblock Information is set 
		gpu.fill(5, 3, 82, 31, " ")
			
		-- Remove the existing machine control buttons
		removeMachineControlButtons()
		
		-- Prints the name of each border 
		for i = machineStartBorder, machineFinishBorder do

			printBordersInner(i)

			machine = machines[i]
			currentMachineName = machine.name

			-- Prints all the multiblock information
			printMachineMethods(component.proxy(component.get(machine.id)), i)
			
			-- If there is an entry in machineTankList, print the info for it. 
			if machineTankList[i] then
				printMachineTankInfo(component.proxy(component.get(machineTankList[i])), i)
			end
			
		end		
		
		API.screen()
end

local fluidYValue = 0

-- Print tank information. Is used for Fluid levels section 
local function printTankInfo(tank, tankName)
	gpu.set(fluidLevelX, fluidLevelY+fluidYValue, tankName..": "..getFluidLevels(tank.getSensorInformation()[4]))
end

-- These three variables decide what page to print, how many tanks per page, and what tanks to start and stop printing on that page
local fluidPrintPage = 1
local fluidStartBorder = (fluidPrintPage - 1) * tanksPerPage + 1
local fluidFinishBorder = math.min(fluidPrintPage * tanksPerPage, #tankFluidLevels) 

-- When a page button is pressed in the Fluid Levels section
-- note: can't be local, is used by buttonAPI.lua
function pageFluidButton(text)

		fluidYValue = 0
		fluidPrintPage = text
		
		fluidStartBorder = (fluidPrintPage - 1) * tanksPerPage + 1
		fluidFinishBorder = math.min(fluidPrintPage * tanksPerPage, #tankFluidLevels)

		-- Clear the area where the fluid Levels is set 
		gpu.fill(94, 26, 52, 10, " ")
		
		-- Iterate through the tankFluidLevels array and call printTankInfo
		for i = fluidStartBorder, fluidFinishBorder do
			local tank = tankFluidLevels[i]
			printTankInfo(component.proxy(tank.id), tank.name)
			fluidYValue = fluidYValue + 1
		end
		
end

local function createPageButtons(numPages, createButtonFunc, pageX)

    
    for i = 1, numPages do
        -- Calculate the x coordinate of the button
        local buttonX = pageX - (i-1) * (pageButtonWidth + pageButtonSpacing)

        -- Draw the button at the specified coordinates
        drawButton(buttonX, 34)
        
        -- Create the button using the specified function
        createButtonFunc(buttonX, i)
    end
end

local machinePGX = 80
createPageButtons(machineNumPage, createMachineButtons, machinePGX)
local fluidPGX = 152
createPageButtons(fluidNumPage, createFluidButtons, fluidPGX)

-- Checks if a user touches the screen then calls API.checkxy
event.listen("touch", API.checkxy)

-- Border for Energy Levels
utils.drawBorder(6, 42, 149, 3)	

-- Initiazling variables for Energy Levels
local counter = 0
local timeToFillAVG = 0
local netEnergyAVG = 0
local LSC = component.proxy(component.get(energy[1].id))
local timeToFill = 0
local energyMax = math.floor(string.gsub(LSC.getSensorInformation()[3], "([^0-9]+)", "") + 0)

-- Everything inside this while loop will run every 1 second1 by os.sleep(1)
local function loop()

	-- Adding problems up. problems wille be printed at the end 
	local problems = 0
	gpu.set(7, 35, "                         ")
	for i, machine in ipairs (machines) do
		if (component.proxy(component.get(machine.id)).isWorkAllowed()) == false or string.match(tostring(component.proxy(component.get(machine.id)).getSensorInformation()[5]), "§c(%d+)")  ~= "0" then
			problems = problems + 1
		end
	end
	
	-- Clear the area where the fluid Levels is set 
	gpu.fill(94, 26, 52, 10, " ")
	fluidYValue = 0
		-- Iterate through the tankFluidLevels array and call printTankInfo
	for i = fluidStartBorder, fluidFinishBorder do
		local tank = tankFluidLevels[i]
		printTankInfo(component.proxy(tank.id), tank.name)
		fluidYValue = fluidYValue + 1
	end
	
	
	-- Get the name of the machine at the start - finish index for the machines table. 
	for i = machineStartBorder, machineFinishBorder do
		
		machine = machines[i]
		currentMachineName = machine.name

		-- Prints all the multiblock information
		printMachineMethods(component.proxy(component.get(machine.id)), i)
		
		-- If there exsists an entry in machineTankList at index i, print the tank info
		if machineTankList[i] then
			printMachineTankInfo(component.proxy(component.get(machineTankList[i])), i)
		end
			
	end
	
	-- Once the # of problems is added up, print it
	gpu.set(7, 35, "Number of Problems: "..problems)
	
	-- Variables for calculating time to drain/fill
	local energyInfo = energyFiles.getEnergyInformation(LSC, energyMax, colors, timeToFillAVG, netEnergyAVG)
	timeToFillAVG = energyInfo.timeToFillAVG
	netEnergyAVG = energyInfo.netEnergyAVG
    
	-- Clear the area to allow for new information to be printed 
	gpu.fill(6,46, 95,1, " ")
	gpu.fill(6, 47, 60, 1, " ")
	
	-- Draws the progress bar 
	utils.setBackgroundColor(7, 43, 148, 2, " ", utils.colors.turq)
	utils.setBackgroundColor(7, 43, energyInfo.progressBar, 2, " ", utils.colors.cyan)
	
	-- Prints Net Energy, Energy Level, and Percent
	utils.printColoredText(6, 46, "Net Energy: "..utils.comma_value(energyInfo.netEnergy).."eu/t", energyInfo.netEnergyColor)
	gpu.set(6, 47, "Energy Level: "..utils.comma_value(energyInfo.energyLevel).." / "..utils.comma_value(energyMax).."eu")
	gpu.set(75, 46, (string.format("%.2f", energyInfo.percent).."%"))
	
	-- To get a more accurate time to fill/drain, it collects inforamtion for 30 second before updating it
	if counter == 30 then
		energyFiles.displayEnergyInfo(energyInfo, netEnergyAVG, timeToFillAVG, colors)
		counter = 0
		timeToFillAVG = 0
		netEnergyAVG = 0
	end
	
		counter = counter + 1

-- API.screen is used to iterate through all the buttons and fill the table in buttonAPI
API.screen()

	-- Wait 1 seconds before checking the status again
	os.sleep(1)

-- End of the while loop
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