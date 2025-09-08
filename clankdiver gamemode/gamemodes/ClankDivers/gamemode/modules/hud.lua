if CLIENT then

    -- ==========================
    -- CONFIG
    -- ==========================
    local compassWidth = 900
    local compassHeight = 20
    local compassY = 20

    local minimapSize = 200
    local minimapX = ScrW() - minimapSize - 20
    local minimapY = 20
    local minimapHeightAbove = 300

    local minimapRT = GetRenderTarget("ClankDivers_MinimapRT", 256, 256, false)

    -- Hide default HUD
    hook.Add("HUDShouldDraw", "ClankDivers_HideDefaultHUD", function(name)
        local hide = {
            ["CHudHealth"] = true,
            ["CHudBattery"] = true,
            ["CHudAmmo"] = true,
            ["CHudSecondaryAmmo"] = true,
            ["CHudWeaponSelection"] = true
        }
        if hide[name] then return false end
    end)

    -- ==========================
    -- HUDPAINT HOOK
    -- ==========================
    hook.Add("HUDPaint", "ClankDivers_HelldiversHUD", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        local scrW, scrH = ScrW(), ScrH()

        -- ==========================
        -- HEALTH BAR
        -- ==========================
        local health = math.max(0, ply:Health())
        local maxHealth = ply:GetMaxHealth()
        local barWidth = 300
        local barHeight = 25
        local barX = 20
        local barY = scrH - barHeight - 20

        surface.SetDrawColor(30,30,30,200)
        surface.DrawRect(barX, barY, barWidth, barHeight)
        surface.SetDrawColor(0,200,0,255)
        surface.DrawRect(barX, barY, barWidth * (health/maxHealth), barHeight)
        surface.SetDrawColor(0,0,0,255)
        surface.DrawOutlinedRect(barX, barY, barWidth, barHeight)
        draw.SimpleText("HEALTH: "..health, "Trebuchet24", barX + barWidth/2, barY + barHeight/2, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- ==========================
        -- AMMO COUNTER
        -- ==========================
        local ammoX, ammoY, ammoWidth, ammoHeight = 20, barY - 70, 140, 70
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local clip = weapon:Clip1() or 0
            local reserve = ply:GetAmmoCount(weapon:GetPrimaryAmmoType()) or 0
            local special = ply:GetAmmoCount(weapon:GetSecondaryAmmoType()) or 0

            -- Background
            surface.SetDrawColor(30,30,30,200)
            surface.DrawRect(ammoX, ammoY, ammoWidth, ammoHeight)
            -- Border
            surface.SetDrawColor(0,0,0,255)
            surface.DrawOutlinedRect(ammoX, ammoY, ammoWidth, ammoHeight)

            -- Clip
            draw.SimpleText("CLIP: "..clip, "Trebuchet24", ammoX + ammoWidth/2, ammoY + 15, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- Reserve
            draw.SimpleText("RESERVE: "..reserve, "Trebuchet24", ammoX + ammoWidth/2, ammoY + 35, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- Special
            draw.SimpleText("SPECIAL: "..special, "Trebuchet24", ammoX + ammoWidth/2, ammoY + 55, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- ==========================
        -- ARMOR ICON & PERCENTAGE
        -- ==========================
    hook.Add("HUDPaint", "DrawArmorBar", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local armor = ply:Armor() or 0
        local maxArmor = 100

        -- Position next to ammo counter (adjust these as needed)
        local barWidth = 64
        local barHeight = 64
        local barX = ammoX + ammoWidth + 10
        local barY = ammoY + 5

        -- Draw bar outline
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(barX - 1, barY - 1, barWidth + 2, barHeight + 2)

        -- Draw background (empty bar)
        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(barX, barY, barWidth, barHeight)

        -- Draw filled portion
        local fillWidth = math.Clamp((armor / maxArmor) * barWidth, 0, barWidth)
        surface.SetDrawColor(0, 150, 255, 200) -- blue bar
        surface.DrawRect(barX, barY, fillWidth, barHeight)

        -- Draw outline for the filled portion (optional, gives that Helldivers feel)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawOutlinedRect(barX, barY, fillWidth, barHeight)

        -- Draw percentage text above the bar
        draw.SimpleText(armor.."%", "Trebuchet24", barX + barWidth / 2, barY - 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end)

        -- ==========================
        -- COMPASS
        -- ==========================
        local compassX = scrW/2 - compassWidth/1 
        local yaw = ply:EyeAngles().y 
        local myX = 500 

        local myX = 500
        local myY = 20 
        local myWidth = 900 
        local myHeight = 20 
        surface.SetDrawColor(50,50,50,150) 
        surface.DrawRect(myX, myY, myWidth, myHeight)


        -- Directions N/E/S/W
        local directions = {"N", "E", "S", "W"}
        for i = 1,4 do
            local angleOffset = ((i-1)*90 - yaw) % 360
            local posX = compassX + compassWidth/2 + (angleOffset/180)*(compassWidth/2)
            draw.SimpleText(directions[i], "Trebuchet24", posX, compassY + compassHeight/2, Color(200,200,200,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Draw NPCs and players on compass
        local scale = 0.2
        for _, ent in pairs(ents.GetAll()) do
            if not IsValid(ent) or ent == ply then continue end

            local delta = ent:GetPos() - ply:GetPos()
            local angle = math.deg(math.atan2(delta.y, delta.x))
            local dist = delta:Length() * scale
            local screenX = compassX + compassWidth/2 + dist * math.cos(math.rad(angle - yaw))
            local screenY = compassY + compassHeight/2

            if ent:IsPlayer() then
                surface.SetDrawColor(100,255,100,255) -- light green
            elseif ent:GetClass() == "npc_combine_s" then
                surface.SetDrawColor(255,0,0,255) -- red
            elseif ent:GetClass() == "npc_citizen" then
                surface.SetDrawColor(0,100,0,255) -- dark green
            else
                continue
            end

            surface.DrawRect(screenX-2, screenY-2, 4, 4)
        end

    end)
end
