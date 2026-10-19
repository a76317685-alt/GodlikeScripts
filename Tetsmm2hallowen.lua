-- language: Lua, file: godlike_flyfarm.lua, runtime: Roblox Executor, deps: none
-- *watch for: плавный полёт = BodyVelocity/AlignPosition, НЕ CFrame-телепорт каждый кадр*
-- *watch for: урон от столкновений — отключаем CanCollide пока летим*
-- *watch for: цель движется — каждые 0.2с обновляем направление*

-- ==================== SMOOTH FLY FARM ====================
do
    if getgenv().GodlikeFlyFarm_loaded then
        print("[FlyFarm] already loaded")
        return
    end
    getgenv().GodlikeFlyFarm_loaded = true

    local UIS = game:GetService("UserInputService")
    local WS = game:GetService("Workspace")
    local RunService = game:GetService("RunService")

    -- === состояние ===
    local state = {
        enabled = false,
        speed = 60,           -- studs/sec
        height = 3,           -- высота над целью
        arrivalDist = 4,      -- на каком расстоянии считаем "долетел"
        mode = "candy",       -- candy | coin | both
        smoothness = 0.3,     -- 0.1 = резко, 1.0 = плавно (лаг)
        bv = nil,             -- BodyVelocity
        bg = nil,             -- BodyGyro (стабилизация)
        conn = nil,
        lastTarget = nil,
    }

    local function safeChar() local c = LP.Character; return c and c.Parent and c or nil end
    local function safeRoot() local c = safeChar(); return c and c:FindFirstChild("HumanoidRootPart") end
    local function safeHum()  local c = safeChar(); return c and c:FindFirstChildOfClass("Humanoid") end

    -- === поиск цели ===
    local function isTarget(obj)
        if not obj:IsA("BasePart") then return false end
        local nm = obj.Name:lower()
        if state.mode == "candy" then return nm:find("candy") or nm:find("sweet") or nm:find("treat") end
        if state.mode == "coin"  then return nm:find("coin") end
        -- both
        return nm:find("candy") or nm:find("sweet") or nm:find("coin") or nm:find("treat")
    end

    local function findNearestTarget()
        local root = safeRoot()
        if not root then return nil end
        local best, bd = nil, math.huge
        for _, obj in ipairs(WS:GetDescendants()) do
            if isTarget(obj) then
                local d = (root.Position - obj.Position).Magnitude
                if d < bd then bd = d; best = obj end
            end
        end
        return best, bd
    end

    -- === создание физики ===
    local function setupPhysics()
        local root = safeRoot()
        if not root then return false end

        -- BodyVelocity — движение
        if state.bv and state.bv.Parent then state.bv:Destroy() end
        state.bv = Instance.new("BodyVelocity")
        state.bv.Name = "G_FlyFarm_BV"
        state.bv.Velocity = Vector3.zero
        state.bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        state.bv.P = 5000
        state.bv.Parent = root

        -- BodyGyro — стабилизация (чтобы не крутило)
        if state.bg and state.bg.Parent then state.bg:Destroy() end
        state.bg = Instance.new("BodyGyro")
        state.bg.Name = "G_FlyFarm_BG"
        state.bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        state.bg.D = 500
        state.bg.P = 3000
        state.bg.CFrame = root.CFrame
        state.bg.Parent = root

        -- отключаем коллизии пока летим
        local char = safeChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    p:SetAttribute("G_FlyFarm_OrigCollide", p.CanCollide)
                    p.CanCollide = false
                end
            end
        end
        return true
    end

    local function restorePhysics()
        local root = safeRoot()
        if state.bv then pcall(function() state.bv:Destroy() end); state.bv = nil end
        if state.bg then pcall(function() state.bg:Destroy() end); state.bg = nil end
        -- возвращаем коллизии
        local char = safeChar()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local orig = p:GetAttribute("G_FlyFarm_OrigCollide")
                    if orig ~= nil then p.CanCollide = orig else p.CanCollide = true end
                    p:SetAttribute("G_FlyFarm_OrigCollide", nil)
                end
            end
        end
    end

    -- === основной цикл ===
    local function start()
        if state.enabled then return end
        state.enabled = true

        if not setupPhysics() then
            state.enabled = false
            return
        end

        state.conn = RunService.Heartbeat:Connect(function()
            if not state.enabled then return end
            local root = safeRoot()
            if not root or not state.bv or not state.bv.Parent then return end

            local target, dist = findNearestTarget()
            if not target then
                state.bv.Velocity = Vector3.zero
                return
            end

            state.lastTarget = target

            -- если близко — собираем (Touched сработает если Tool/Part подбираемый; иначе просто рядом)
            if dist < state.arrivalDist then
                state.bv.Velocity = Vector3.zero
                -- пытаемся собрать Tool в Backpack если это Tool
                pcall(function()
                    if target:IsA("Tool") and target.Parent ~= LP.Backpack then
                        target.Parent = LP.Backpack
                    end
                end)
                return
            end

            -- направление к цели с учётом высоты
            local targetPos = target.Position + Vector3.new(0, state.height, 0)
            local delta = targetPos - root.Position
            local dir = delta.Unit
            local velocity = dir * state.speed

            -- плавное приближение скорости (инерция)
            local a = math.clamp(state.smoothness, 0.05, 1)
            state.bv.Velocity = state.bv.Velocity:Lerp(velocity, a)

            -- стабилизация поворота
            if state.bg then
                state.bg.CFrame = CFrame.lookAt(root.Position, targetPos)
            end
        end)

        print("[FlyFarm] started | mode="..state.mode.." speed="..state.speed)
    end

    local function stop()
        state.enabled = false
        if state.conn then state.conn:Disconnect(); state.conn = nil end
        restorePhysics()
        print("[FlyFarm] stopped")
    end

    -- на респавн — перезапустить физику
    LP.CharacterAdded:Connect(function()
        if state.enabled then
            task.wait(1)
            setupPhysics()
        end
    end)

    -- ==================== UI ====================
    local TFly = makeTab("flyfarm")

    local function head(parent, txt)
        return n("TextLabel",{
            Parent=parent, BackgroundTransparency=1,
            Size=UDim2.new(1,-12,0,22), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=COL.titleText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7,
        })
    end

    head(TFly.page, "─ FLY-FARM ─")

    makeToggle(TFly.page, "Fly-to-Coin/Candy (smooth)", "flyfarm_on", false, function(v)
        if v then start() else stop() end
    end)

    -- режим: candy / coin / both
    local modeBtns = {}
    local function modeBtn(label, value)
        local b = n("TextButton",{
            Parent=TFly.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
            Size=UDim2.new(1,-12,0,32), Font=Enum.Font.GothamBold,
            Text=label, TextColor3=COL.tabText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false, ZIndex=6,
        })
        n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
        b.Activated:Connect(function()
            state.mode = value
            for k, btn in pairs(modeBtns) do
                btn.BackgroundColor3 = (k == value) and Color3.fromRGB(200,220,255) or COL.btn
            end
            print("[FlyFarm] mode → "..value)
        end)
        modeBtns[value] = b
        return b
    end
    modeBtn("🍬 Candy only", "candy")
    modeBtn("🪙 Coin only", "coin")
    modeBtn("🎯 Both", "both")
    task.delay(0.1, function()
        for k, b in pairs(modeBtns) do
            b.BackgroundColor3 = (k == state.mode) and Color3.fromRGB(200,220,255) or COL.btn
        end
    end)

    head(TFly.page, "─ TUNING ─")

    makeSlider(TFly.page, "Flight Speed", "flyfarm_speed", 20, 200, 60, function(v)
        state.speed = v
    end)

    makeSlider(TFly.page, "Smoothness (0.05 резко — 1 плавно)", "flyfarm_smooth", 5, 100, 30, function(v)
        state.smoothness = v / 100
    end)

    makeSlider(TFly.page, "Height above target", "flyfarm_height", 0, 15, 3, function(v)
        state.height = v
    end)

    makeSlider(TFly.page, "Arrival distance", "flyfarm_arrive", 1, 20, 4, function(v)
        state.arrivalDist = v
    end)

    head(TFly.page, "─ STATUS ─")

    local statusLbl = n("TextLabel",{
        Parent=TFly.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,50), Font=Enum.Font.Code,
        Text="", TextColor3=COL.tabText, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true, ZIndex=6,
    })
    n("UIPadding",{Parent=statusLbl,PaddingLeft=UDim.new(0,10),PaddingTop=UDim.new(0,6)})

    task.spawn(function()
        while task.wait(0.3) do
            if state.enabled then
                local target = state.lastTarget
                local dist = "?"
                local root = safeRoot()
                if target and target.Parent and root then
                    dist = tostring(math.floor((root.Position - target.Position).Magnitude))
                end
                statusLbl.Text = string.format(
                    "status: FLYING\nmode: %s\nspeed: %d\ntarget dist: %s",
                    state.mode, state.speed, dist
                )
            else
                statusLbl.Text = "status: stopped"
            end
        end
    end)

    getgenv().GodlikeFlyFarm = {
        start = start,
        stop = stop,
        state = state,
    }

    print("[FlyFarm] loaded — smooth flight to coin/candy")
end
-- ==================== END SMOOTH FLY FARM ====================
