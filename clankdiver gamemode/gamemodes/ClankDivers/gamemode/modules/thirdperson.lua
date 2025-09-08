if CLIENT then
    local distance = 60      -- distance behind the player
    local rightOffset = 25    -- offset to the right shoulder
    local heightOffset = 60   -- camera height above player

    hook.Add("CalcView", "ClankDivers_ThirdPersonView", function(ply, pos, angles, fov)
        if not IsValid(ply) or not ply:Alive() then return end

        local view = {}
        local targetPos = ply:GetPos() + Vector(0,0,heightOffset)
        local right = ply:EyeAngles():Right()
        local back = -ply:EyeAngles():Forward()

        -- Position camera slightly behind and to the right
        view.origin = targetPos + back * distance + right * rightOffset
        view.angles = angles
        view.fov = fov
        view.drawviewer = true   -- this makes player visible

        return view
    end)
end
