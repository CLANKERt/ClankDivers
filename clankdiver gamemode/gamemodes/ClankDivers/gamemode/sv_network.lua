if SERVER then
    util.AddNetworkString("Clank_StartGame")
    util.AddNetworkString("Clank_SaveLoadout")

    -- Store each player's loadout server-side
    local PlayerLoadouts = {}

    net.Receive("Clank_SaveLoadout", function(len, ply)
        local primary = net.ReadString()
        local secondary = net.ReadString()
        local utility = net.ReadString()
        local armor = net.ReadInt(8)

        -- Save loadout
        PlayerLoadouts[ply] = {
            Primary = primary,
            Secondary = secondary,
            Utility = utility,
            Armor = armor
        }

        print(ply:Nick().." saved loadout: ", primary, secondary, utility, "Armor:", armor)
    end)

    net.Receive("Clank_StartGame", function(len, ply)
        local loadout = PlayerLoadouts[ply]
        if not loadout then
            ply:ChatPrint("You have no loadout saved! Please open loadout first.")
            return
        end

        -- Give Primary
        if loadout.Primary == "Rifle" then
            ply:Give("weapon_m4a1") -- replace with your actual weapon class
        elseif loadout.Primary == "Shotgun" then
            ply:Give("weapon_shotgun")
        elseif loadout.Primary == "Sniper" then
            ply:Give("weapon_awp")
        end

        -- Give Secondary
        if loadout.Secondary == "Pistol" then
            ply:Give("weapon_pistol")
        elseif loadout.Secondary == "SMG" then
            ply:Give("weapon_smg1")
        end

        -- Give Utility
        if loadout.Utility == "Grenade" then
            ply:Give("weapon_frag") -- grenade
        elseif loadout.Utility == "Medkit" then
            ply:Give("item_healthkit") -- if you have a medkit entity
        end

        -- Give armor
        ply:SetArmor(loadout.Armor or 0)

        ply:ChatPrint("Your loadout has been given!")
        print(ply:Nick().." started game with loadout.")
    end)
end
