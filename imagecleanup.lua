local ITEMS_FILE = "resources/[ox]/ox_inventory/data/items.lua"
local WEAPONS_FILE = "resources/[ox]/ox_inventory/data/weapons.lua"
local IMAGES_FOLDER = "resources/[ox]/ox_inventory/web/images/"

RegisterCommand("cleanupimages", function(source, args)
    if source ~= 0 then
        print("This command can only be run from server console.")
        return
    end

    local function readFile(path)
        local f = io.open(path, "r")
        if not f then
            print("ERROR: Could not read " .. path)
            return ""
        end
        local data = f:read("*all")
        f:close()
        return data
    end

    -- Collect used images from items.lua and weapons.lua
    local used = {}
    for _, path in ipairs({ITEMS_FILE, WEAPONS_FILE}) do
        local data = readFile(path)
        for img in data:gmatch('image%s*=%s*"([^"]+)"') do
            used[img:lower() .. ".png"] = true
            used[img:lower() .. ".jpg"] = true
            used[img:lower() .. ".jpeg"] = true
        end
        for name in data:gmatch("%[%'([^']+)%'%]") do
            used[name:lower() .. ".png"] = true
            used[name:lower() .. ".jpg"] = true
            used[name:lower() .. ".jpeg"] = true
        end
        for name in data:gmatch('%["([^"]+)"%]') do
            used[name:lower() .. ".png"] = true
            used[name:lower() .. ".jpg"] = true
            used[name:lower() .. ".jpeg"] = true
        end
        for name in data:gmatch('name%s*=%s*"([^"]+)"') do
            used[name:lower() .. ".png"] = true
            used[name:lower() .. ".jpg"] = true
            used[name:lower() .. ".jpeg"] = true
        end
    end

    -- Scan images folder
    local p = io.popen('dir "' .. IMAGES_FOLDER .. '" /b')
    local unused = {}
    for file in p:lines() do
        if file:match("%.png$") or file:match("%.jpg$") or file:match("%.jpeg$") then
            if not used[file:lower()] then
                table.insert(unused, file)
            end
        end
    end
    p:close()

    if #unused == 0 then
        print("No unused images found.")
        return
    end

    print("\nUnused images found:")
    for _, f in ipairs(unused) do
        print("  " .. f)
    end

    if #args == 0 or args[1]:lower() ~= "yes" then
        print("\nRun the command again with 'yes' to delete these images:")
        print("cleanupimages yes")
        return
    end

    -- Delete unused images
    local deleted = 0
    for _, file in ipairs(unused) do
        local success, err = os.remove(IMAGES_FOLDER .. file)
        if success then
            deleted = deleted + 1
            print("Deleted → " .. file)
        else
            print("ERROR deleting " .. file, err)
        end
    end

    print("\nCleanup complete! Deleted " .. deleted .. " images.")
end, true)
