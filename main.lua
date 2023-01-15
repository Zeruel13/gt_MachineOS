--MachineOS created by: Zeruel
--Ver 1.0

--Border code originally by Krakaen to use in 'OPENCOMPUTER AUTOMATION PROGRAM'
--buttonAPI ported to OC by MoparDan originally created by DireWolf20 for ComputerCraft

--components to require
local filesystem = require("filesystem")
local component = require("component")
local keyboard = require("keyboard")
local event = require("event")
local gpu = component.gpu

--require the buttonAPI module from buttonAPI.lua
API = require("buttonAPI")

--load the files that store machines / tank addresses
local machines_chunk = loadfile("machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("tanks.lua")
local tanks = tanks_chunk()
local pinnedMachines_chunk = loadfile("pinnedMachines.lua")
local pinnedMachines = pinnedMachines_chunk()

--This line creates a new table called machineFunctions, which will be used to store the proxy objects for each machine.
local machineList = {}
local tankList = {}
local pinnedMachineList = {}

--This for loop iterates through the machines list from lcrList
--For each iteration of the loop, the code creates a new entry in the machineFunctions table, using the name field of the machine table as the key and a proxy object for the machine as the value
for i, machine in ipairs(machines) do
  machineList[machine.name] = component.proxy(component.get(machine.id))
end

--Same as above but for the Pinned Machines
for i, pinnedMachine in ipairs(pinnedMachines) do
  pinnedMachineList[pinnedMachine.name] = component.proxy(component.get(pinnedMachine.id))
end

--Same as above but for the tanks
for i, tank in ipairs (tanks) do
	tankList[tank.name] = component.proxy(component.get(tank.id))
end

--initializes some colors to use 
local colors = { blue = 0x0096FF, blue2 = 0x0047AB, purple = 0x884EA0, red = 0xC14141, green = 0xDA841,
  black = 0x000000, white = 0xFFFFFF, grey = 0x47494C, lightGrey = 0xBBBBBB, pastelRed = 0xFAA0A0, orange = 0xF28C28, yellow = 0xFFBF00}

--gets the number of pages needed for multiblockInformation
local numPage = math.ceil(#machines/12)
local setPage = numPage

--create a table for button that will be used to store all the buttons. used in buttonAPI.lua
button = {}

--this function is running multiple times then multiple times
function createMachineButtons (pgX, i)

	API.setTable("page"..i, pageMachineButton, pgX+1, 35, pgX+3, 35, tostring(setPage), {on = colors.black, off = colors.yellow})
	setPage = setPage -1

end

--when the program starts, it will always start and print the first page 
local start = 1
local printPage = 1

--this variable will be used to determine when the list of multiblocks should stop. 
local finish

--if the number of machines is less than twelve, set finish to twelve. 
if #machines < 13 then
	finish = #machines
else
	finish = 12
end

--this variable will temporarily store machine[i] values later to use in currentMachineName. Used for printing border titles
local machine

--initiazling variables. ScreenInner controle how many machine borders are printed YVariance and YVarianceRight are used to determine Y values for printing machine info
local screenInner = {}
local yVar = 0
local yVarR = 0

--this function will be called everytime a button is hit.  
function pageMachineButton(text)

		printPage = text
		start = (printPage - 1) * 12 + 1
		finish = start + 11	
		
		--resetting variables and emptying screenInner. screenInner controls how many borders are printed so it has to be reset. 
		yVar = 0
		yVarR = 0
		screenInner = {}
		
		--clear the area where the Multiblock Information is set 
		gpu.fill(5, 3, 73, 31, " ")
		
		--calls the drawMachineBorder function. This is what actually prints the borders 
		drawMachineBorder()
		
		--prints the name of each border 
		for name, data in pairs(screenInner) do
			printBordersInner(name)
		end
		
end

--initalizes screenOuter table to add entries to later
local screenOuter = {}

--adds all the borders to the screenOuter table	
function setScreenOuter()
	screenOuter["multiblockInformation"] = { x = 3, y = 2, width = 78, height= 35, title = "  Multiblock Information  "}
	screenOuter["pinnedMachines"] = { x = 85, y = 2, width = 45, height = 20, title = "  Pinned Machines  "}
	screenOuter["info"] = { x = 85, y = 24, width = 45, height= 13, title = "  Fluid Levels  "}
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
	gpu.setBackground(colors.blue2)
	gpu.fill(sO.x, sO.y, sO.width, 1, " ")
	gpu.fill(sO.x, sO.y, 1, sO.height, " ")
	gpu.fill(sO.x, sO.y + sO.height, sO.width, 1, " ")
	gpu.fill(sO.x + sO.width, sO.y, 1, sO.height + 1, " ")
  
	-- set title
	gpu.setBackground(colors.black)
	gpu.setForeground(colors.blue2)
	gpu.set(sO.x + 4, sO.y, sO.title)
	gpu.setForeground(colors.white)
	
end

-- get the dimensions of the pinnedMachines section. 
local x = screenOuter["pinnedMachines"].x + 2
local y = screenOuter["pinnedMachines"].y + 1
	
gpu.set(x, y+18, "Created by: Zeruel    ⠀⠀⠀  ⠀⠀⠀⠀⠀   Ver 1.0⠀")
	
--quick and dirty way to print pinned machine info. Will be cleaned up in future versions
local pinnedMachineY = 0
local pinnedMachineX = x
for i = 1, #pinnedMachines do
	gpu.setForeground(colors.yellow)
	gpu.set(x+5, y+1+pinnedMachineY, "╭──────────────────────────────╮")
	gpu.set(x+5, y+2+pinnedMachineY, "│                              │")
	gpu.set(x+5, y+3+pinnedMachineY, "│                              │")
	gpu.set(x+5, y+4+pinnedMachineY, "│                              │")
	gpu.set(x+5, y+5+pinnedMachineY, "╰──────────────────────────────╯")
	pinnedMachineY = pinnedMachineY + 5
end
	
--print the title. Again, quick and dirty to be updated later. 
gpu.setForeground(colors.purple)
gpu.set(pinnedMachineX+8, y+1, " Cleanroom ")
gpu.setForeground(colors.white)
	
	
	
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

-- indent the text by 2 spaces from the left side of the section
local x = screenOuter["info"].x + 2 
-- start the text at the top of the section
local y = screenOuter["info"].y + 1 

--this function adds table values to sceenInner. Differs if it's on the left or right side. 
local function setScreenInner(currentMachineName, i)
	
	--If there is more than one page, i will be greater than 12. Subtracts 12
	if i > 12 then	
		i = i-12
	end
	
	--Controls the 6 left boxes
	if(math.ceil(i/6) % 2) == 1 then
		screenInner[tostring(currentMachineName)] = {x = 7, y = 4+yVar, width = 33, height = 4, title = " "..tostring(currentMachineName).." "}
			
	else
			
		--controls the 6 right boxes
		screenInner[tostring(currentMachineName)] = {x = 44, y = 4+yVarR, width = 33, height = 4, title = " "..tostring(currentMachineName).." "}
		yVarR = yVarR + 5
				
	end
		
	--adds 5 so next time this is called, it'll print 5 lines lower. 
	yVar = yVar + 5
		
end

--function to draw the borders of each machines 
function drawMachineBorder()
	
	local startBorder = (printPage - 1) * 12 + 1
	local finishBorder = math.min(printPage * 12, #machines)

	for i = startBorder, finishBorder do
    -- access and display the machine at index i
	machine = machines[i]
	local currentMachineName = machine.name
	--this line adds the the name of the machines to the screenInner table
		setScreenInner(currentMachineName, i)
    
	end 
end

--calls the function drawMachineBorder
drawMachineBorder()
	
	function printBordersInner(screenInnerName)
	
		local sI = screenInner[screenInnerName]
		
			gpu.setForeground(colors.yellow)
		
			--top horizontal
			gpu.fill(sI.x, sI.y, sI.width, 1, "─")
		
		
			--left vertical
			gpu.fill(sI.x, sI.y, 1, sI.height, "│")
			gpu.set(sI.x, sI.y, "╭")
		
			--bottom Horiztonal
			gpu.fill(sI.x, sI.y + sI.height, sI.width, 1, "─")
			gpu.set(sI.x, sI.y+4, "╰")
		
			--right vertical
			gpu.fill(sI.x + sI.width, sI.y, 1, sI.height + 1, "│")
			gpu.set(sI.x + sI.width, sI.y, "╮")
			gpu.set(sI.x + sI.width, sI.y+4, "╯")
			
			gpu.setForeground(colors.white)
		
 
			-- set title
			gpu.setBackground(colors.black)
			gpu.setForeground(colors.purple)
			gpu.set(sI.x + 4, sI.y, sI.title)
			gpu.setForeground(colors.white)
			
	end
  
--these two for loops iterates through the tables screenOuter and sceenInner and displays all the sections for each. 
--i.e. This will print the borders and the titles of the borders. 
for name, data in pairs(screenOuter) do
	printBordersOuter(name)
end
  
   for name, data in pairs(screenInner) do
	
	printBordersInner(name)
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

--everything inside this while loop will run every 0.5 seconds by os.sleep(0.5)
while true do 

	--code for adding problems up. problems wille be printed at the end 
	local problems = 0
	gpu.set(7, 35, "                         ")
	for i, machine in ipairs (machines) do
		--print(machine.id)
		if (component.proxy(component.get(machine.id)).isWorkAllowed()) == false or string.match(tostring(component.proxy(component.get(machine.id)).getSensorInformation()[5]), "§c(%d+)")  ~= "0" then
			--print("problem has occured")
			problems = problems + 1
		end
	end

	--This is so finish will be the print the last element in machine 
	if #machines < finish then
			finish = #machines
	end
	
	--this sets the fluid level area blank. Allows for new information to be printed every second.
	gpu.fill(87, 26, 42, 10, " ")
	
	local gpuX = 9
	local gpuY = 5
	
	--This sets the inner borders of each multiblockInformation blank. It clears the first six then if it's the 7nth
	--changes the x and y values and continues to print blank
	for i = start, finish do
		machine = machines [i]
		if(i == 7) then
			gpuY = 5
			gpuX = 46
		end
		gpu.fill(gpuX, gpuY, 30, 2, " ")
		gpuY = gpuY + 5
	end
	
	--setting the Fluid Levels area with text
	gpu.set(x, y+1, "Oxygen: "..(getFluidLevels(tankList["Oxygen"].getSensorInformation()[4])))
	gpu.set(x, y+2, "Fluid: 2")
	gpu.set(x, y+3, "Fluid: 3")
	gpu.set(x, y+4, "Fluid: 4")
	gpu.set(x, y+5, "Fluid: 5")
	gpu.set(x, y+6, "Fluid: 6")
	gpu.set(x, y+7, "Fluid: 7")
	gpu.set(x, y+8, "Fluid: 8")
	gpu.set(x, y+9, "Fluid: 9")
	gpu.set(x, y+10, "Fluid: 10")

	--for future versions, adding pages to Fluid Levels
	--[[local fluidPageX = 124
	for i = 2, 1, -1 do
		gpu.set(fluidPageX, 34, "╭───╮")
		gpu.set(fluidPageX, 35, "│ 2 │")
		gpu.set(fluidPageX, 36, "╰───╯")
		fluidPageX = fluidPageX - 5
	fluidPageX]]

	--this variable decides what y-level to print out each machine's information. This goes up by 5 after each iteration
	yVar = 0	
	local xVar = 2
	
	--This clears the Pinned Machines area to allow new information to be printed every 0.5 seconds
	pinnedMachineY = 0
	for i = 1, 3, 1 do
		gpu.fill(pinnedMachineX+6, 5+pinnedMachineY, 30, 2, " ")
		pinnedMachineY = pinnedMachineY +5
	end
	
	--quick and dirty way of printing a pinnedMachine info. This is for a cleanroom. Change the name "Cleanroom" to whatever your id is in pinnedMachines
	--if the number of problems is equal to 0
	if (string.match(tostring(pinnedMachineList["Cleanroom"].getSensorInformation()[5]), "§c(%d+)")) == "0" then
		if (pinnedMachineList["Cleanroom"].isWorkAllowed()) == true then
			if(pinnedMachineList["Cleanroom"].isMachineActive()) == true then
				gpu.setForeground(colors.green)
				gpu.set(pinnedMachineX+7, 5,"Machine go Brrrrrrr")

				gpu.setForeground(colors.white)
				gpu.set(pinnedMachineX+7, 6,(string.gsub(pinnedMachineList["Cleanroom"].getSensorInformation()[1], "§.","")))
			else
				gpu.setForeground(colors.orange)
				gpu.set(pinnedMachineX+7, 5,"Machine Status: IDLE")
				gpu.setForeground(colors.white)
					
			end	
		else
				gpu.setForeground(colors.red)
				gpu.set(pinnedMachineX+7, 5,"Machine processing diabled!!")
				gpu.setForeground(colors.white)
					
		end
	--if the number of problem isn't equal to 0 
	else
		gpu.setForeground(colors.red)
		gpu.set(pinnedMachineX+7, 5,"MACHINE HAS PROBLEMS!!!")
		gpu.setForeground(colors.white)
		gpu.set(pinnedMachineX+7, 6,"")
					
	end
	
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
					gpu.set(7+xVar, i*5,"Machine processing diabled!!")
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
	local function printTankInfo(tank, i)
		gpu.set(7+xVar, i*5+2, getFluidLevels(tank.getSensorInformation()[4]))
	end

	
	--get the name of the machine at the start - finish index for the machines table. 
	for i = start, finish do
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
				printTankInfo(component.proxy(component.get(tank.id)), i)
			end

		end
		
	    -- go up by 5 each time
		yVar = yVar + 5	
		
	end
		--reset the y value to 0 to correct itself once the while loop runs again
		local yVar = 0
	
	--Once the # of problems is added up, print it
	gpu.set(7, 35, "Number of Problems: "..problems)
	
	--This checks if a user touches the screen then calls API.checkxy
	event.listen("touch", API.checkxy)

  -- Wait 0.5 seconds before checking the status again
  os.sleep(0.5)

--end of the while loop
end