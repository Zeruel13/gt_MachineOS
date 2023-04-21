--load requirements
local component = require("component")

--load files to read information from
local machines_chunk = loadfile("addressList/machines.lua")
local machines = machines_chunk()
local tanks_chunk = loadfile("addressList/tanks.lua")
local tanks = tanks_chunk()
local energy_chunk = loadfile("addressList/energy.lua")
local energy = energy_chunk()

local gtMachineFind = {}

function table.find(t, value)
  for i, v in ipairs(t) do
    if v == value then
      return i
    end
  end
  return nil
end

--create two tables, one to store what machines are in your list and one for what's on the network
local gt_machineList = {}
local gt_machineNetwork = {}
local gt_machineNew = {} 

--These three for loops add gt_machines from the three files to the gt_machineList table
for i, machine in ipairs(machines) do
	table.insert(gt_machineList , component.get(machine.id))
end

for i, tank in ipairs (tanks) do
	table.insert(gt_machineList , component.get(tank.id))
end

for i, energy in ipairs (energy) do
	table.insert(gt_machineList , component.get(energy.id))
end

--This goes through all components connected to your OC computer. If it has the name gt_machine, add it to the gt_machineNetwork table
for k, v in pairs(component.list()) do 
	if v == "gt_machine" then
		if component.type(k) == "gt_machine" and component.methods(k) and component.methods(k)["getOwnerName"] then
			table.insert(gt_machineNetwork, k)
		end
	end
end

--If a gt_machine is connected to the network but not in your list (not in a lua file yet), print the value
for i, value in ipairs(gt_machineNetwork) do
  if not table.find(gt_machineList, value) then
    table.insert(gt_machineNew, value)
  end
end

return gt_machineNew
