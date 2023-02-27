--components to require
local component = require("component")
local gpu = component.gpu

local energyFiles = {}

function energyFiles.getEnergyInformation(LSC, energyMax, colors, timeToFillAVG, netEnergyAVG)
	local energyInput = string.match(LSC.getSensorInformation()[7], "%d[%d,]*")
	local energyOutput =  string.match(LSC.getSensorInformation()[8], "%d[%d,]*")
	local netEnergy = math.floor((string.gsub(energyInput, ",", "")) - (string.gsub(energyOutput, ",", "")))
	local energyPerSecond = netEnergy*20
	
	local energyLevel = math.floor(string.gsub(LSC.getSensorInformation()[2], "([^0-9]+)", "") + 0)

	local timeToFill = math.huge
	if netEnergy ~= 0 then
		timeToFill = math.floor((netEnergy > 0 and energyMax - energyLevel or energyLevel) / math.abs(energyPerSecond))
	end
	
	local progress = energyLevel/energyMax
	local percent = progress*100
	local progressBar = tonumber(string.format("%.2f", progress*148))

	local netEnergyColor
	if netEnergy > 0 then
		netEnergyColor = colors.green
	else
		netEnergyColor = colors.red
	end

	if timeToFill ~= math.huge and timeToFill ~= -math.huge then
		timeToFillAVG = timeToFillAVG + timeToFill
		netEnergyAVG = netEnergyAVG + netEnergy
	end

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

function energyFiles.displayEnergyInfo(energyInfo, netEnergyAVG, timeToFillAVG, colors)
    gpu.fill(85, 46, 70, 1, " ")
    timeToFillAVG = timeToFillAVG / 30
    if (energyInfo.percent > 99.99) then
        printColoredText(156 - #"Full!", 46, "Full!", colors.green)
    elseif (energyInfo.percent < 0.01) then
        printColoredText(156 - #"Empty!", 46, "Empty!", colors.red)
    elseif (netEnergyAVG > 0) then
        timeToFillAVGText = "Time to fill: "..formatTime(timeToFillAVG)
        timeToFillAVGX = 156 - #timeToFillAVGText
        printColoredText(timeToFillAVGX, 46, timeToFillAVGText, colors.green)
    elseif (netEnergyAVG < 0) then
        timeToFillAVGText = "Time to drain: "..formatTime(timeToFillAVG)
        timeToFillAVGX = 156 - #timeToFillAVGText
        printColoredText(timeToFillAVGX, 46, timeToFillAVGText, colors.red)
    end
end

return energyFiles