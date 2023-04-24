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
local term = require("term")
local computer = require("computer")
local gpu = component.gpu

-- Require APIs
local API = require("buttonAPI")
local utils = require("utils")
local energyFiles = require("energyFiles")
local gtMachineFind = require("gtMachineFind")

-- Load the files that store machines / tank addresses
local machines_chunk = loadfile("addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("addressList/tanks.lua")
local tanks = tanks_chunk()
local pinnedMachines_chunk = loadfile("addressList/pinnedMachines.lua")
local pinnedMachines = pinnedMachines_chunk()
local energy_chunk = loadfile("addressList/energy.lua")
local energy = energy_chunk()

-- Controls the whole loop
local checkLoop = true

-- Define the width and height of the buttons
local pageButtonWidth = 4
local pageButtonHeight = 2

-- Define the horizontal spacing between buttons
local pageButtonSpacing = 1

local function drawButton(x, y)
  -- Draw the border
  utils.drawBorder(x, y, pageButtonWidth, pageButtonHeight)
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
gpu.fill(1, 1, 160, 50, " ")	

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

local multiblockInformationX = screenOuter["multiblockInformation"].x + 2
local multiblockInformationY = screenOuter["multiblockInformation"].y + 1

-- Get the dimensions of the pinnedMachines section. 
local controlPanelX = screenOuter["controlPanel"].x + 2
local controlPanelY = screenOuter["controlPanel"].y + 1

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

-- Iterate through all entries in tanks.lua and if there isn't a machine matching the same name, it adds it to tankFluidLevels
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
local tanksPerPage = 8
local fluidNumPage = math.ceil(#tankFluidLevels/tanksPerPage)
local fluidSetPage = fluidNumPage

-- Create a page containing multiblocks 
local function createMachineButtons (machinePGX, i)
	API.setTable("machinePage"..i, pageMachineButton, machinePGX+1, 35, machinePGX+3, 35, tostring(machineSetPage), utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)
	machineSetPage = machineSetPage -1
end

-- Create a page containing tanks
local function createFluidButtons (fluidPGX, i)
	API.setTable("fluidPage"..i, pageFluidButton, fluidPGX+1, 35, fluidPGX+3, 35, tostring(fluidSetPage), utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)
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
	API.setTable("Control"..i, function() machine.setWorkAllowed(not machine.isWorkAllowed()) end, x + xValue, y + 1, x + 36, y + 1, buttonLabel, buttonColor, {on = utils.colors.black, off = utils.colors.yellow}, true)
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
		gpu.fill(94, 26, 52, 8, " ")
		
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

-- Initiazling variables for Energy Levels. Checks if there is one valid LSC in energy.lua
local LSC 
local energyMax
local counter = 0
local timeToFillAVG = 0
local netEnergyAVG = 0
local timeToFill = 0

if #energy == 1 and component.proxy(component.get(energy[1].id)) then

	-- Border for Energy Levels
	utils.drawBorder(6, 42, 149, 3)	

	LSC = component.proxy(component.get(energy[1].id))
	energyMax = math.floor(string.gsub(LSC.getSensorInformation()[3], "([^0-9]+)", "") + 0)
	
end

local function createBackButton()
utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 30, multiblockInformationX+ 2, 2)
API.setTable("backButton", backButton, multiblockInformationX+ 3, multiblockInformationY+ 31, multiblockInformationX+ 7,  multiblockInformationY+ 31, "Back", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)
API.screen("backButton")
 -- Unregister checkxy from the touch event listener. If checkxy isn't unregistered, 
 -- both waitForButtonPress and checkxy will be called resulting in a button's function being called twice
event.ignore("touch", API.checkxy)

-- Program will do nothing until a button is pressed. 
API.waitForButtonPress("backButton")
end

local function processingFilterButton()

end

local function idleFilterButton()

end

local function processingDisabledFilterButton()

end

local function problemFilterButton()

end

local function createFilterButtons()

utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 2, multiblockInformationX+ 8, 2)
API.setTable("processingFilterButton", processingFilterButton, multiblockInformationX+ 4, multiblockInformationY + 3, multiblockInformationX + 13, multiblockInformationY + 3, "Processing", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 6, multiblockInformationX+ 2, 2)
API.setTable("idleFilterButton", idleFilterButton, multiblockInformationX+ 4, multiblockInformationY + 7, multiblockInformationX + 7, multiblockInformationY + 7, "Idle", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 10, multiblockInformationX+ 17, 2)
API.setTable("processingDisabledFilterButton", processingDisabledFilterButton, multiblockInformationX+ 4, multiblockInformationY + 11, multiblockInformationX + 20, multiblockInformationY + 11, "Processing Disabled", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 14, multiblockInformationX+ 10, 2)
API.setTable("problemFilterButton", problemFilterButton, multiblockInformationX+ 4, multiblockInformationY + 15, multiblockInformationX + 15, multiblockInformationY + 15, "Has Problems", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

API.screen("processingFilterButton")
API.screen("idleFilterButton")
API.screen("processingDisabledFilterButton")
API.screen("problemFilterButton")

end

local function aboutButton()

checkLoop = false

-- Clears the multiblock information section
gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
gpu.set(multiblockInformationX + 1, multiblockInformationY + 4, "This is where text will go to explain what the progam is, who made it, etc.")

createBackButton()
end

local function helpButton()

	checkLoop = false

	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 4, "This is where text will go to explain how to use the program")

	createBackButton()
