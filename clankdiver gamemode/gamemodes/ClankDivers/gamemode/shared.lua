GM.Name = "ClankDivers"
GM.Author = "CLANKERt"
GM.Email = "N/A"
GM.Website = "N/A"

-- Load all modules in the modules/ folder
local files, _ = file.Find(GM.FolderName .. "/gamemode/modules/*.lua", "LUA")

for _, f in ipairs(files) do
    if SERVER then
        AddCSLuaFile("modules/" .. f)
    end

    include("modules/" .. f)
    print("[ClankDivers] Loaded module: " .. f)
end
