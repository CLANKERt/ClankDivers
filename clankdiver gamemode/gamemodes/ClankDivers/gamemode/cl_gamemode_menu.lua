if CLIENT then
    local function OpenGameModeMenu()
        -- Main frame
        local frame = vgui.Create("DFrame")
        frame:SetTitle("")  -- no default title
        frame:SetSize(500, 350)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(false)
        frame:ShowCloseButton(false)

        -- Custom paint for Helldivers style
        frame.Paint = function(self, w, h)
            -- Background
            draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 35, 240))
            -- Header
            draw.RoundedBox(4, 0, 0, w, 50, Color(20, 20, 25, 255))
            draw.SimpleText("Select Game Mode", "Trebuchet24", w/2, 25, Color(255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            -- Credit
            draw.SimpleText("ClankDivers by CLANKERt_", "Trebuchet18", w/2, h-30, Color(180,180,180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Button style
        local function CreateMenuButton(parent, text, x, y, callback)
            local btn = vgui.Create("DButton", parent)
            btn:SetText(text)
            btn:SetFont("Trebuchet24")
            btn:SetSize(200, 50)
            btn:SetPos(x, y)
            btn:SetTextColor(Color(255,255,255))
            btn.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(6, 0, 0, w, h, Color(50, 150, 255))
                else
                    draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 45))
                end
            end
            btn.DoClick = callback
            return btn
        end

        -- Survival button
        CreateMenuButton(frame, "Survival", 50, 100, function()
            net.Start("ClankDivers_SelectGameMode")
            net.WriteString("survival")
            net.SendToServer()
            frame:Close()
        end)

        -- Objective button
        CreateMenuButton(frame, "Objective", 250, 100, function()
            net.Start("ClankDivers_SelectGameMode")
            net.WriteString("objective")
            net.SendToServer()
            frame:Close()
        end)

        -- Exit button
        CreateMenuButton(frame, "Exit", 150, 200, function()
            frame:Close()
        end)
    end

    -- Auto-open menu when player joins
    hook.Add("InitPostEntity", "ClankDivers_OpenMenu", function()
        timer.Simple(0.5, function()
            OpenGameModeMenu()
        end)
    end)

    -- Optional: manual open
    concommand.Add("clankdivers_menu", OpenGameModeMenu)
end