end

-- Note, can't be local as it accessses buttonAPI
function backButton()

	button["backButton"]["isVisible"] = false
	
	if button["processingFilterButton"] then
		button["processingFilterButton"]["isVisible"] = false
		button["idleFilterButton"]["isVisible"] = false
		button["processingDisabledFilterButton"]["isVisible"] = false
		button["problemFilterButton"]["isVisible"] = false
	end

	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	
	
	-- Print the borders again
	for i = machineStartBorder, machineFinishBorder do
		printBordersInner(i)
	end
	
	for i = 1, machineNumPage do
		-- Calculate the x coordinate of the button
		local buttonX = machinePGX - (i-1) * (pageButtonWidth + pageButtonSpacing)

		-- Draw the button at the specified coordinates
		drawButton(buttonX, 34)
	end
	checkLoop = true
end

local function filterButton()

checkLoop = false

-- Clears the multiblock information section
gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
gpu.set(multiblockInformationX + 1, multiblockInformationY + 4, "This is where text will go to explain what filtering is.")

createFilterButtons()
createBackButton()

end

local function rebootButton()
computer.shutdown(true)
end

local function createRebootButton()
utils.drawBorder(multiblockInformationX+ 1, multiblockInformationY+ 30, multiblockInformationX+ 4, 2)
API.setTable("rebootButton", rebootButton, multiblockInformationX+ 3, multiblockInformationY+ 31, multiblockInformationX+ 9,  multiblockInformationY+ 31, "Reboot", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)
API.screen("rebootButton")
 -- Unregister checkxy from the touch event listener. If checkxy isn't unregistered, 
 -- both waitForButtonPress and checkxy will be called resulting in a button's function being called twice
event.ignore("touch", API.checkxy)

-- Program will do nothing until a button is pressed. 
API.waitForButtonPress("rebootButton")
end


utils.printAsciiArt(controlPanelX - 2, controlPanelY - 12, titleCard)
gpu.set(controlPanelX + 35, controlPanelY - 2, "Created by: Zeruel    Ver 1.0 ")
		
