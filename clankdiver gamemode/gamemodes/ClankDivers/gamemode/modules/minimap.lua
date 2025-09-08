if CLIENT then
    local mapSize = 200
    local mapX = ScrW() - mapSize - 20  -- top-right corner
    local mapY = 20                      -- margin from top

    hook.Add("HUDPaint", "ClankDivers_Minimap", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        -- Camera above player
        local camPos = ply:GetPos() + Vector(0,0,300) -- height above player
        local camAng = Angle(90, ply:EyeAngles().y, 0) -- look straight down

        -- Render the 3D view in a small rectangle
        cam.Start3D(camPos, camAng, 90, mapX, mapY, mapSize, mapSize, 5, 4096)
            render.RenderView({
                origin = camPos,
                angles = camAng,
                x = 0,
                y = 0,
                w = mapSize,
                h = mapSize,
                fov = 110,
                drawviewmodel = false,
                dopostprocess = false
            })
        cam.End3D()
    end)
end

