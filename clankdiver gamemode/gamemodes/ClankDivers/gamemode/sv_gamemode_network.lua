if SERVER then
    util.AddNetworkString("ClankDivers_SelectGameMode")

    net.Receive("ClankDivers_SelectGameMode", function(len, ply)
        local mode = net.ReadString()
        print(ply:Nick() .. " selected game mode: " .. mode)

        -- Here you can start prep timer or store selected mode
        game.SetMapMode = mode
    end)
end
