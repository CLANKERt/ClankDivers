if CLIENT then
    ClankDivers = ClankDivers or {}
    ClankDivers.PlayersAlive = {}

    ------------------------
    -- Receive alive players from server
    ------------------------
    net.Receive("ClankDivers_UpdatePlayersAlive", function()
        local aliveIDs = net.ReadTable()
        local newAlive = {}
        for _, sid in ipairs(aliveIDs) do
            for _, ply in ipairs(player.GetAll()) do
                if ply:SteamID() == sid then
                    table.insert(newAlive, ply)
                end
            end
        end
        ClankDivers.PlayersAlive = newAlive
    end)

    ------------------------
    -- Spectator controls (E/Q)
    ------------------------
    local SpectateCooldown = 0.2
    local LastSpectate = 0

    hook.Add("Think", "ClankDiversSpectatorControls", function()
        local ply = LocalPlayer()
        if not ply:Alive() and #ClankDivers.PlayersAlive > 0 then
            if CurTime() > LastSpectate then
                if input.IsKeyDown(KEY_E) then
                    net.Start("ClankDivers_SpectateSwitch")
                    net.WriteInt(1, 8) -- next player
                    net.SendToServer()
                    LastSpectate = CurTime() + SpectateCooldown
                elseif input.IsKeyDown(KEY_Q) then
                    net.Start("ClankDivers_SpectateSwitch")
                    net.WriteInt(-1, 8) -- previous player
                    net.SendToServer()
                    LastSpectate = CurTime() + SpectateCooldown
                end
            end
        end
    end)

    ------------------------
    -- Helldivers-style HUD
    ------------------------
    hook.Add("HUDPaint", "ClankDiversHUD", function()
        local ply = LocalPlayer()
        local scrW, scrH = ScrW(), ScrH()

        -- Background panel
        draw.RoundedBox(4, scrW - 220, 40, 200, 180, Color(0,0,0,150))

        -- Player count
        draw.SimpleText("Players Alive: "..#ClankDivers.PlayersAlive, "DermaDefaultBold", scrW - 120, 50, Color(0,255,0), TEXT_ALIGN_CENTER)

        -- Mini scoreboard
        local y = 80
        for i, p in ipairs(player.GetAll()) do
            local alive = table.HasValue(ClankDivers.PlayersAlive, p)
            local col = alive and Color(0,255,0) or Color(255,0,0)
            draw.SimpleText(p:Nick(), "DermaDefault", scrW - 120, y, col, TEXT_ALIGN_CENTER)
            y = y + 20
        end

        -- Optional: draw a subtle tactical bar for alive player count
        local barWidth = 180
        local barHeight = 10
        local totalPlayers = #player.GetAll()
        local alivePlayers = #ClankDivers.PlayersAlive
        local fraction = alivePlayers / math.max(totalPlayers,1)

        draw.RoundedBox(2, scrW - 210, y + 10, barWidth, barHeight, Color(50,50,50,200))
        draw.RoundedBox(2, scrW - 210, y + 10, barWidth * fraction, barHeight, Color(0,200,0,220))

        -- Credits at bottom
        draw.SimpleText("CLANKERt_", "DermaDefaultBold", scrW - 120, scrH - 40, Color(255,255,255), TEXT_ALIGN_CENTER)
    end)

    ------------------------
    -- Hide default HUD elements
    ------------------------
    hook.Add("HUDShouldDraw", "ClankDivers_HideDefaultHUD", function(name)
        local hudToHide = {
            ["CHudHealth"] = true,
            ["CHudBattery"] = true,
            ["CHudAmmo"] = true,
            ["CHudSecondaryAmmo"] = true
        }
        if hudToHide[name] then return false end
    end)
end
