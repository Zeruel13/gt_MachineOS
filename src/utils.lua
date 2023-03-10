-- Components to require
local component = require("component")
local gpu = component.gpu

-- Initializes some colors to use 
colors = {
	blue = 0x1434A4, -- old blue
	purple = 0x884EA0,
	red = 0xC14141,
	green = 0xDA841,
	black = 0x000000,
	white = 0xFFFFFF,
	orange = 0xF28C28,
	yellow = 0xFFBF00,
	cyan = 0x00FFFF,
	turq = 0x008B8B
}

-- Print colored text	
function printColoredText(x, y, text, color)
  local oldColor = gpu.getForeground()
  gpu.setForeground(color)
  gpu.set(x, y, text)
  gpu.setForeground(oldColor)
end

-- Set background colors
function setBackgroundColor(x, y, width, height, text, color)
	local oldBackground = gpu.getBackground()
	gpu.setBackground(color)
	gpu.fill(x, y, width, height, text)
	gpu.setBackground(oldBackground)
end

-- Draw a yellow border	
function drawBorder(x, y, width, height)

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

-- Change a number into comma format
-- ex. 400000 -> 400,000
function comma_value(amount)

    -- Check if the number is negative
    local negative = amount < 0 

    -- Convert to positive for formatting
    local formatted = tostring(math.abs(amount)) 

    local k

    -- Format the number with commas for thousands separators
    while true do
		-- Add a comma to the number string if it has at least 4 digits to the left
        formatted, k = formatted:gsub("^(%d+)(%d%d%d)", '%1,%2')

        -- If no commas were added, break out of the loop
        if k == 0 then
            break
        end
    end

    -- Add negative sign back to the formatted number if it was negative
    if negative then
        formatted = '-' .. formatted 
    end

    return formatted
end

-- Given seconds, change into readable time
function formatTime(time)
	-- Check if time value is valid
	if not time or time == math.huge or time == -math.huge then
		return "N/A"
	end

	-- Calculate time units
	local weeks = math.floor(time / 604800)
	local days = math.floor((time % 604800) / 86400)
	local hours = math.floor((time % 86400) / 3600)
	local minutes = math.floor((time % 3600) / 60)

	local output = ""

	-- Add weeks if any
	if weeks > 0 then
		output = string.format("%d week%s", weeks, weeks > 1 and "s" or "")
		if days > 0 or hours > 0 or minutes > 0 then
			output = output .. ", "
		end
	end

	-- Add days if any
	if days > 0 then
		output = output .. string.format("%d day%s", days, days > 1 and "s" or "")
		if hours > 0 or minutes > 0 then
			output = output .. ", "
		end
	end

	-- Add hours if any
	if hours > 0 then
		output = output .. string.format("%d hour%s", hours, hours > 1 and "s" or "")
		if minutes > 0 and (weeks > 0 or days > 0 or hours > 0) then
			output = output .. ", "
		end
	end

	-- Add minutes if any
	if minutes > 0 then
		output = output .. string.format("%d minute%s", minutes, minutes > 1 and "s" or "")
	end

	-- Add a default value for cases when time is less than one minute
	if output == "" then
		output = "Less than one minute"
	end

	-- Return formatted time string
	return output
end

-- prints AsciiArt
function printAsciiArt(x, y, art)
	local rows = {}
	local i = 1
	art:gsub("[^\n]+", function(row)
		rows[i] = row
		i = i + 1
	end)
	gpu.setForeground(colors.cyan)
	for i, row in ipairs(rows) do
		for j = 1, #row do
			gpu.set(x + j - 1, y + i - 1, row:sub(j, j))
		end
	end
	gpu.setForeground(colors.white)
end

-- Returns Utilities
return {
	colors = colors,
	printColoredText = printColoredText,
	setBackgroundColor = setBackgroundColor,
	drawBorder = drawBorder,
	comma_value = comma_value,
	formatTime = formatTime,
	printAsciiArt = printAsciiArt
}
