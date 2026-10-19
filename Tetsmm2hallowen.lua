-- language: Lua, file: godlike_mini_hub.lua, runtime: Roblox Executor, deps: none
-- *watch for: отдельный ScreenGui — не зависит от tabs/makeTab основного хаба*
-- *watch for: fly-to-coin = BodyVelocity + BodyGyro, плавно, без телепорта*
-- *watch for: auto kill murderer = Knife Activate если мурдер, Gun если шериф/инносент*

-- ==================== MINI HUB (20 functions) ====================
do
    if getgenv().GodlikeMiniHub_loaded then
        print("[MiniHub] already loaded")
        return
    end
    getgenv().GodlikeMiniHub_loaded = true

    local Players    = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS        = game:GetService("UserInputService")
    local WS         = game:GetService("Workspace")
    local LP         = Players.LocalPlayer
    local CoreGui    = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

    local function n2(c, p) local i = Instance.new(c); for k, v in pairs(p or {}) do i[k] = v end; return i end
    local function safeChar() local c = LP.Character; return c and c.Parent and c or nil end
    local function safeRoot() local c = safeChar(); return c and c:FindFirstChild("HumanoidRootPart") end
    local function safeHum() local c = safeChar(); return c and c:FindFirstChildOfClass("Humanoid") end

    -- === роль ===
    local function role(p)
        p = p or LP
        local c = p.Character
        if not c then return "UNKNOWN" end
        local bp = p:FindFirstChild("Backpack")
        local function has(nm)
            if c:FindFirstChild(nm) then return true end
            if bp and bp:FindFirstChild(nm) then return true end
            return false
        end
        for _, x in ipairs({"Knife","Dagger","MurdererKnife"}) do
            if has(x) then return "MURDERER" end
        end
        for _, x in ipairs({"Gun","Revolver","Pistol","SheriffGun"}) do
            if has(x) then return "SHERIFF" end
        end
        for _, o in ipairs(c:GetChildren()) do
            if o:IsA("Tool") then return "ARMED" end
        end
        return "INNOCENT"
    end
    local function isMurd(p) return role(p) == "MURDERER" end
    local function nearest(pred)
        local best, bd = nil, math.huge
        local r = safeRoot()
        if not r then return nil end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if not pred or pred(p) then
                    local d = (r.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if d < bd then bd = d; best = p end
                end
            end
        end
        return best, bd
    end

    -- ==================== GUI ====================
    local gui = n2("ScreenGui",{Name="GodlikeMiniHub",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})

    local Main = n2("Frame",{
        Parent=gui, BackgroundColor3=Color3.fromRGB(15,15,20), BackgroundTransparency=0.08,
        BorderSizePixel=0, Position=UDim2.new(0.5,-180,0.5,-240),
        Size=UDim2.new(0,360,0,480), Active=true, ZIndex=1,
    })
    n2("UICorner",{CornerRadius=UDim.new(0,10),Parent=Main})
    n2("UIStroke",{Color=Color3.fromRGB(255,140,40),Thickness=2,Parent=Main})

    local Top = n2("Frame",{
        Parent=Main, BackgroundColor3=Color3.fromRGB(40,20,10), BackgroundTransparency=0.1,
        BorderSizePixel=0, Size=UDim2.new(1,0,0,36), Active=true, ZIndex=10,
    })
    n2("UICorner",{CornerRadius=UDim.new(0,10),Parent=Top})
    n2("TextLabel",{
        Parent=Top, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0),
        Size=UDim2.new(1,-50,1,0), Font=Enum.Font.GothamBold,
        Text="🎃 GODLIKE MINI | 20 FUNCS", TextColor3=Color3.fromRGB(255,180,60),
        TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=11,
    })
    local CloseBtn = n2("TextButton",{
        Parent=Top, BackgroundTransparency=1, Position=UDim2.new(1,-34,0,6),
        Size=UDim2.new(0,26,0,24), Font=Enum.Font.GothamBold, Text="×",
        TextColor3=Color3.fromRGB(255,80,80), TextSize=20, AutoButtonColor=false, ZIndex=11,
    })
    CloseBtn.Activated:Connect(function() Main.Visible = false end)

    -- drag
    local dragging, dragStart, startPos
    Top.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=Main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    -- контент
    local Content = n2("ScrollingFrame",{
        Parent=Main, BackgroundTransparency=1, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,40), Size=UDim2.new(1,0,1,-40),
        ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, ClipsDescendants=true, ZIndex=2,
    })
    n2("UIListLayout",{Parent=Content,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
    n2("UIPadding",{Parent=Content,PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),
        PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

    -- элементы
    local function head(txt)
        return n2("TextLabel",{
            Parent=Content, BackgroundTransparency=1, Size=UDim2.new(1,-12,0,20),
            Font=Enum.Font.GothamBold, Text=txt, TextColor3=Color3.fromRGB(255,180,60),
            TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3,
        })
    end

    local function btn(txt, cb, color)
        local b = n2("TextButton",{
            Parent=Content, BackgroundColor3=color or Color3.fromRGB(45,45,55),
            BorderSizePixel=0, Size=UDim2.new(1,-12,0,32), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=3,
        })
        n2("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n2("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,10)})
        b.Activated:Connect(cb)
        return b
    end

    local function toggle(txt, key, default, cb)
        local state = default
        local b = n2("TextButton",{
            Parent=Content, BackgroundColor3=Color3.fromRGB(45,45,55),
            BorderSizePixel=0, Size=UDim2.new(1,-12,0,32), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=3,
        })
        n2("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n2("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,10)})
        local ind = n2("Frame",{
            Parent=b, BackgroundColor3=state and Color3.fromRGB(255,140,40) or Color3.fromRGB(100,100,120),
            BorderSizePixel=0, Position=UDim2.new(1,-26,0,8), Size=UDim2.new(0,14,0,14), ZIndex=4,
        })
        n2("UICorner",{CornerRadius=UDim.new(1,0),Parent=ind})
        local function apply(v)
            state = v
            ind.BackgroundColor3 = v and Color3.fromRGB(255,140,40) or Color3.fromRGB(100,100,120)
            if cb then cb(v) end
        end
        b.Activated:Connect(function() apply(not state) end)
        getgenv().MiniHubRegistry = getgenv().MiniHubRegistry or {}
        getgenv().MiniHubRegistry[key] = {set=apply, get=function() return state end}
        return b
    end

    local Reg = function(k) return getgenv().MiniHubRegistry and getgenv().MiniHubRegistry[k] end

    -- ==================== FLY-TO-COIN ====================
    local flyState = { enabled=false, speed=60, bv=nil, bg=nil, conn=nil, mode="coin" }

    local function startFly()
        if flyState.enabled then return end
        local r = safeRoot()
        if not r then return end
        flyState.enabled = true
        flyState.bv = Instance.new("BodyVelocity")
        flyState.bv.Velocity = Vector3.zero
        flyState.bv.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyState.bv.P = 5000
        flyState.bv.Parent = r
        flyState.bg = Instance.new("BodyGyro")
        flyState.bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
        flyState.bg.P = 3000
        flyState.bg.D = 500
        flyState.bg.Parent = r
        -- noclip во время полёта
        local c = safeChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    p:SetAttribute("G_FlyOrig", p.CanCollide)
                    p.CanCollide = false
                end
            end
        end
        flyState.conn = RunService.Heartbeat:Connect(function()
            if not flyState.enabled then return end
            local root = safeRoot()
            if not root or not flyState.bv.Parent then return end
            -- ищем цель
            local best, bd = nil, math.huge
            for _, o in ipairs(WS:GetDescendants()) do
                if o:IsA("BasePart") then
                    local nm = o.Name:lower()
                    local isCoin = nm:find("coin")
                    local isCandy = nm:find("candy") or nm:find("sweet") or nm:find("treat")
                    local match = (flyState.mode == "coin" and isCoin)
                        or (flyState.mode == "candy" and isCandy)
                        or (flyState.mode == "both" and (isCoin or isCandy))
                    if match then
                        local d = (root.Position - o.Position).Magnitude
                        if d < bd then bd = d; best = o end
                    end
                end
            end
            if best then
                if bd < 4 then
                    flyState.bv.Velocity = Vector3.zero
                    pcall(function()
                        if best:IsA("Tool") and best.Parent ~= LP.Backpack then
                            best.Parent = LP.Backpack
                        end
                    end)
                else
                    local targetPos = best.Position + Vector3.new(0, 3, 0)
                    local dir = (targetPos - root.Position).Unit
                    flyState.bv.Velocity = flyState.bv.Velocity:Lerp(dir * flyState.speed, 0.3)
                    flyState.bg.CFrame = CFrame.lookAt(root.Position, targetPos)
                end
            else
                flyState.bv.Velocity = Vector3.zero
            end
        end)
    end

    local function stopFly()
        flyState.enabled = false
        if flyState.conn then flyState.conn:Disconnect(); flyState.conn = nil end
        if flyState.bv then flyState.bv:Destroy(); flyState.bv = nil end
        if flyState.bg then flyState.bg:Destroy(); flyState.bg = nil end
        local c = safeChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then
                    local orig = p:GetAttribute("G_FlyOrig")
                    p.CanCollide = (orig ~= nil) and orig or true
                    p:SetAttribute("G_FlyOrig", nil)
                end
            end
        end
    end

    -- ==================== AUTO KILL MURDERER ====================
    local function autoKillMurd()
        if not (Reg("akm") and Reg("akm").get()) then return end
        local t = nearest(function(p)
            if not isMurd(p) then return false end
            local r = role(LP)
            return r ~= "MURDERER"
        end)
        if not t or not t.Character then return end
        local c = safeChar(); if not c then return end
        local h = safeHum();  if not h then return end
        local r = safeRoot(); if not r then return end

        -- выбираем оружие: если мурдер — knife, иначе gun
        local toolName = (role(LP) == "MURDERER") and "Knife" or "Gun"
        local tool = c:FindFirstChild(toolName) or (LP.Backpack and LP.Backpack:FindFirstChild(toolName))
        if not tool then return end
        pcall(function()
            if tool.Parent ~= c then h:EquipTool(tool) end
            r.CFrame = CFrame.new(r.Position, t.Character.HumanoidRootPart.Position)
            task.wait(0.03)
            tool:Activate()
        end)
    end

    -- ==================== AUTO SHOOT MURDERER ====================
    local function autoShootMurd()
        if not (Reg("asm") and Reg("asm").get()) then return end
        local t = nearest(function(p) return isMurd(p) end)
        if not t or not t.Character then return end
        local c = safeChar(); if not c then return end
        local h = safeHum();  if not h then return end
        local r = safeRoot(); if not r then return end
        local g = c:FindFirstChild("Gun") or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
        if not g then return end
        pcall(function()
            if g.Parent ~= c then h:EquipTool(g) end
            r.CFrame = CFrame.new(r.Position, t.Character.HumanoidRootPart.Position)
            task.wait(0.02)
            g:Activate()
        end)
    end

    -- ==================== FLING ====================
    local function flingPlayer(p)
        if not p or not p.Character then return end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        pcall(function()
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(1e5,1e5,1e5)
            bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            bv.Parent = hrp
            game:GetService("Debris"):AddItem(bv, 1)
        end)
    end

    -- ==================== RESET COINS ====================
    local function resetCoins()
        -- визуально удаляем все Coin/Candy (только у тебя на экране)
        local count = 0
        for _, o in ipairs(WS:GetDescendants()) do
            if o:IsA("BasePart") then
                local nm = o.Name:lower()
                if nm:find("coin") or nm:find("candy") then
                    o:Destroy()
                    count = count + 1
                end
            end
        end
        print("[MiniHub] cleared "..count.." coins (client-side)")
    end

    -- ==================== ЦИКЛЫ ====================
    task.spawn(function()
        while task.wait(0.4) do pcall(autoKillMurd) end
    end)
    task.spawn(function()
        while task.wait(0.15) do pcall(autoShootMurd) end
    end)

    -- ==================== UI: 20 FUNCS ====================

    -- 1-2 fly
    head("─ FLY FARM ─")
    toggle("Fly to Coin/Candy", "fly", false, function(v)
        if v then startFly() else stopFly() end
    end)
    btn("Mode: coin / candy / both", function()
        local order = {"coin", "candy", "both"}
        local i = 1
        for k, v in ipairs(order) do if v == flyState.mode then i = k; break end end
        flyState.mode = order[(i % #order) + 1]
        print("[MiniHub] fly mode → "..flyState.mode)
    end)
    btn("Noclip toggle", function()
        local c = safeChar(); if not c then return end
        local any = false
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then any = true; break end
        end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = (not any) end
        end
    end)

    -- 3-4 aim
    head("─ COMBAT ─")
    toggle("Auto Kill Murderer", "akm", false)
    toggle("Auto Shoot Murderer", "asm", false)
    btn("Kill Murderer (once)", function()
        local t = nearest(function(p) return isMurd(p) end)
        if t then
            local r = safeRoot(); local c = safeChar(); local h = safeHum()
            if not r or not c or not h then return end
            local toolName = (role(LP) == "MURDERER") and "Knife" or "Gun"
            local tool = c:FindFirstChild(toolName) or (LP.Backpack and LP.Backpack:FindFirstChild(toolName))
            if tool then
                pcall(function()
                    if tool.Parent ~= c then h:EquipTool(tool) end
                    r.CFrame = CFrame.new(r.Position, t.Character.HumanoidRootPart.Position)
                    task.wait(0.03)
                    tool:Activate()
                end)
            end
        end
    end)

    -- 5-6 fling
    head("─ FLING ─")
    btn("Fling Sheriff", function()
        local t = nearest(function(p) return role(p) == "SHERIFF" end)
        if t then flingPlayer(t) end
    end)
    btn("Fling Murderer", function()
        local t = nearest(function(p) return isMurd(p) end)
        if t then flingPlayer(t) end
    end)
    btn("Fling All", function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then flingPlayer(p) end
        end
    end)

    -- 7-8 coins
    head("─ COINS ─")
    btn("Reset all coins (client-side)", function() resetCoins() end, Color3.fromRGB(120,50,50))
    toggle("Auto Collect Coin", "acoin", false, function(v)
        if v then
            task.spawn(function()
                while Reg("acoin") and Reg("acoin").get() do
                    task.wait(0.3)
                    local r = safeRoot(); if not r then continue end
                    for _, o in ipairs(WS:GetDescendants()) do
                        if o:IsA("BasePart") then
                            local nm = o.Name:lower()
                            if nm:find("coin") or nm:find("candy") then
                                if (r.Position - o.Position).Magnitude < 30 then
                                    pcall(function()
                                        if o:IsA("Tool") then o.Parent = LP.Backpack end
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end)

    -- 9-12 movement
    head("─ MOVEMENT ─")
    toggle("Infinite Jump", "ij", false, function(v)
        if v then
            UIS.JumpRequest:Connect(function()
                if Reg("ij") and Reg("ij").get() then
                    local h = safeHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end)
        end
    end)
    toggle("Noclip Always", "noclip", false, function(v)
        if v then
            task.spawn(function()
                while Reg("noclip") and Reg("noclip").get() do
                    task.wait(0.2)
                    local c = safeChar(); if not c then continue end
                    for _, p in ipairs(c:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanCollide = false end
                    end
                end
            end)
        end
    end)
    toggle("God Mode (MaxHealth)", "god", false, function(v)
        if v then
            task.spawn(function()
                while Reg("god") and Reg("god").get() do
                    task.wait(0.3)
                    local h = safeHum(); if h then h.MaxHealth = math.huge; h.Health = math.huge end
                end
            end)
        end
    end)
    toggle("Speed Boost (WalkSpeed 50)", "ws", false, function(v)
        local h = safeHum(); if h then h.WalkSpeed = v and 50 or 16 end
    end)

    -- 13-14 anti
    head("─ ANTI ─")
    toggle("Anti Fling", "af", true, function(v)
        if v then
            task.spawn(function()
                while Reg("af") and Reg("af").get() do
                    task.wait(0.1)
                    local c = safeChar(); if not c then continue end
                    local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
                    for _, v2 in ipairs(hrp:GetChildren()) do
                        if v2:IsA("BodyVelocity") or v2:IsA("BodyGyro") or v2:IsA("BodyAngularVelocity") then
                            v2:Destroy()
                        end
                    end
                    if hrp.Velocity.Magnitude > 200 then
                        hrp.Velocity = Vector3.zero
                    end
                end
            end)
        end
    end)
    toggle("Anti Void", "av", true, function(v)
        if v then
            local lastPos = nil
            task.spawn(function()
                while Reg("av") and Reg("av").get() do
                    task.wait(0.2)
                    local r = safeRoot(); if not r then continue end
                    if r.Position.Y < -50 then
                        if lastPos then r.CFrame = lastPos end
                    else
                        lastPos = r.CFrame
                    end
                end
            end)
        end
    end)

    -- 15-16 server
    head("─ SERVER ─")
    btn("Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP, game.JobId)
    end)
    btn("Copy JobId", function()
        if setclipboard then setclipboard(game.JobId) end
    end)

    -- 17-18 info
    head("─ INFO ─")
    local infoLbl = n2("TextLabel",{
        Parent=Content, BackgroundColor3=Color3.fromRGB(35,35,45),
        BorderSizePixel=0, Size=UDim2.new(1,-12,0,50), Font=Enum.Font.Code,
        Text="", TextColor3=Color3.fromRGB(200,220,255), TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, ZIndex=3,
    })
    n2("UIPadding",{Parent=infoLbl,PaddingLeft=UDim.new(0,10),PaddingTop=UDim.new(0,6)})
    task.spawn(function()
        while task.wait(0.5) do
            infoLbl.Text = string.format(
                "role: %s\nfly: %s | mode: %s",
                role(LP), tostring(flyState.enabled), flyState.mode
            )
        end
    end)

    -- 19-20 open/close
    head("─ UI ─")
    btn("Hide menu (show small cube)", function()
        Main.Visible = false
    end)
    btn("Unload script", function()
        gui:Destroy()
    end)

    print("[MiniHub] loaded — 20 functions ready")
end
-- ==================== END MINI HUB ====================
