if CLIENT then
    -- Hide default GMod crosshair
    hook.Add("HUDShouldDraw", "ClankDivers_HideDefaultCrosshair", function(name)
        if name == "CHudCrosshair" then
            return false
        end
    end)

    -- Draw trace-based dot crosshair
    hook.Add("HUDPaint", "ClankDivers_TraceCrosshair", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        -- Start trace from eyes
        local startPos = ply:EyePos()
        local aimDir = ply:GetAimVector()

        -- Trace 10000 units forward, ignore player
        local tr = util.TraceLine({
            start = startPos,
            endpos = startPos + aimDir * 10000,
            filter = ply
        })

        local hitPos = tr.HitPos
        local screenPos = hitPos:ToScreen()

        local size = 4
        local color = Color(255, 255, 255, 255)

        surface.SetDrawColor(color)
        surface.DrawRect(screenPos.x - size/2, screenPos.y - size/2, size, size)
    end)
end
