-- language: Lua, file: godlike_10menu.lua, runtime: Roblox Executor, deps: none
-- *watch for: ставится в конец, отдельный ScreenGui*
-- *watch for: одна кнопка → Popup с 10 функциями, вкладок нет — просто список*

-- ==================== 10-FUNC MENU ====================
do
    if getgenv().Godlike10_loaded then
        print("[10Menu] already loaded")
        return
    end
    getgenv().Godlike10_loaded = true

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

    -- === GUI ===
    local gui = n2("ScreenGui",{Name="Godlike10",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})

    -- ОДНА кнопка
    local OpenBtn = n2("TextButton",{
        Parent = gui,
        BackgroundColor3 = Color3.fromRGB(255,140,40),
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -150, 1, -80),
        Size = UDim2.new(0, 130, 0, 50),
        Font = Enum.Font.GothamBold,
        Text = "🎃 GODLIKE",
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 500,
    })
    n2("UICorner",{CornerRadius=UDim.new(0,10),Parent=OpenBtn})
    n2("UIStroke",{Color=Color3.fromRGB(255,200,100),Thickness=2,Parent=OpenBtn})

    -- Popup меню
    local Popup = n2("Frame",{
        Parent = gui,
        BackgroundColor3 = Color3.fromRGB(15,15,20),
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -180, 0.5, -240),
        Size = UDim2.new(0, 360, 0, 480),
        Visible = false, Active = true,
        ZIndex = 600,
    })
    n2("UICorner",{CornerRadius=UDim.new(0,10),Parent=Popup})
    n2("UIStroke",{Color=Color3.fromRGB(255,140,40),Thickness=2,Parent=Popup})

    -- Topbar
    local Top = n2("Frame",{
        Parent=Popup, BackgroundColor3=Color3.fromRGB(40,20,10),
        BackgroundTransparency=0.1, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,40), Active=true, ZIndex=610,
    })
    n2("UICorner",{CornerRadius=UDim.new(0,10),Parent=Top})
    n2("TextLabel",{
        Parent=Top, BackgroundTransparency=1, Position=UDim2.new(0,12,0,0),
        Size=UDim2.new(1,-50,1,0), Font=Enum.Font.GothamBold,
        Text="Godlike · 10 Functions", TextColor3=Color3.fromRGB(255,180,60),
        TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=611,
    })
    local CloseBtn = n2("TextButton",{
        Parent=Top, BackgroundTransparency=1, Position=UDim2.new(1,-34,0,8),
        Size=UDim2.new(0,26,0,24), Font=Enum.Font.GothamBold, Text="×",
        TextColor3=Color3.fromRGB(255,80,80), TextSize=20, AutoButtonColor=false, ZIndex=611,
    })
    CloseBtn.Activated:Connect(function() Popup.Visible = false end)

    -- drag
    local dragging, dragStart, startPos
    Top.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=Popup.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            Popup.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)

    OpenBtn.Activated:Connect(function() Popup.Visible = not Popup.Visible end)

    -- Content
    local Content = n2("ScrollingFrame",{
        Parent=Popup, BackgroundTransparency=1, BorderSizePixel=0,
        Position=UDim2.new(0,0,0,44), Size=UDim2.new(1,0,1,-44),
        ScrollBarThickness=4, CanvasSize=UDim2.new(0,0,0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, ClipsDescendants=true, ZIndex=605,
    })
    n2("UIListLayout",{Parent=Content,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
    n2("UIPadding",{Parent=Content,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})

    local function head(txt)
        return n2("TextLabel",{
            Parent=Content, BackgroundTransparency=1, Size=UDim2.new(1,-12,0,20),
            Font=Enum.Font.GothamBold, Text=txt, TextColor3=Color3.fromRGB(255,180,60),
            TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=606,
        })
    end
    local function btn(txt, cb, col)
        local b = n2("TextButton",{
            Parent=Content, BackgroundColor3=col or Color3.fromRGB(45,45,55),
            BorderSizePixel=0, Size=UDim2.new(1,-12,0,38), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=606,
        })
        n2("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n2("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
        b.Activated:Connect(cb)
        return b
    end
    local function toggle(txt, key, default, cb)
        local state = default
        local b = n2("TextButton",{
            Parent=Content, BackgroundColor3=Color3.fromRGB(45,45,55),
            BorderSizePixel=0, Size=UDim2.new(1,-12,0,38), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=Color3.fromRGB(240,240,240), TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=606,
        })
        n2("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n2("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
        local ind = n2("Frame",{
            Parent=b, BackgroundColor3=state and Color3.fromRGB(255,140,40) or Color3.fromRGB(100,100,120),
            BorderSizePixel=0, Position=UDim2.new(1,-28,0,11), Size=UDim2.new(0,16,0,16), ZIndex=607,
        })
        n2("UICorner",{CornerRadius=UDim.new(1,0),Parent=ind})
        local function apply(v)
            state = v
            ind.BackgroundColor3 = v and Color3.fromRGB(255,140,40) or Color3.fromRGB(100,100,120)
            if cb then cb(v) end
        end
        b.Activated:Connect(function() apply(not state) end)
        getgenv().Mini10Reg = getgenv().Mini10Reg or {}
        getgenv().Mini10Reg[key] = {set=apply, get=function() return state end}
        return b
    end
    local Reg = function(k) return getgenv().Mini10Reg and getgenv().Mini10Reg[k] end

    -- ============ ФУНКЦИИ ============

    -- 1) FLY-FARM (плавный)
    local flyState = { enabled=false, speed=60, bv=nil, bg=nil, conn=nil, mode="both" }
    local coinCache = {}
    task.spawn(function()
        while task.wait(1.5) do
            coinCache = {}
            for _, o in ipairs(WS:GetDescendants()) do
                if o:IsA("BasePart") then
                    local nm = o.Name:lower()
                    if nm:find("coin") or nm:find("candy") or nm:find("sweet") or nm:find("treat") then
                        coinCache[#coinCache+1] = o
                    end
                end
            end
        end
    end)

    local function findNearest()
        local r = safeRoot()
        if not r then return nil, math.huge end
        local best, bd = nil, math.huge
        for _, o in ipairs(coinCache) do
            if o and o.Parent then
                local d = (r.Position - o.Position).Magnitude
                if d < bd then bd = d; best = o end
            end
        end
        return best, bd
    end

    local function startFly()
        if flyState.enabled then return end
        local r = safeRoot(); local h = safeHum()
        if not r or not h then return end
        if r.Anchored then r.Anchored = false end
        h.PlatformStand = true
        flyState.enabled = true
        flyState.bv = Instance.new("BodyVelocity")
        flyState.bv.MaxForce = Vector3.new(1e6,1e6,1e6)
        flyState.bv.P = 8000
        flyState.bv.Parent = r
        flyState.bg = Instance.new("BodyGyro")
        flyState.bg.MaxTorque = Vector3.new(1e6,1e6,1e6)
        flyState.bg.P = 5000
        flyState.bg.D = 500
        flyState.bg.Parent = r
        local c = safeChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
        flyState.conn = RunService.Heartbeat:Connect(function()
            if not flyState.enabled then return end
            local root = safeRoot(); if not root then return end
            if not flyState.bv.Parent then
                flyState.bv = Instance.new("BodyVelocity")
                flyState.bv.MaxForce = Vector3.new(1e6,1e6,1e6)
                flyState.bv.P = 8000
                flyState.bv.Parent = root
            end
            local t, d = findNearest()
            if not t then flyState.bv.Velocity = Vector3.zero; return end
            if d < 5 then flyState.bv.Velocity = Vector3.zero; return end
            local targetPos = t.Position + Vector3.new(0,2,0)
            local dir = (targetPos - root.Position).Unit
            flyState.bv.Velocity = dir * flyState.speed
            flyState.bg.CFrame = CFrame.lookAt(root.Position, targetPos)
        end)
        print("[10Menu] fly started")
    end

    local function stopFly()
        flyState.enabled = false
        if flyState.conn then flyState.conn:Disconnect(); flyState.conn=nil end
        if flyState.bv then flyState.bv:Destroy(); flyState.bv=nil end
        if flyState.bg then flyState.bg:Destroy(); flyState.bg=nil end
        local h = safeHum(); if h then h.PlatformStand = false end
        local c = safeChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end

    -- 2) ДРОНЫ
    local drones = {}
    local function spawnDrone()
        if #drones >= 5 then return end
        local r = safeRoot(); if not r then return end
        local d = n2("Part",{
            Size=Vector3.new(1.5,1.5,2), Color=Color3.fromRGB(200,50,50),
            Material=Enum.Material.Neon, CanCollide=false, Anchored=false,
            CFrame=r.CFrame * CFrame.new(0,5,-8), Parent=WS,
        })
        local bv = n2("BodyVelocity",{
            Velocity=Vector3.new(0,0,0), MaxForce=Vector3.new(1e6,1e6,1e6),
            Parent=d,
        })
        table.insert(drones, {part=d, bv=bv})
        task.spawn(function()
            for i = 1, 150 do
                task.wait(0.1)
                if not d.Parent then break end
                local best, bd = nil, math.huge
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (d.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if dist < bd then bd = dist; best = p end
                    end
                end
                if best and bd < 4 then
                    pcall(function()
                        local ex = Instance.new("Explosion")
                        ex.Position = d.Position
                        ex.BlastRadius = 15
                        ex.BlastPressure = 0
                        ex.DestroyJointRadiusPercent = 0
                        ex.Parent = WS
                        local hrp = best.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bv2 = Instance.new("BodyVelocity")
                            bv2.Velocity = Vector3.new(1e5,1e5,1e5)
                            bv2.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                            bv2.Parent = hrp
                            game:GetService("Debris"):AddItem(bv2, 0.2)
                        end
                    end)
                    d:Destroy()
                    break
                elseif best then
                    local dir = (best.Character.HumanoidRootPart.Position + Vector3.new(0,2,0) - d.Position).Unit
                    bv.Velocity = dir * 80
                end
            end
            if d.Parent then d:Destroy() end
        end)
    end

    -- ============ СПИСОК 10 ФУНКЦИЙ ============
    head("─ FARM ─")
    toggle("✈ Fly-to-Coin (smooth)", "fly", false, function(v)
        if v then startFly() else stopFly() end
    end)
    btn("🎯 Mode: coin / candy / both", function()
        local modes = {"coin","candy","both"}
        local i = 1
        for k, v in ipairs(modes) do if v == flyState.mode then i = k; break end end
        flyState.mode = modes[(i % #modes) + 1]
        print("[10Menu] mode → "..flyState.mode)
    end)
    toggle("🕶 Noclip", "noclip", false, function(v)
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

    head("─ DRONES ─")
    btn("🚀 Spawn Drone (kamikaze)", function() spawnDrone() end, Color3.fromRGB(120,50,50))
    btn("✈ Spawn 3 Drones", function()
        for i = 1, 3 do spawnDrone(); task.wait(0.2) end
    end, Color3.fromRGB(120,50,50))
    btn("🧹 Clear Drones", function()
        for i = #drones, 1, -1 do
            if drones[i].part then drones[i].part:Destroy() end
            table.remove(drones, i)
        end
    end)

    head("─ COMBAT ─")
    toggle("⚔ Auto Kill Murderer", "akm", false, function(v)
        if v then
            task.spawn(function()
                while Reg("akm") and Reg("akm").get() do
                    task.wait(0.4)
                    local t = getNearest and getNearest(function(p) return getRole and getRole(p) == "MURDERER" end)
                    if t and t.Character then
                        local r = safeRoot(); local c = safeChar(); local h = safeHum()
                        if r and c and h then
                            local tool = c:FindFirstChild("Gun") or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
                            if tool then
                                pcall(function()
                                    if tool.Parent ~= c then h:EquipTool(tool) end
                                    r.CFrame = CFrame.new(r.Position, t.Character.HumanoidRootPart.Position)
                                    task.wait(0.03)
                                    tool:Activate()
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end)

    head("─ UTIL ─")
    btn("🔫 Auto Shoot (loop)", function()
        if not (Reg("ashoot") and Reg("ashoot").get()) then return end
    end)
    toggle("🔫 Auto Shoot Murderer", "ashoot", false, function(v)
        if v then
            task.spawn(function()
                while Reg("ashoot") and Reg("ashoot").get() do
                    task.wait(0.15)
                    local t = getNearest and getNearest(function(p) return getRole and getRole(p) == "MURDERER" end)
                    if t and t.Character then
                        local r = safeRoot(); local c = safeChar(); local h = safeHum()
                        if r and c and h then
                            local g = c:FindFirstChild("Gun") or (LP.Backpack and LP.Backpack:FindFirstChild("Gun"))
                            if g then
                                pcall(function()
                                    if g.Parent ~= c then h:EquipTool(g) end
                                    r.CFrame = CFrame.new(r.Position, t.Character.HumanoidRootPart.Position)
                                    task.wait(0.02)
                                    g:Activate()
                                end)
                            end
                        end
                    end
                end
            end)
        end
    end)
    btn("📋 Copy JobId", function()
        if setclipboard then setclipboard(game.JobId) end
    end)
    btn("♻ Rejoin", function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LP, game.JobId)
    end)

    head("─ ABOUT ─")
    btn("📜 Version: v1.5.0 (10 funcs)", function()
        print("[10Menu] v1.5.0 — 10 functions")
    end)
    btn("ℹ Info", function()
        local executor = "?"
        pcall(function() executor = identifyexecutor and identifyexecutor() or "?" end)
        print("[10Menu] executor="..executor.." user="..LP.Name)
    end)

    print("[10Menu] loaded — 10 functions, one button")
end
-- ==================== END 10-FUNC MENU ====================
