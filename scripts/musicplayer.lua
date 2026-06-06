local function get_command_output(command)
    local handle = io.popen(command .. " 2>/dev/null")
    if not handle then return "" end
    local result = handle:read("*a")
    handle:close()
    return result:gsub("%s+$", "")
end

local function get_terminal_width()
    local output = get_command_output("tput cols")
    local width = tonumber(output)
    if not width or width <= 0 then return 80 end
    return width
end

local function center_text(text, width)
    local lines = {}
    for line in string.gmatch(text .. "\n", "(.-)\n") do
        -- Strip leading/trailing spaces for proper calculation
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        -- Note: #trimmed counts bytes; for heavy Unicode/Emoji, centering may be slightly off
        local padding = math.max(0, math.floor((width - #trimmed) / 2))
        table.insert(lines, string.rep(" ", padding) .. trimmed)
    end
    return table.concat(lines, "\n")
end

local function create_progress_bar(width)
    local status = get_command_output("playerctl status")
    if status == "" or status == "Stopped" then 
        return "[ No Media Playing ]" 
    end

    local pos_str = get_command_output("playerctl position")
    local dur_str = get_command_output("playerctl metadata mpris:length")
    
    local position = tonumber(pos_str) or 0
    local duration = (tonumber(dur_str) or 0) / 1000000 

    if duration <= 0 then return "[ Live ]" end

    local bar_max_width = math.floor(width * 0.4)
    local progress = math.min(1, position / duration)
    local filled = math.floor(bar_max_width * progress)
    local empty = bar_max_width - filled

    local bar = "[" .. string.rep("#", filled) .. string.rep("-", empty) .. "]"
    local time_info = string.format(" %d:%02d / %d:%02d", 
        math.floor(position/60), math.floor(position%60), 
        math.floor(duration/60), math.floor(duration%60))
    
    return bar .. time_info
end

local function main()
    local width = get_terminal_width()
    
    local art = [[
 
	⠀⠀⠀⢠⡾⠲⠶⣤⣀⣠⣤⣤⣤⡿⠛⠿⡴⠾⠛⢻⡆⠀⠀⠀
	⠀⠀⠀⣼⠁⠀⠀⠀⠉⠁⠀⢀⣿⠐⡿⣿⠿⣶⣤⣤⣷⡀⠀⠀
	⠀⠀⠀⢹⡶⠀⠀⠀⠀⠀⠀⠌⢯⣡⣿⣿⣀⣸⣿⣦⢓⡟⠀⠀
	⠀⠀⢀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠹⣍⣭⣾⠁⠀⠀
	⠀⣀⣸⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣸⣷⣤⡀
	⠈⠉⠹⣏⡁⠀⢸⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⢀⣸⣇⣀⠀
	⠀⠐⠋⢻⣅⣄⢀⣀⣀⡀⠀⠯⠽⠀⢀⣀⣀⡀⠀⣤⣿⠀⠉⠀
	⠀⠀⠴⠛⠙⣳⠋⠉⠉⠙⣆⠀⠀⢰⡟⠉⠈⠙⢷⠟⠉⠙⠂⠀
	⠀⠀⠀⠀⠀⢻⣄⣠⣤⣴⠟⠛⠛⠛⢧⣤⣤⣀⡾⠀⠀⠀⠀⠀]]

    local title = get_command_output("playerctl metadata xesam:title")
    if title == "" then title = "Nothing Playing" end

    local progress_bar = create_progress_bar(width)

    -- Clear terminal and print output
    io.write("\027[H\027[2J")
    print("\n" .. center_text(art, width))
    print("\n" .. center_text(title, width))
    print(center_text(progress_bar, width))
end

main()
