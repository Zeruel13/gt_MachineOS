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


--initializes some colors to use 
local colors = {
	blue = 0x0047AB,
	purple = 0x884EA0,
	red = 0xC14141,
	green = 0xDA841,
	black = 0x000000,
	white = 0xFFFFFF,
	orange = 0xF28C28,
	yellow = 0xFFBF00
}

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
	screenOuter["multiblockInformation"] = { x = 3, y = 2, width = 78, height= 35, title = "  Multiblock Information  "}
	screenOuter["pinnedMachines"] = { x = 85, y = 2, width = 45, height = 20, title = "  Pinned Machines  "}
	screenOuter["fluidLevels"] = { x = 85, y = 24, width = 45, height= 13, title = "  Fluid Levels  "}
end

  
-- set size of the screen for lvl 3 and clear the screen
gpu.setResolution(132,38)
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
	gpu.setForeground(colors.blue)
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
local machineXOffset = 37
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
	
local function drawHorizontalLine(x, y, width)
  gpu.fill(x, y, width, 1, "─")
end

local function drawVerticalLine(x, y, height)
  gpu.fill(x, y, 1, height, "│")
end

local function drawCorner(x, y, char)
  gpu.set(x, y, char)
end

local function printBordersInner(i)

  local sI = screenInner[i]

  gpu.setForeground(colors.yellow)

  drawHorizontalLine(sI.x, sI.y, sI.width)
  drawVerticalLine(sI.x, sI.y, sI.height)
  drawCorner(sI.x, sI.y, "╭")
  drawHorizontalLine(sI.x, sI.y + sI.height, sI.width)
  drawCorner(sI.x, sI.y + sI.height, "╰")
  drawVerticalLine(sI.x + sI.width, sI.y, sI.height + 1)
  drawCorner(sI.x + sI.width, sI.y, "╮")
  drawCorner(sI.x + sI.width, sI.y + sI.height, "╯")

  gpu.setForeground(colors.white)

  gpu.setForeground(colors.purple)
  gpu.set(sI.x + 2, sI.y, sI.title)
  gpu.setForeground(colors.white)
  
end
  
--these two for loops iterates through the tables screenOuter and sceenInner and displays all the sections for each. 
--i.e. This will print the borders and the titles of the borders. 
for name, data in pairs(screenOuter) do
	printBordersOuter(name)
end

local printPage = 1
local startBorder = (printPage - 1) * 12 + 1
local finishBorder = math.min(printPage * 12, #machines) 

for i = startBorder, finishBorder do
	printBordersInner(i) 
end

--this function correctly prints fluid level sensor information
function getFluidLevels(output)
    fluidLevel = string.match(output, "^[^L]*")
    fluidLevel = string.gsub(fluidLevel, "§a", "")
    fluidMax = string.match(output, "L[^L]*")
    fluidMax = string.gsub(fluidMax, "L§r", "")
    fluidMax = string.gsub(fluidMax, "§e", "")
    return fluidLevel.."/"..fluidMax.."mb"
end

--gets the number of pages needed for multiblockInformation
local numPage = math.ceil(#machines/12)
local setPage = numPage

--this function is running multiple times then multiple times
function createMachineButtons (pgX, i)
	API.setTable("page"..i, pageMachineButton, pgX+1, 35, pgX+3, 35, tostring(setPage), {on = colors.black, off = colors.yellow})
	setPage = setPage -1
end

--this function will be called everytime a button is hit.  
function pageMachineButton(text)

		printPage = text
		
		startBorder = (printPage - 1) * 12 + 1
		finishBorder = math.min(printPage * 12, #machines)

		--clear the area where the Multiblock Information is set 
		gpu.fill(5, 3, 73, 31, " ")
		
		--prints the name of each border 
		for i = startBorder, finishBorder do
			printBordersInner(i)
		end
		
end
	
--where to start the outline of the first button. Will always be the same
pgX = 73

--This loop will run for as many pages there are. Each time it runs, it reduces the number of pages left by 1 and decrease the x value (where to start drawing the border by 5)
gpu.setForeground(colors.yellow)
for i = numPage, 1, -1 do
	gpu.set(pgX, 34, "╭───╮")
	gpu.set(pgX, 35, "│   │")
	gpu.set(pgX, 36, "╰───╯")
	createMachineButtons(pgX, i)
	pgX = pgX - 5
end
gpu.setForeground(colors.white)
	
--API.screen is used to iterate through all the buttons and fill the table in buttonAPI
API.screen()	

--This checks if a user touches the screen then calls API.checkxy
event.listen("touch", API.checkxy)


local function printTankInfo(tank, tankValue, tankName)
	gpu.set(fluidLevelX, fluidLevelY+tankValue, tankName..": "..getFluidLevels(tank.getSensorInformation()[4]))
end

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
	
	--this sets the fluid level area blank. Allows for new information to be printed every second.
	gpu.fill(87, 26, 42, 10, " ")
	
	local gpuX = 9
	local gpuY = 5
	
	--This sets the inner borders of each multiblockInformation blank. It clears the first six then if it's the 7nth
	--changes the x and y values and continues to print blank
	for i = startBorder, finishBorder do
	
		--If there is more than one page, i will be greater than 12. Subtracts 12
		if i > 12 then	
			i = i-12
		end
		
		--To start printing the right boxes
		if(i == 7) then
			gpuY = 5
			gpuX = 46
		end
		
		gpu.fill(gpuX, gpuY, 30, 3, " ")
		gpuY = gpuY + 5

	end

	local tankValue = 0 
	for i, tank in ipairs(tanks) do
		found = false
			for g, machine in ipairs(machines) do
				if(tank.name == machine.name) then
					found = true
					break
				end
			end
		if not found then 
			tankValue = tankValue + 1
			tankName = tank.name
			printTankInfo(component.proxy(component.get(tank.id)), tankValue, tankName)
		end
	end

	--this variable decides what y-level to print out each machine's information. This goes up by 5 after each iteration
	local xVar = 2
	
	--this function prints all the MultiBlock Information. 
	local function printMachineMethods(machine, i)
	
		--if i is greater than 6, it needs to print on the right side. Change the X value to 39. 
		--also subtracts 6 to start at the top as i is multiple for the y value in gpu.set
		if(i>6) then
			i = i-6
			xVar = 39
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

	
	--get the name of the machine at the start - finish index for the machines table. 
	for i = startBorder, finishBorder do
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
