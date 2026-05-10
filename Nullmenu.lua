if CLIENT then
    --[[ FULL NULLMENU v4.0 – Everything Working ]]--
    local NULL_VERSION = "v4.0_Full"
    surface.PlaySound("buttons/button16.wav")
    chat.AddText(Color(200,0,255), "[NullMenu] ", Color(0,255,200), NULL_VERSION, Color(255,255,255), " loaded. Type !null")

    -- ========== ALL ORIGINAL CONVARS ==========
    CreateClientConVar("rz_espname", "1", true, false)
    CreateClientConVar("rz_esphp", "1", true, false)
    CreateClientConVar("rz_espping", "1", true, false)
    CreateClientConVar("rz_espdistance", "1", true, false)
    CreateClientConVar("rz_espvelocity", "0", true, false)
    CreateClientConVar("rz_esp", "1", true, false)
    CreateClientConVar("rz_xray", "0", true, false)
    CreateClientConVar("rz_chams", "1", true, false)
    CreateClientConVar("rz_tracers", "1", true, false)
    CreateClientConVar("rz_proptracers", "1", true, false)
    CreateClientConVar("rz_headtracers", "0", true, false)
    CreateClientConVar("rz_eyetracers", "0", true, false)
    CreateClientConVar("rz_fov", "90", true, false)
    CreateClientConVar("rz_traceprop", "1", true, false)
    CreateClientConVar("rz_hud", "1", true, false)
    CreateClientConVar("rz_crosshair", "1", true, false)
    CreateClientConVar("rz_skybox", "0", true, false)
    CreateClientConVar("rz_skyboxr", "0", true, false)
    CreateClientConVar("rz_skyboxg", "0", true, false)
    CreateClientConVar("rz_skyboxb", "0", true, false)
    CreateClientConVar("rz_crosshairsize", "10", true, false)
    CreateClientConVar("rz_propdist", "1", true, false)
    CreateClientConVar("rz_xraydrawdist", "15000", true, false)
    CreateClientConVar("null_silent_aim_enabled", "1", true, false)

    local ply = LocalPlayer()
    local physgun_classes = {["weapon_physgun"]=true, ["propkill_physgun"]=true, ["lua_physgun"]=true}

    -- ========== WEAPON POS ==========
    local function weaponpos()
        if IsValid(ply:GetActiveWeapon()) and physgun_classes[ply:GetActiveWeapon():GetClass()] then
            local wep = ply:GetViewModel()
            if IsValid(wep) then
                local att = wep:LookupAttachment("muzzle")
                if att and att > 0 then
                    local atpos = wep:GetAttachment(att)
                    if atpos then return atpos.Pos end
                end
            end
        end
        return ply:GetShootPos()
    end

    -- ========== TRACERS ==========
    hook.Add("HUDPaint", "Null_Tracers", function()
        if not (IsValid(ply:GetActiveWeapon()) and physgun_classes[ply:GetActiveWeapon():GetClass()]) then return end
        local tracers_on = GetConVarNumber("rz_tracers") == 1
        local proptracers_on = GetConVarNumber("rz_proptracers") == 1
        if not tracers_on and not proptracers_on then return end
        local wep = ply:GetActiveWeapon()
        local held = wep.GetHeldEntity and wep:GetHeldEntity() or wep:GetInternalVariable("m_hGrabbedEntity")
        cam.Start3D()
        for _, v in ipairs(player.GetAll()) do
            if v ~= ply and v:Alive() and v:Team() ~= TEAM_SPECTATOR and not v:IsDormant() then
                if proptracers_on and IsValid(held) then
                    render.DrawLine(held:LocalToWorld(held:OBBCenter()), v:LocalToWorld(v:OBBCenter()), Color(255,255,255), false)
                end
                if tracers_on then
                    local speed = v:GetVelocity():Length() / 2
                    render.DrawLine(weaponpos(), v:GetPos(), Color(speed,0,255), false)
                end
            end
        end
        cam.End3D()
    end)

    -- ========== CHAMS ==========
    hook.Add("RenderScreenspaceEffects", "Null_Chams", function()
        if GetConVarNumber("rz_chams") ~= 1 then return end
        for _, v in ipairs(player.GetAll()) do
            if IsValid(v:GetObserverTarget()) then continue end
            if v:IsDormant() then continue end
            if v ~= ply and v:Alive() then
                cam.Start3D()
                cam.IgnoreZ(true)
                v:SetRenderMode(RENDERMODE_TRANSALPHA)
                v:SetColor(Color(255,105,180,100))
                render.SetColorModulation(0,0,255)
                v:DrawModel()
                render.DrawWireframeBox(v:GetPos(), v:GetAngles(), v:OBBMins()+Vector(4.5,4.5,4.5), v:OBBMaxs()-Vector(4.5,4.5,4.5), Color(0,0,0), false)
                render.DrawWireframeBox(v:GetPos(), v:GetAngles(), v:OBBMins()+Vector(5,5,5), v:OBBMaxs()-Vector(5,5,5), Color(0,255,0), false)
                cam.End3D()
            end
        end
    end)

    -- ========== XRAY ==========
    hook.Add("RenderScreenspaceEffects", "Null_XRay", function()
        if GetConVarNumber("rz_xray") ~= 1 then return end
        for _, ent in ipairs(ents.FindByClass("prop_physics")) do
            if ent:IsDormant() then continue end
            cam.Start3D()
            cam.IgnoreZ(true)
            ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            ent:SetColor(Color(0,255,255,255))
            ent:DrawModel()
            render.DrawWireframeBox(ent:GetPos(), ent:GetAngles(), ent:OBBMins()+Vector(5,5,5), ent:OBBMaxs()-Vector(5,5,5), Color(0,255,255))
            ent:AddEffects(256)
            cam.End3D()
        end
    end)

    -- ========== EYE TRACERS ==========
    hook.Add("RenderScreenspaceEffects", "Null_EyeTracers", function()
        if GetConVarNumber("rz_eyetracers") ~= 1 then return end
        for _, v in ipairs(player.GetAll()) do
            if v:Alive() and v ~= ply and v:Team() ~= TEAM_SPECTATOR and not v:IsDormant() then
                cam.Start3D()
                render.DrawLine(v:GetEyeTrace().HitPos, v:EyePos(), Color(100,200,100))
                cam.End3D()
            end
        end
    end)

    -- ========== HEAD TRACERS ==========
    hook.Add("RenderScreenspaceEffects", "Null_HeadTracers", function()
        if GetConVarNumber("rz_headtracers") ~= 1 then return end
        for _, v in ipairs(player.GetAll()) do
            if v ~= ply and v:Alive() and v:Team() ~= TEAM_SPECTATOR and not v:IsDormant() then
                local trace = util.QuickTrace(v:EyePos(), Vector(0,0,-100000), v)
                local vel = v:GetVelocity():Length()
                cam.Start3D()
                cam.IgnoreZ(true)
                render.DrawLine(v:GetPos(), trace.HitPos, Color(100,0,vel))
                if trace.HitWorld then
                    render.DrawLine(trace.HitPos+Vector(40,0,0), trace.HitPos, Color(100,vel/3,0))
                    render.DrawLine(trace.HitPos-Vector(40,0,0), trace.HitPos, Color(100,vel/3,0))
                    render.DrawLine(trace.HitPos+Vector(0,40,0), trace.HitPos, Color(100,vel/3,0))
                    render.DrawLine(trace.HitPos-Vector(0,40,0), trace.HitPos, Color(100,vel/3,0))
                else
                    render.DrawLine(trace.HitPos+Vector(60,0,0), trace.HitPos, Color(255,255,200))
                    render.DrawLine(trace.HitPos-Vector(60,0,0), trace.HitPos, Color(255,255,200))
                    render.DrawLine(trace.HitPos+Vector(0,60,0), trace.HitPos, Color(255,255,200))
                    render.DrawLine(trace.HitPos-Vector(0,60,0), trace.HitPos, Color(255,255,200))
                end
                cam.End3D()
            end
        end
    end)

    -- ========== FOV ==========
    hook.Add("CalcView", "Null_FOV", function(pl, origin, ang, fov, zn, zf)
        local newFOV = GetConVarNumber("rz_fov")
        if newFOV >= 20 and newFOV <= 150 then
            return {origin=origin, angles=ang, fov=newFOV, znear=zn, zfar=zf}
        end
    end)

    -- ========== ESP ==========
    hook.Add("HUDPaint", "Null_ESP", function()
        if GetConVarNumber("rz_esp") ~= 1 then return end
        for _, v in ipairs(player.GetAll()) do
            if v == ply or not v:Alive() or v:Team() == TEAM_SPECTATOR or v:IsDormant() then continue end
            local screen = v:EyePos():ToScreen()
            if not screen.visible then continue end
            local dist = math.floor(ply:GetPos():Distance(v:GetPos()))
            local yOff = -30
            if GetConVarNumber("rz_espname")==1 then
                draw.SimpleTextOutlined(string.upper(v:Name()), "Default", screen.x, screen.y+yOff, Color(255,255,255), 1, 4, 1, Color(0,0,0))
                yOff = yOff + 10
            end
            if GetConVarNumber("rz_espdistance")==1 then
                draw.SimpleTextOutlined(dist, "Default", screen.x, screen.y+yOff, Color(255,255,255), 1, 4, 1, Color(0,0,0))
                yOff = yOff + 10
            end
            if GetConVarNumber("rz_esphp")==1 then
                draw.SimpleTextOutlined(v:Health().." HP", "Default", screen.x, screen.y+yOff, Color(255,255,255), 1, 4, 1, Color(0,0,0))
                yOff = yOff + 10
            end
            if GetConVarNumber("rz_espping")==1 then
                draw.SimpleTextOutlined(v:Ping().." MS", "Default", screen.x, screen.y+yOff, Color(255,255,255), 1, 4, 1, Color(0,0,0))
                yOff = yOff + 10
            end
            if GetConVarNumber("rz_espvelocity")==1 then
                draw.SimpleTextOutlined(math.floor(v:GetVelocity():Length()), "Default", screen.x, screen.y+yOff, Color(255,255,255), 1, 4, 1, Color(0,0,0))
            end
        end
    end)

    -- ========== CROSSHAIR ==========
    hook.Add("HUDPaint", "Null_Crosshair", function()
        if GetConVarNumber("rz_crosshair") ~= 1 then return end
        local m = ply:GetEyeTraceNoCursor().HitPos:ToScreen()
        local size = GetConVarNumber("rz_crosshairsize")
        local color = ply:GetEyeTrace().HitSky and Color(0,0,0) or Color(255,255,255)
        surface.SetDrawColor(color)
        surface.DrawLine(m.x-size, m.y, m.x+size, m.y)
        surface.DrawLine(m.x, m.y+size, m.x, m.y-size)
    end)

    -- ========== HUD ==========
    hook.Add("HUDPaint", "Null_HUD", function()
        if GetConVarNumber("rz_hud") ~= 1 then return end
        draw.SimpleText("VELOCITY : "..math.floor(ply:GetVelocity():Length()), "Default", 10, 10, Color(255,255,255))
        draw.SimpleText("LATENCY : "..ply:Ping(), "Default", 10, 20, Color(255,255,255))
        draw.SimpleText("FPS : "..math.Round(1/FrameTime()), "Default", 10, 30, Color(255,255,255))
    end)

    -- ========== SKYBOX ==========
    hook.Add("PreDrawSkyBox", "Null_Skybox", function()
        if GetConVarNumber("rz_skybox") == 1 then
            render.Clear(GetConVarNumber("rz_skyboxr"), GetConVarNumber("rz_skyboxg"), GetConVarNumber("rz_skyboxb"), 255)
            return true
        end
    end)

    -- ========== PROP DISTANCE ==========
    hook.Add("HUDPaint", "Null_PropDist", function()
        if GetConVarNumber("rz_propdist") ~= 1 then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not physgun_classes[wep:GetClass()] then return end
        local held = wep.GetHeldEntity and wep:GetHeldEntity() or wep:GetInternalVariable("m_hGrabbedEntity")
        if IsValid(held) then
            local dist = math.floor(held:GetPos():Distance(ply:GetPos()))
            local scr = held:GetPos():ToScreen()
            draw.SimpleTextOutlined(dist.."m", "Default", scr.x, scr.y, Color(255,100,0), 1, 1, 1, Color(0,0,0))
        end
    end)

    -- ========== TRACE PROP ==========
    hook.Add("HUDPaint", "Null_TraceProp", function()
        if GetConVarNumber("rz_traceprop") ~= 1 then return end
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) then
            local held = wep.GetHeldEntity and wep:GetHeldEntity() or wep:GetInternalVariable("m_hGrabbedEntity")
            if IsValid(held) then
                local dist = math.floor(held:GetPos():Distance(ply:GetPos()))
                cam.Start3D()
                render.DrawLine(held:GetPos(), ply:GetPos(), Color(255, 20+dist/100, 50))
                render.DrawWireframeBox(held:GetPos(), held:GetAngles(), held:OBBMins()+Vector(10,10,10), held:OBBMaxs()-Vector(10,10,10), Color(0,255*FrameTime(),0), false)
                cam.End3D()
            end
        end
    end)

    -- ========== SILENT AIM (MOUSE3 HOLD) ==========
    local function GetNearest()
        local closest, closestDist = nil, 999999
        for _, v in ipairs(player.GetAll()) do
            if v ~= ply and v:Alive() and v:Team() ~= TEAM_SPECTATOR and not v:IsDormant() then
                local d = ply:GetPos():Distance(v:GetPos())
                if d < closestDist then closest, closestDist = v, d end
            end
        end
        return closest
    end
    hook.Add("Think", "Null_SilentAim", function()
        if GetConVarNumber("null_silent_aim_enabled") == 1 and input.IsButtonDown(MOUSE_MIDDLE) then
            local target = GetNearest()
            if target then
                ply:SetEyeAngles((target:GetPos() + Vector(0,0,20) - ply:GetShootPos()):Angle())
            end
        end
    end)

    -- ========== ROTATE COMMANDS ==========
    concommand.Add("null_rotate", function()
        ply:SetEyeAngles(Angle(ply:EyeAngles().p, ply:EyeAngles().y - 180, 0))
        chat.AddText(Color(0,255,0), "[NullMenu] 180° spin")
    end)
    concommand.Add("null_rotate2", function()
        RunConsoleCommand("+jump")
        ply:SetEyeAngles(Angle(-ply:EyeAngles().p, ply:EyeAngles().y - 180, 0))
        timer.Simple(0.1, function() RunConsoleCommand("-jump") end)
        chat.AddText(Color(0,255,0), "[NullMenu] 180° spin + jump")
    end)

    -- ========== PROP BINDER (FIXED) ==========
    local propCategories = {
        Attack = {
            {"Tide Gate", "models/props/de_tides/gate_large.mdl"},
            {"Refrigerator", "models/props/CS_militia/refrigerator01.mdl"},
            {"Locker", "models/props_c17/lockers001a.mdl"},
            {"4x4 Plate", "models/props_phx/construct/metal_plate4x4.mdl"}
        },
        Defense = {
            {"Canal Bars", "models/props_canal/canal_bars004.mdl"},
            {"Canal Bars 2", "models/props_canal/canal_bars002.mdl"},
            {"Chimney", "models/props/de_inferno/chimney01.mdl"}
        },
        Surfing = {
            {"SawBlade", "models/props_junk/sawblade001a.mdl"},
            {"Moped Wheel", "models/props_phx/wheels/moped_tire.mdl"},
            {"Barrel Lid", "models/props/de_inferno/flower_barrel_p11.mdl"},
            {"Barrel Lid Clear", "models/props/de_inferno/flower_barrel_p10.mdl"}
        }
    }

    local function BindKeyToProp(keyName, propModel)
        RunConsoleCommand("bind", keyName, "gm_spawn " .. propModel)
        chat.AddText(Color(0,255,0), "[BINDER] Bound '", Color(255,255,0), keyName, Color(0,255,0), "' to: gm_spawn " .. propModel)
        surface.PlaySound("buttons/button15.wav")
    end

    local function WaitForKey(propName, propModel)
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 120)
        frame:Center()
        frame:SetTitle("Bind: " .. propName)
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(8,0,0,w,h,Color(30,30,40,230))
            draw.RoundedBox(8,0,0,w,25,Color(100,0,150,255))
            surface.SetDrawColor(200,0,255,255)
            surface.DrawOutlinedRect(0,0,w,h)
            draw.SimpleText("Press ANY key (ESC to cancel)", "Trebuchet20", w/2, 50, Color(255,255,0), 1, 1)
        end
        local hookName = "Null_Bind_" .. propName
        local listener = function(key)
            if key == KEY_ESCAPE then
                frame:Close()
                chat.AddText(Color(255,100,100), "[BINDER] Cancelled")
                hook.Remove("OnKeyCodePressed", hookName)
                return
            end
            local keyName = input.GetKeyName(key)
            if keyName and keyName ~= "" then
                BindKeyToProp(string.lower(keyName), propModel)
                frame:Close()
            end
            hook.Remove("OnKeyCodePressed", hookName)
        end
        hook.Add("OnKeyCodePressed", hookName, listener)
        frame.OnClose = function() hook.Remove("OnKeyCodePressed", hookName) end
    end

    local function OpenPropBinder()
        local frame = vgui.Create("DFrame")
        frame:SetSize(550, 650)
        frame:Center()
        frame:SetTitle("NullMenu - Prop Binder")
        frame:MakePopup()
        frame.Paint = function(self,w,h)
            draw.RoundedBox(8,0,0,w,h,Color(25,25,35,235))
            draw.RoundedBox(8,0,0,w,30,Color(150,0,200,255))
            surface.SetDrawColor(255,0,255,255)
            surface.DrawOutlinedRect(0,0,w,h)
        end
        local tabs = vgui.Create("DPropertySheet", frame)
        tabs:SetPos(5,35)
        tabs:SetSize(540,605)
        for catName, props in pairs(propCategories) do
            local panel = vgui.Create("DPanel")
            panel:SetSize(530,600)
            local scroll = vgui.Create("DScrollPanel", panel)
            scroll:SetPos(5,5)
            scroll:SetSize(520,590)
            local y = 5
            for _, prop in ipairs(props) do
                local btn = vgui.Create("DButton", scroll)
                btn:SetPos(10, y)
                btn:SetSize(490, 50)
                btn:SetText(prop[1] .. "\n" .. prop[2])
                btn.DoClick = function()
                    WaitForKey(prop[1], prop[2])
                    frame:Close()
                end
                btn.Paint = function(self,w,h)
                    draw.RoundedBox(4,0,0,w,h,Color(70,70,100,200))
                    surface.SetDrawColor(0,200,255,255)
                    surface.DrawOutlinedRect(0,0,w,h)
                end
                y = y + 60
            end
            tabs:AddSheet(catName, panel, "icon16/brick.png")
        end
    end

    concommand.Add("null_binder", OpenPropBinder)
    chat.AddCommand("bindprop", OpenPropBinder)

    -- ========== MAIN MENU ==========
    local function MainMenu()
        local frame = vgui.Create("DFrame")
        frame:SetSize(260, 400)
        frame:Center()
        frame:SetTitle("NullMenu " .. NULL_VERSION)
        frame:MakePopup()
        frame.Paint = function(self,w,h)
            draw.RoundedBox(2,0,0,w,h,Color(80,80,80,200))
            draw.RoundedBox(2,0,1,w,22,Color(50,50,50,200))
            surface.SetDrawColor(100,255,0,200)
            surface.DrawOutlinedRect(0,0,w,h)
        end
        local function addBtn(x,y,text,convar)
            local btn = vgui.Create("DButton", frame)
            btn:SetPos(x,y)
            btn:SetSize(100,20)
            btn:SetText(text)
            btn.DoClick = function()
                local cur = GetConVarNumber(convar)
                RunConsoleCommand(convar, cur==1 and 0 or 1)
            end
            btn.Paint = function(self,w,h)
                local state = GetConVarNumber(convar)
                if state==1 then
                    surface.SetDrawColor(60,60,60,255)
                    surface.DrawRect(0,0,w,h)
                    surface.SetDrawColor(20,255,20,200)
                    surface.DrawOutlinedRect(0,0,w,h)
                else
                    surface.SetDrawColor(50,50,50,255)
                    surface.DrawRect(0,0,w,h)
                    surface.SetDrawColor(120,120,120,200)
                    surface.DrawOutlinedRect(0,0,w,h)
                end
            end
            return btn
        end
        addBtn(20,40,"HEADTRACERS","rz_headtracers")
        addBtn(135,40,"XRAY","rz_xray")
        addBtn(135,70,"CHAMS","rz_chams")
        addBtn(20,70,"EYETRACERS","rz_eyetracers")
        addBtn(20,100,"ESP","rz_esp")
        addBtn(135,100,"PLAYER TRACERS","rz_tracers")
        addBtn(20,130,"TRACE PROPS","rz_traceprop")
        addBtn(135,130,"HUD STATS","rz_hud")
        addBtn(135,160,"CROSSHAIR","rz_crosshair")
        addBtn(20,160,"REMOVE SKYBOX","rz_skybox")
        addBtn(20,190,"PROP DISTANCE","rz_propdist")
        
        local binderBtn = vgui.Create("DButton", frame)
        binderBtn:SetPos(135,190)
        binderBtn:SetSize(100,20)
        binderBtn:SetText("PROP BINDER")
        binderBtn:SetTextColor(Color(255,255,0))
        binderBtn.Paint = function(self,w,h)
            surface.SetDrawColor(80,0,80,255)
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(255,0,255,200)
            surface.DrawOutlinedRect(0,0,w,h)
        end
        binderBtn.DoClick = function() OpenPropBinder() end
        
        local fovSlide = vgui.Create("DNumSlider", frame)
        fovSlide:SetPos(30,241)
        fovSlide:SetSize(220,20)
        fovSlide:SetText("FOV")
        fovSlide:SetConVar("rz_fov")
        fovSlide:SetMinMax(20,150)
        fovSlide:SetDecimals(0)
        
        local crossSize = vgui.Create("DNumSlider", frame)
        crossSize:SetPos(30,265)
        crossSize:SetSize(220,20)
        crossSize:SetText("Crosshair Size")
        crossSize:SetConVar("rz_crosshairsize")
        crossSize:SetMinMax(2,50)
        crossSize:SetDecimals(0)
    end
    
    concommand.Add("nullmenu", MainMenu)
    concommand.Add("rz_menu", MainMenu)
    chat.AddCommand("null", MainMenu)
    
    chat.AddText(Color(0,255,0), "[NullMenu] FULLY LOADED - ESP, FOV, Silent Aim (MOUSE3), Prop Binder (!bindprop)")
end