local ITEMS_FILE = "resources/[ox]/ox_inventory/data/items.lua"
local WEAPONS_FILE = "resources/[ox]/ox_inventory/data/weapons.lua"
local IMAGES_FOLDER = "resources/[ox]/ox_inventory/web/images/"

-- you can change the paths if your files are in a different location but this is usually startndard paths for ox inventory ^^

RegisterCommand("cleanupimages", function(source, args)
    if source ~= 0 then
        -- print("This command can only be run from server console.")
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

    -- check items.lua and the weapons.lua files
    local used = {}
    local files = {ITEMS_FILE, WEAPONS_FILE}

    for _, path in ipairs(files) do
        local data = readFile(path)

        for img in data:gmatch('image%s*=%s*"([^"]+)"') do
            used[img] = true
        end

        for img in data:gmatch('client%s*=%s*{[^}]-image%s*=%s*"([^"]+)"') do
            used[img] = true
        end

        for name in data:gmatch("%[%'([^']+)%'%]") do
            used[name] = true
        end

        for name in data:gmatch('%["([^"]+)"%]') do
            used[name] = true
        end

        for name in data:gmatch('name%s*=%s*"([^"]+)"') do
            used[name] = true
        end
    end

    local p = io.popen('dir "' .. IMAGES_FOLDER .. '" /b')
    local unused = {}

    for file in p:lines() do
        local base = file:gsub("%.%w+$", "")

        local ext = file:match("%.([^.]+)$")
        ext = ext and ext:lower()

        if ext == "png" or ext == "jpg" or ext == "jpeg" then
            if not used[base] then
                table.insert(unused, file)
            end
        end
    end

    p:close()

    -- no unused images found
    if #unused == 0 then
        print("No unused images found.")
        return
    end

    -- show unused images
    print("\nUnused images found:")
    for _, f in ipairs(unused) do
        print("  " .. f)
    end

    -- the "are you sure" check
    if not args[1] or args[1]:lower() ~= "yes" then
        print("\nRun the command again with 'yes' to delete these images:")
        print("cleanupimages yes")
        return
    end

    -- remove unused images
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
