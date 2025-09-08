if CLIENT then
    -- Fonts
    surface.CreateFont("Clank_Title", { font = "Arial", size = 64, weight = 800 })
    surface.CreateFont("Clank_Button", { font = "Arial", size = 32, weight = 600 })

    -- Keep loadout selections across menu opens
    ClankDivers_Loadout = ClankDivers_Loadout or {
        Primary = "Rifle",
        Secondary = "Pistol",
        Utility = "Grenade",
        Armor = 50
    }

    local function OpenMainMenu()
        if IsValid(MainMenu) then MainMenu:Remove() end

        local scrW, scrH = ScrW(), ScrH()

        -- Main menu frame
        MainMenu = vgui.Create("DFrame")
        MainMenu:SetSize(scrW, scrH)
        MainMenu:SetPos(0, 0)
        MainMenu:SetTitle("")
        MainMenu:ShowCloseButton(false)
        MainMenu:MakePopup()
        MainMenu.Paint = function(self, w, h)
            surface.SetDrawColor(10, 20, 40, 255)
            surface.DrawRect(0, 0, w, h)

            -- Overlay stripes
            for i = 0, h, 40 do
                surface.SetDrawColor(20, 40, 70, 80)
                surface.DrawRect(0, i, w, 20)
            end

            draw.SimpleText("CLANKDIVERS", "Clank_Title", w/2, h*0.15, Color(0, 180, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        -- Reusable button
        local function CreateMenuButton(text, yFrac, onClick)
            local btn = vgui.Create("DButton", MainMenu)
            btn:SetText(text)
            btn:SetFont("Clank_Button")
            btn:SetTextColor(Color(255,255,255))
            btn:SetSize(scrW*0.3, 70)
            btn:CenterHorizontal()
            btn:SetY(scrH * yFrac)
            btn.Paint = function(self,w,h)
                local col = self:IsHovered() and Color(0,120,200) or Color(0,80,160)
                surface.SetDrawColor(col)
                surface.DrawRect(0,0,w,h)
                surface.SetDrawColor(255,255,255,40)
                surface.DrawOutlinedRect(0,0,w,h,2)
            end
            btn.DoClick = onClick
            return btn
        end

        -- START GAME
        CreateMenuButton("START GAME", 0.35, function()
            MainMenu:Close()
            chat.AddText(Color(0,255,0), "Game started!")
            net.Start("Clank_StartGame")
            net.SendToServer()
        end)

        -- LOADOUT
        CreateMenuButton("LOADOUT", 0.50, function()
            local loadFrame = vgui.Create("DFrame")
            loadFrame:SetSize(600, 400)
            loadFrame:Center()
            loadFrame:SetTitle("")
            loadFrame:ShowCloseButton(true)
            loadFrame:MakePopup()
            loadFrame.Paint = function(self,w,h)
                surface.SetDrawColor(20,40,70,240)
                surface.DrawRect(0,0,w,h)
                draw.SimpleText("SELECT LOADOUT","Clank_Button",w/2,30,Color(255,255,255),TEXT_ALIGN_CENTER)
            end

            -- Model preview
            local mdlPanel = vgui.Create("DModelPanel", loadFrame)
            mdlPanel:SetSize(250, 350)
            mdlPanel:SetPos(330, 30)
            mdlPanel:SetModel(LocalPlayer():GetModel() or "models/player/kleiner.mdl")
            mdlPanel:SetFOV(35)
            mdlPanel:SetCamPos(Vector(50, 0, 60))
            mdlPanel:SetLookAt(Vector(0, 0, 60))

            -- Spin + animate safely
            mdlPanel.LayoutEntity = function(self, ent)
                local entity = ent or self:GetEntity()
                if IsValid(entity) then
                    entity:SetAngles(Angle(0, CurTime() * 30 % 360, 0))
                    entity:FrameAdvance(FrameTime())
                end
            end

            timer.Simple(0.1, function()
                if IsValid(mdlPanel.Entity) then
                    local seq = mdlPanel.Entity:LookupSequence("idle_all_01") or 0
                    mdlPanel.Entity:ResetSequence(seq)
                    mdlPanel.Entity:ResetSequenceInfo()
                    mdlPanel.Entity:SetCycle(0)
                end
            end)

            -- Weapon attachment (only one at a time)
            mdlPanel.ActiveWep = nil
            local function ClearWeaponPreview()
                if IsValid(mdlPanel.ActiveWep) then
                    mdlPanel.ActiveWep:Remove()
                    mdlPanel.ActiveWep = nil
                end
            end

            local function AttachWeaponToPreview(wepModel, boneName, pos, ang)
                if not IsValid(mdlPanel.Entity) then return end
                ClearWeaponPreview()

                local wep = ClientsideModel(wepModel, RENDERGROUP_OPAQUE)
                if not IsValid(wep) then return end

                wep:SetParent(mdlPanel.Entity)
                wep:AddEffects(EF_BONEMERGE)
                wep:SetNoDraw(false)

                local bone = mdlPanel.Entity:LookupBone(boneName or "ValveBiped.Bip01_R_Hand")
                if bone then
                    local m = mdlPanel.Entity:GetBoneMatrix(bone)
                    if m then
                        wep:SetPos(m:GetTranslation() + (pos or Vector(0,0,0)))
                        wep:SetAngles(m:GetAngles() + (ang or Angle(0,0,0)))
                    end
                end

                mdlPanel.ActiveWep = wep
            end

            -- Primary dropdown
            local primary = vgui.Create("DComboBox", loadFrame)
            primary:SetPos(30, 30)
            primary:SetSize(200, 30)
            primary:SetValue(ClankDivers_Loadout.Primary)
            primary:AddChoice("Rifle")
            primary:AddChoice("Shotgun")
            primary:AddChoice("Sniper")

            primary.OnSelect = function(_, _, value)
                ClankDivers_Loadout.Primary = value
                if value == "Rifle" then
                    AttachWeaponToPreview("models/weapons/w_rif_m4a1.mdl")
                elseif value == "Shotgun" then
                    AttachWeaponToPreview("models/weapons/w_shotgun.mdl")
                elseif value == "Sniper" then
                    AttachWeaponToPreview("models/weapons/w_snip_awp.mdl")
                end
            end

            -- Secondary dropdown
            local secondary = vgui.Create("DComboBox", loadFrame)
            secondary:SetPos(30, 80)
            secondary:SetSize(200, 30)
            secondary:SetValue(ClankDivers_Loadout.Secondary)
            secondary:AddChoice("Pistol")
            secondary:AddChoice("SMG")

            secondary.OnSelect = function(_, _, value)
                ClankDivers_Loadout.Secondary = value
                if value == "Pistol" then
                    AttachWeaponToPreview("models/weapons/w_pistol.mdl")
                elseif value == "SMG" then
                    AttachWeaponToPreview("models/weapons/w_smg1.mdl")
                end
            end

            -- Utility dropdown
            local utility = vgui.Create("DComboBox", loadFrame)
            utility:SetPos(30, 130)
            utility:SetSize(200, 30)
            utility:SetValue(ClankDivers_Loadout.Utility)
            utility:AddChoice("Grenade")
            utility:AddChoice("Medkit")

            utility.OnSelect = function(_, _, value)
                ClankDivers_Loadout.Utility = value
                if value == "Grenade" then
                    AttachWeaponToPreview("models/weapons/w_grenade.mdl", "ValveBiped.Bip01_Pelvis", Vector(-4,2,-6), Angle(0,90,0))
                elseif value == "Medkit" then
                    AttachWeaponToPreview("models/items/healthkit.mdl", "ValveBiped.Bip01_Spine2", Vector(4,0,0))
                end
            end

            -- Armor slider
            local armorSlider = vgui.Create("DNumSlider", loadFrame)
            armorSlider:SetPos(30, 180)
            armorSlider:SetSize(250, 40)
            armorSlider:SetText("Armor Amount")
            armorSlider:SetMin(0)
            armorSlider:SetMax(100)
            armorSlider:SetDecimals(0)
            armorSlider:SetValue(ClankDivers_Loadout.Armor)

            -- Confirm loadout
            local confirm = vgui.Create("DButton", loadFrame)
            confirm:SetText("CONFIRM LOADOUT")
            confirm:SetFont("Clank_Button")
            confirm:SetSize(250,50)
            confirm:SetPos(30, 250)
            confirm.Paint = function(self,w,h)
                surface.SetDrawColor(self:IsHovered() and Color(0,150,100) or Color(0,100,70))
                surface.DrawRect(0,0,w,h)
            end
            confirm.DoClick = function()
                ClankDivers_Loadout.Armor = armorSlider:GetValue()
                net.Start("Clank_SaveLoadout")
                net.WriteString(ClankDivers_Loadout.Primary)
                net.WriteString(ClankDivers_Loadout.Secondary)
                net.WriteString(ClankDivers_Loadout.Utility)
                net.WriteInt(ClankDivers_Loadout.Armor, 8)
                net.SendToServer()
                loadFrame:Close()
            end

            -- Auto-preview last chosen primary weapon
            if ClankDivers_Loadout.Primary == "Rifle" then
                AttachWeaponToPreview("models/weapons/w_rif_m4a1.mdl")
            elseif ClankDivers_Loadout.Primary == "Shotgun" then
                AttachWeaponToPreview("models/weapons/w_shotgun.mdl")
            elseif ClankDivers_Loadout.Primary == "Sniper" then
                AttachWeaponToPreview("models/weapons/w_snip_awp.mdl")
            end
        end)

        -- EXIT
        CreateMenuButton("EXIT", 0.65, function()
            MainMenu:Close()
        end)
    end

    -- Open menu on spawn
    hook.Add("InitPostEntity","Clank_OpenMenuOnSpawn",function()
        timer.Simple(1, OpenMainMenu)
    end)

    -- Optional console command to open menu
    concommand.Add("clank_menu", OpenMainMenu)
end