-- function for adding a line to the end of the file
local function addMachine(fileType, machineAddress, machineName)

    -- read the file into a table
    local gtMachineTable = {}
    for line in io.lines("addresslist/"..fileType..".lua") do
        table.insert(gtMachineTable, line)
    end
    
	-- insert the new machine at the desired position
	local position = #gtMachineTable - 2 -- insert before the last line (which is 'return')
	table.insert(gtMachineTable, position, "	{id = \"" .. machineAddress .. "\", name = \"" .. machineName .. "\"},")
	
    -- write the modified table back to the correct file
    local file = io.open("addresslist/"..fileType..".lua", "w")
    file:write(table.concat(gtMachineTable, "\n"))

    -- Close the file
    file:close()
	
end

-- function for moving a line in the file
local function moveMachine(fileType, machineIndex, newLineNum)

    -- read the file into a table
    local gtMachineTable = {}
    for line in io.lines("addresslist/"..fileType..".lua") do
        table.insert(gtMachineTable, line)
    end
    
    -- remove the desired line
    local removedLine = table.remove(gtMachineTable, machineIndex + 5)

    -- insert the removed line at the new position
    table.insert(gtMachineTable, newLineNum + 5, removedLine)

    -- write the modified table back to the correct file
    local file = io.open("addresslist/"..fileType..".lua", "w")
    file:write(table.concat(gtMachineTable, "\n"))

    -- Close the file
    file:close()
end

-- function for deleting a line from the file
local function deleteMachine(fileType, machineIndex)
    -- read the file into a table
    local gtMachineTable = {}
    for line in io.lines("addresslist/"..fileType..".lua") do
        table.insert(gtMachineTable, line)
    end
    
    -- remove the desired line
    local removedLine = table.remove(gtMachineTable, machineIndex + 5)

    -- write the modified table back to the correct file
    local file = io.open("addresslist/"..fileType..".lua", "w")
    file:write(table.concat(gtMachineTable, "\n"))

    -- Close the file
    file:close()
end

local function readInput(x, y, valueType)
  local input = ""
  term.setCursor(x, y)
  while true do
    local _, _, char, code = event.pull("key_down")
    if code == 28 then -- 28 is the scan code for enter
      if valueType == "number" then
        return tonumber(input)
      elseif valueType == "string" then
        return input
      else
        return nil
      end
    elseif code == 14 then -- 14 is the scan code for backspace
      if #input > 0 then
		input = string.sub(input, 1, -2)
        term.setCursor(x, y)
        term.write(input)
        term.write(" ") -- erases the last character
        term.setCursor(x + #input, y) -- move cursor back to end of input
      end
    elseif char ~= 0 and #input < 20 then
      input = input .. string.char(char)
      term.write(string.char(char))
    end
  end
end

local machineType
local fileType
local machineName

local function addButton()

	checkLoop = false

	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 1, "This page adds a multiblock, tank, or an LSC to gt_MachineOS.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 2, "Connect the machine to your OC Network for gt_MachineOS to detect it.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 3, "Attach the machine to an adapter or use an MFU for wireless connection.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 4, "Note that only one machine can be added to the OC network at a time.")
	
	local newMachineList = gtMachineFind.new

	if #newMachineList ~= 1 then
		if #newMachineList == 0 then
			gpu.set(multiblockInformationX + 1, multiblockInformationY + 6, "No new address found. Please attach an adapter to a gt_machine and try again.")
			gpu.set(multiblockInformationX + 1, multiblockInformationY + 7, "Please attach an adapter to a gt_machine and try again.")
			createRebootButton()
		else
			gpu.set(multiblockInformationX + 1, multiblockInformationY + 6, "More than one address found.")
			gpu.set(multiblockInformationX + 1, multiblockInformationY + 7, "Please only add one gt_machine at a time and try again.")
			createRebootButton()
		end
	else
	
		machineAddress = newMachineList[1]
	
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 6, "One address found. Enter the type of machine below: multiblock / tank / LSC.")
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 7, "Enter type of machine: ")
		machineType = readInput(multiblockInformationX + 24, multiblockInformationY + 7, "string")
		 
		
		while machineType ~= "multiblock" and machineType ~= "tank" and machineType ~= "lsc" do
			gpu.set(multiblockInformationX + 1, multiblockInformationY + 8, "Machine type must be multiblock / tank / LSC.")
			gpu.fill(multiblockInformationX + 24, multiblockInformationY + 7, 40, 1, " ")
			machineType = readInput(multiblockInformationX + 24, multiblockInformationY + 7, "string")
		end
	
		-- Set the maximum length for the machine name and address
		local maxNameLength = 20

		-- Set the cursor position and prompt the user for the machine name
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 10, "Enter the name of the machine (20 characters max): ")
		machineName = readInput(multiblockInformationX + 32, multiblockInformationY + 10, "string")
		
		fileType = {
			multiblock = "machines",
			tank = "tanks",
			energy = "energy"
		}
		
		addMachine(fileType[machineType], machineAddress, machineName)
		
		-- Print a confirmation message
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 16, machineType.." added to "..fileType[machineType]..".lua.")
		
		createRebootButton()
		
	end
