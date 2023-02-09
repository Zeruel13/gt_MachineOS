--This code is used to easily find what gt_machines are added to your code or not yet. 
--to use, type gtMachinelist.lua > output.txt
--this will generate a textfile in the same directory as this code 

--load requirements
local term = require("term")
local component = require("component")

--load files to read information from
local machines_chunk = loadfile("addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("addressList/tanks.lua")
local tanks = tanks_chunk()
local pinnedMachines_chunk = loadfile("addressList/pinnedMachines.lua")
local pinnedMachines = pinnedMachines_chunk()


function table.find(t, value)
  for i, v in ipairs(t) do
    if v == value then
      return i
    end
  end
  return nil
end

--clear the terminal
term.clear()

--create two tables, one to store what machines are in your list and one for what's on the network
gt_machineList = {}
gt_machineNetwork = {}

--These three for loops add gt_machines from the three files to the gt_machineList table
for i, machine in ipairs(machines) do
	table.insert(gt_machineList , component.get(machine.id))
end

for i, tank in ipairs (tanks) do
	table.insert(gt_machineList , component.get(tank.id))
end

for i, pinnedMachine in ipairs (pinnedMachines) do
	table.insert(gt_machineList , component.get(pinnedMachine.id))
end

--This goes through all components connected to your OC computer. If it has the name gt_machine, add it to the gt_machineNetwork table
for k, v in pairs(component.list()) do 
	if v == "gt_machine" then
		table.insert(gt_machineNetwork, k)
	end
end

--print formatting
print()
print("The following is not present in the compnent list and something has gone terribly wrong:")
print("-----------------------------")

--If a gt_machine is on your list (in one of the lua files but not connected to the network, print the value
for i, value in ipairs(gt_machineList) do
  if not table.find(gt_machineNetwork, value) then
    print(value)
  end
end

--print formatting
print("\nThe following is not present in the files and need to be filed:")
print("-----------------------------")

--If a gt_machine is connected to the network but not in your list (not in a lua file yet), print the value
for i, value in ipairs(gt_machineNetwork) do
  if not table.find(gt_machineList, value) then
    print(value)
  end
end

--print formatting
print()
print("\nThe following is present in both tables and nothing needs to be done:")
print("-----------------------------")

--if a gt_machine is connected to your network and on your list (in a lua file), print the value 
for i, value in ipairs(gt_machineList) do
  if table.find(gt_machineNetwork, value) then
    print(value)
  end
end
