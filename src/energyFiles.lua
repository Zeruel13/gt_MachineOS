-- Require utils from utils.lua
local utils = require("gt_MachineOS/utils")

-- Components to require
local component = require("component")
local gpu = component.gpu

local energyFiles = {}

-- Returns energy information
function energyFiles.getEnergyInformation(LSC, energyMax, colors, timeToFillAVG, netEnergyAVG)
    -- Extract energy input and output values from sensor information
    local energyInput = string.match(LSC.getSensorInformation()[7], "%d[%d,]*")
    local energyOutput =  string.match(LSC.getSensorInformation()[8], "%d[%d,]*")
    -- Calculate net energy and energy per second
    local netEnergy = math.floor((string.gsub(energyInput, ",", "")) - (string.gsub(energyOutput, ",", "")))
    local energyPerSecond = netEnergy*20
    
    -- Extract energy level and calculate time to fill
    local energyLevel = math.floor(string.gsub(LSC.getSensorInformation()[2], "([^0-9]+)", "") + 0)
    local timeToFill = math.huge
    if netEnergy ~= 0 then
        timeToFill = math.floor((netEnergy > 0 and energyMax - energyLevel or energyLevel) / math.abs(energyPerSecond))
    end
    
    -- Calculate progress, percent and progress bar
    local progress = energyLevel/energyMax
    local percent = progress*100
    local progressBar = tonumber(string.format("%.2f", progress*148))

    -- Determine net energy color
    local netEnergyColor
	if netEnergy > 0 then
		netEnergyColor = utils.colors.green
    else
        netEnergyColor = utils.colors.red
    end

    -- Update time to fill average and net energy average
    if timeToFill ~= math.huge and timeToFill ~= -math.huge then
        timeToFillAVG = timeToFillAVG + timeToFill
        netEnergyAVG = netEnergyAVG + netEnergy
    end

    -- Return energy information
    return {
        netEnergy = netEnergy,
        timeToFill = timeToFill,
        energyLevel = energyLevel,
        percent = percent,
        progressBar = progressBar,
        netEnergyColor = netEnergyColor,
        timeToFillAVG = timeToFillAVG,
        netEnergyAVG = netEnergyAVG
    }
end

-- Displays energy information
function energyFiles.displayEnergyInfo(energyInfo, netEnergyAVG, timeToFillAVG, colors)
    -- Clear energy info area
    gpu.fill(85, 46, 70, 1, " ")
    -- Calculate time to fill average
    timeToFillAVG = timeToFillAVG / 30
    -- Display appropriate message based on energy level
    if (energyInfo.percent > 99.99) then
        utils.printColoredText(156 - #"Full!", 46, "Full!", utils.colors.green)
    elseif (energyInfo.percent < 0.01) then
        utils.printColoredText(156 - #"Empty!", 46, "Empty!", utils.colors.red)
    elseif (netEnergyAVG > 0) then
        timeToFillAVGText = "Time to fill: "..utils.formatTime(timeToFillAVG)
        timeToFillAVGX = 156 - #timeToFillAVGText
        utils.printColoredText(timeToFillAVGX, 46, timeToFillAVGText, utils.colors.green)
     elseif (netEnergyAVG < 0) then
        timeToFillAVGText = "Time to drain: "..utils.formatTime(timeToFillAVG)
        timeToFillAVGX = 156 - #timeToFillAVGText
        utils.printColoredText(timeToFillAVGX, 46, timeToFillAVGText, utils.colors.red)
    end
end

function energyFiles.problemCheck(LSC)
	-- get the maintenance status 
	status = LSC.getSensorInformation()[9]:gsub(".*§a(.-)§r.*", "%1")
	if status == "Working perfectly" then
		if LSC.isWorkAllowed() == true then
			utils.printColoredText(78 - #status/2, 47, status, utils.colors.green)
		else
			utils.printColoredText(78 - #status/2, 47, "Processing Disabled!", utils.colors.red)
		end
	else
		utils.printColoredText(70, 47, "Has Problems!!!", utils.colors.red)
	end
end

return energyFiles