end

local function printMachines(array)
    
    -- Print the name and index of each element in the array
    for i, machine in ipairs(array) do
        local column = math.floor((i - 1) / 24)
        local row = (i - 1) % 24
        local x = multiblockInformationX + 1 + (column * 28)
        local y = multiblockInformationY + 1 + row
        gpu.set(x, y, i .. ". " .. machine.name)
    end
end

local function editButton()

	checkLoop = false

	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 1, "This page edits exisiting machines in gt_MachineOS.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 2, "You can change the position of a machine or delete it.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 6, "What type of machine would you like to edit? multiblock / tank / LSC.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 7, "Enter type of machine: ")
	machineType = readInput(multiblockInformationX + 24, multiblockInformationY + 7, "string")
		
	while machineType ~= "multiblock" and machineType ~= "tank" and machineType ~= "lsc" do
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 8, "Machine type must be multiblock / tank / LSC.")
		gpu.fill(multiblockInformationX + 24, multiblockInformationY + 7, 40, 1, " ")
		machineType = readInput(multiblockInformationX + 24, multiblockInformationY + 7, "string")
	end
	
		fileType = {
		multiblock = "machines",
		tank = "tanks",
		energy = "energy"
	}
	
	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	
	-- Select the appropriate array based on the machine type
    local array = ({
        multiblock = machines,
        tank = tanks,
        energy = energy
    })[machineType]
	
	printMachines(array)
	
	local machineNum 
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 26, "Select the number of the machine you want to edit.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 27, "Enter number: ")
	machineNum = readInput(multiblockInformationX + 15, multiblockInformationY + 27, "number")

	while not machineNum or machineNum > #array or machineNum < 1 do 
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 28, "Must be a number from 1 - "..#array..".")
		gpu.fill(multiblockInformationX + 15, multiblockInformationY + 27, 60, 1, " ")
		machineNum = readInput(multiblockInformationX + 15, multiblockInformationY + 27, "number")
	end

	
	-- Clears the multiblock information section
	gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
	
	local editOption
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 1, "Editing: "..machineNum..". "..array[machineNum].name)
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 2, "Enter a new number to change position or type 'delete' to remove the machine.")
	gpu.set(multiblockInformationX + 1, multiblockInformationY + 3, "Enter number or delete: ")
	editOption = readInput(multiblockInformationX + 25, multiblockInformationY + 3, "string")
	
	while not editOption or (editOption ~= "delete" and (tonumber(editOption) > #array or tonumber(editOption) < 1)) do 
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 4, "Input must be a number between 1 and "..#array.." or 'delete'.")
		gpu.fill(multiblockInformationX + 25, multiblockInformationY + 3, 50, 1, " ")
		editOption = readInput(multiblockInformationX + 25, multiblockInformationY + 3, "string")
	end
	
	if editOption == "delete" then
		deleteMachine(fileType[machineType], machineNum)
		-- Print a confirmation message
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 6, array[machineNum].name.." deleted from "..fileType[machineType]..".lua.")
	else
		moveMachine(fileType[machineType], machineNum, editOption)
		-- Print a confirmation message
		gpu.set(multiblockInformationX + 1, multiblockInformationY + 6,  array[machineNum].name.." moved from position "..machineNum.." to "..editOption.." in "..fileType[machineType]..".lua.")
	end
	
	createRebootButton()

end

local function machineCheck(machines)
  for i, machine in ipairs(machines) do
    local machineCheck = component.get(machine.id)
    if not machineCheck then
      return false -- machine not found
    end
  end
  return true -- all machines found
end


gpu.set(controlPanelX + 1, controlPanelY + 1, "Add / Edit Machines")
utils.drawBorder(controlPanelX + 1, controlPanelY + 3, 14, 2)
API.setTable("Add", addButton, controlPanelX + 3, controlPanelY + 4, controlPanelX + 13, controlPanelY + 4, "Add Address", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(controlPanelX + 1, controlPanelY + 6, 17, 2)
API.setTable("Edit", editButton, controlPanelX + 3, controlPanelY + 7, controlPanelX + 17, controlPanelY + 7, "Edit Addresses", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

gpu.set(controlPanelX + 27, controlPanelY + 1, "Filter by Status")
utils.drawBorder(controlPanelX + 30, controlPanelY + 3, 9, 2)
API.setTable("filter", filterButton, controlPanelX + 33, controlPanelY + 4, controlPanelX + 38, controlPanelY + 4, "Filter", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(controlPanelX + 54, controlPanelY + 3, 8, 2)
API.setTable("about", aboutButton, controlPanelX + 56, controlPanelY + 4, controlPanelX+ 61, controlPanelY + 4, "About", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

utils.drawBorder(controlPanelX + 55, controlPanelY + 6, 7, 2)
API.setTable("help", helpButton, controlPanelX + 57, controlPanelY + 7, controlPanelX + 61, controlPanelY + 7, "Help", utils.colors.white, {on = utils.colors.black, off = utils.colors.yellow}, true)

-- API.screen is used to iterate through all the buttons and fill the table in buttonAPI
API.screen()

local firstTime = true

-- Everything inside this while loop will run every 1 second1 by os.sleep(1)
local function mainLoop()

	-- To check if user entered machines or not
	if #machines > 0 then
		if machineCheck(machines) then
			if firstTime then
			
				-- Clears the multiblock information section
				gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
				
				for i = machineStartBorder, machineFinishBorder do
					printBordersInner(i)
				end
				
				for i = 1, machineNumPage do
					-- Calculate the x coordinate of the button
					local buttonX = machinePGX - (i-1) * (pageButtonWidth + pageButtonSpacing)

					-- Draw the button at the specified coordinates
					drawButton(buttonX, 34)
				end
				
				firstTime = false
			end
		
			-- Adding problems up. problems will be printed at the end 
			local problems = 0
			gpu.fill(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 33, 23, 1, " ")
		
			for i, machine in ipairs (machines) do
				if (component.proxy(component.get(machine.id)).isWorkAllowed()) == false or string.match(tostring(component.proxy(component.get(machine.id)).getSensorInformation()[5]), "§c(%d+)")  ~= "0" then
					problems = problems + 1
				end
			end	
		
			-- Get the name of the machine at the start - finish index for the machines table. 
			for i = machineStartBorder, machineFinishBorder do
		
				machine = machines[i]

				-- Prints all the multiblock information
				printMachineMethods(component.proxy(component.get(machine.id)), i)
			
				-- If there exsists an entry in machineTankList at index i, print the tank info
				if machineTankList[i] then
					printMachineTankInfo(component.proxy(component.get(machineTankList[i])), i)
				end	
			end
			
			-- Once the # of problems is added up, print it
			gpu.set(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 33, "Number of Problems: "..problems)
			API.screen()
		else
			-- Clears the multiblock information section
			gpu.fill(multiblockInformationX, multiblockInformationY, 83, 34, " ")
			utils.printColoredText(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 4, "There are errors with the machine addresses!!!", utils.colors.red)
			utils.printColoredText(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 5, "This error appears when a machine has been added to gt_MachineOS", utils.colors.red)
			utils.printColoredText(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 6, "but your OC network can't access it.", utils.colors.red)
			utils.printColoredText(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 7, "This could happen because if a cable, adapater, or MFU has been removed.", utils.colors.red)
			utils.printColoredText(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 8, "Go to edit addresses and delete the machine has has been removed from your OC network.", utils.colors.red)
			firstTime = true
		end
	else
		gpu.set(screenOuter["multiblockInformation"].x + 2, screenOuter["multiblockInformation"].y + 2, "There are no machines entered!")
	
	end

	-- To check if user entered tanks or not
	if #tanks > 0 then
		
		-- Clear the area where the fluid Levels is set 
		gpu.fill(94, 26, 52, 8, " ")
	
		fluidYValue = 0
		-- Iterate through the tankFluidLevels array and call printTankInfo
		for i = fluidStartBorder, fluidFinishBorder do
			local tank = tankFluidLevels[i]
			printTankInfo(component.proxy(tank.id), tank.name)
			fluidYValue = fluidYValue + 1
		end
	else	
		gpu.set(screenOuter["fluidLevels"].x + 2, screenOuter["fluidLevels"].y + 2, "There are no tanks entered!")	
	end

	-- To check if user entered only one energy source
	if #energy == 1 then
	
		-- Variables for calculating time to drain/fill
		local energyInfo = energyFiles.getEnergyInformation(LSC, energyMax, colors, timeToFillAVG, netEnergyAVG)
		timeToFillAVG = energyInfo.timeToFillAVG
		netEnergyAVG = energyInfo.netEnergyAVG
    
		-- Clear the area to allow for new information to be printed 
		gpu.fill(6,46, 95,2, " ")
	
		-- Draws the progress bar 
		utils.setBackgroundColor(7, 43, 148, 2, " ", utils.colors.turq)
		utils.setBackgroundColor(7, 43, energyInfo.progressBar, 2, " ", utils.colors.cyan)
	
		-- Prints Net Energy, Energy Level, Percent, and status
		utils.printColoredText(6, 46, "Net Energy: "..utils.comma_value(energyInfo.netEnergy).."eu/t", energyInfo.netEnergyColor)
		gpu.set(6, 47, "Energy Level: "..utils.comma_value(energyInfo.energyLevel).." / "..utils.comma_value(energyMax).."eu")
		gpu.set(75, 46, (string.format("%.2f", energyInfo.percent).."%"))
		energyFiles.problemCheck(LSC)
	
		-- To get a more accurate time to fill/drain, it collects inforamtion for 30 second before updating it
		if counter == 30 then
			energyFiles.displayEnergyInfo(energyInfo, netEnergyAVG, timeToFillAVG, colors)
			counter = 0
			timeToFillAVG = 0
			netEnergyAVG = 0
		end
		counter = counter + 1
	-- Checks for none / too many LSCs entered in energy.lua
	elseif #energy == 0 then
	gpu.set(screenOuter["energy"].x + 2, screenOuter["energy"].y + 2, "There is no LSC entered!")
	elseif #energy > 1 then
	gpu.set(screenOuter["energy"].x + 2, screenOuter["energy"].y + 2, "There are too many LSCs entered")
	end

	-- API.screen is used to iterate through all the buttons and fill the table in buttonAPI
	--API.screen()

	-- Wait 1 seconds before checking the status again
	os.sleep(1)

-- End of the while loop
end

while checkLoop do
    mainLoop()
end