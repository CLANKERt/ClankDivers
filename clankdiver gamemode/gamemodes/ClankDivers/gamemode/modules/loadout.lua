-- ClankDivers Loadout System (Auto Open on Spawn)

-- Available weapons
local AvailableWeapons = {
    ["Pistol"]        = "weapon_pistol",
    ["SMG"]           = "weapon_smg1",
    ["Shotgun"]       = "weapon_shotgun",
    ["AR2"]           = "weapon_ar2",
    [".357 Revolver"] = "weapon_357",
    ["Crossbow"]      = "weapon_crossbow",
}

if SERVER then
    util.AddNetworkString("ClankDivers_SetLoadout")
    util.AddNetworkString("ClankDivers_OpenLoadoutMenu") -- NEW: network for opening menu

    -- Receive chosen loadout from client
    net.Receive("ClankDivers_SetLoadout", function(len, ply)
        local weaponName = net.ReadString()
        local weaponClass = AvailableWeapons[weaponName]
        if not weaponClass then return end

        -- Strip old weapons
        ply:StripWeapons()

        -- Give chosen weapon + utility
        ply:Give(weaponClass)
        ply:Give("weapon_crowbar")

        ply:SelectWeapon(weaponClass)

        -- Set armor to 100%
        ply:SetArmor(100)

        ply:ChatPrint("[ClankDivers] Loadout set: " .. weaponName .. " with 100% armor")
    end)

    -- Open loadout menu automatically when player spawns
    hook.Add("PlayerSpawn", "ClankDivers_OpenLoadoutMenu", function(ply)
        net.Start("ClankDivers_OpenLoadoutMenu")
        net.Send(ply)
    end)
end

if CLIENT then
    -- Function to create the loadout menu
    local function OpenLoadoutMenu()
        local frame = vgui.Create("DFrame")
        frame:SetTitle("ClankDivers Loadout")
        frame:SetSize(300, 400)
        frame:Center()
        frame:MakePopup()

        local list = vgui.Create("DListView", frame)
        list:Dock(FILL)
        list:AddColumn("Weapon")

        -- Fill the list
        for name, _ in pairs(AvailableWeapons) do
            list:AddLine(name)
        end

        -- Handle selection
        function list:OnRowSelected(_, row)
            local weaponName = row:GetColumnText(1)
            net.Start("ClankDivers_SetLoadout")
            net.WriteString(weaponName)
            net.SendToServer()
            frame:Close()
        end
    end

    -- Console command still works
    concommand.Add("clankdivers_loadout", OpenLoadoutMenu)

    -- Listen for server telling us to open the menu
    net.Receive("ClankDivers_OpenLoadoutMenu", function()
        OpenLoadoutMenu()
    end)
end
