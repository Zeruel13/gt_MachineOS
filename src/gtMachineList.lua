--This code is used to easily find what gt_machines are added to your code or not yet. 
--to use, type gtMachinelist.lua > output.txt
--this will generate a textfile in the same directory as this code 

--load requirements
local term = require("term")
local component = require("component")

--load files to read information from
local machines_chunk = loadfile("gt_MachineOS/addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("gt_MachineOS/addressList/tanks.lua")
local tanks = tanks_chunk()
local energy_chunk = loadfile("gt_MachineOS/addressList/energy.lua")
local energy = energy_chunk()


function table.find(t, id)
  for i, v in ipairs(t) do
    if v.id == id then
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
gt_machineNil = {}

--These three for loops add gt_machines from the three files to the gt_machineList table
for i, machine in ipairs(machines) do
	if component.get(machine.id) ~= nil then
		table.insert(gt_machineList , {name = machine.name, id = component.get(machine.id)})
	else
		table.insert(gt_machineNil , machine.id)
	end
end

for i, tank in ipairs (tanks) do
	if component.get(tank.id) ~= nil then
		table.insert(gt_machineList , {name = tank.name, id = component.get(tank.id)})
	else
		table.insert(gt_machineNil , tank.id)
		
	end
end

for i, energy in ipairs (energy) do
	if component.get(energy.id) ~= nil then
		table.insert(gt_machineList , {name = energy.name, id = component.get(energy.id)})
	else
		table.insert(gt_machineNil , energy.id)
	end
end

--This goes through all components connected to your OC computer. If it has the name gt_machine, add it to the gt_machineNetwork table
for k, v in pairs(component.list()) do 
	if v == "gt_machine" then
		if component.type(k) == "gt_machine" and component.methods(k) and component.methods(k)["getOwnerName"] then
			table.insert(gt_machineNetwork, k)
		end
	end
end

--print formatting
print()
print("The following is not present in the compnent list and something has gone terribly wrong:")
print("-----------------------------")

--If a gt_machine is on your list (in one of the lua files but not connected to the network, print the value
for i, value in ipairs(gt_machineNil) do
    print(value)
end

--print formatting
print("\nThe following is not present in the files and need to be filed:")
print("-----------------------------")

--If a gt_machine is connected to the network but not in your list (not in a lua file yet), print the value
for i, value in ipairs(gt_machineNetwork) do
  local index = table.find(gt_machineList, value)
  if not index then
    print(value)
  end
end


--print formatting
print()
print("\nThe following is present in both tables and nothing needs to be done:")
print("-----------------------------")

--if a gt_machine is connected to your network and on your list (in a lua file), print the value and its name
for i, value in ipairs(gt_machineNetwork) do
  local index = table.find(gt_machineList, value)
  if index then
    local name = gt_machineList[index].name
    print(name, value)
  end
end

