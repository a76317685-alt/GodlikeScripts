-- language: Lua, file: godlike_fly_v3.lua, runtime: Roblox Executor, deps: none
-- *watch for: CFrame-интерполяция вместо BodyVelocity — работает ВСЕГДА*
-- *watch for: ищем ВСЕ Coin/Candy через Workspace:GetDescendants() как в твоём коде*
-- *watch for: плавность через CFrame:Lerp(1 - 0.7^dt) — 60fps = плавно*

-- ==================== FLY-TO-COIN v3 (CFrame smooth) ====================
do
    if getgenv().GodlikeFlyV3_loaded then
        print("[FlyV3] already loaded")
        return
    end
    getgenv().GodlikeFlyV3_loaded = true

    local RunService = game:GetService("RunService")
    local WS = game:GetService("Workspace")

    local flyState = {
        enabled = false,
        speed = 2.5,       -- множитель интерполяции (1-10)
        conn = nil,
        mode = "both",
    }

    local function safeChar() local c = LP.Character; return c and c.Parent and c or nil end
    local function safeRoot() local c = safeChar(); return c and c:FindFirstChild("HumanoidRootPart") end

    -- === твой поиск: ВСЕ Coin/Candy в Workspace ===
    local function findNearest()
        local r = safeRoot()
        if not r then return nil, math.huge end
        local closest, dist = nil, math.huge
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("BasePart") then
                local nm = obj.Name:lower()
                local isCoin = nm:find("coin")
                local isCandy = nm:find("candy") or nm:find("sweet") or nm:find("treat")
                local match = (flyState.mode == "coin" and isCoin)
                    or (flyState.mode == "candy" and isCandy)
                    or (flyState.mode == "both" and (isCoin or isCandy))
                if match then
                    local d = (r.Position - obj.Position).Magnitude
                    if d < dist then dist = d; closest = obj end
                end
            end
        end
        return closest, dist
    end

    -- === плавный полёт через CFrame Lerp ===
    local function start()
        if flyState.enabled then return end
        flyState.enabled = true

        flyState.conn = RunService.RenderStepped:Connect(function(dt)
            if not flyState.enabled then return end
            local root = safeRoot()
            if not root then return end

            local target, dist = findNearest()
            if not target then return end

            -- цель = позиция монеты + 3 сверху
            local goal = CFrame.new(target.Position + Vector3.new(0, 3, 0))

            -- плавная интерполяция: чем больше speed, тем быстрее
            -- dt = время кадра, alpha = 1 - 0.7^(speed*dt*60)
            local alpha = 1 - math.pow(0.85, flyState.speed * dt * 60)
            alpha = math.clamp(alpha, 0, 1)

            root.CFrame = root.CFrame:Lerp(goal, alpha)

            -- если очень близко — сразу на цель
            if dist < 4 then
                root.CFrame = goal
                -- подбор Tool
                pcall(function()
                    if target:IsA("Tool") and target.Parent ~= LP.Backpack then
                        target.Parent = LP.Backpack
                    end
                end)
            end
        end)

        print("[FlyV3] started | mode="..flyState.mode.." speed="..flyState.speed)
    end

    local function stop()
        flyState.enabled = false
        if flyState.conn then flyState.conn:Disconnect(); flyState.conn = nil end
        print("[FlyV3] stopped")
    end

    -- === UI ===
    local TFly = makeTab("flyv3")

    local function head(parent, txt)
        return n("TextLabel",{
            Parent=parent, BackgroundTransparency=1,
            Size=UDim2.new(1,-12,0,22), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=COL.titleText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7,
        })
    end

    head(TFly.page, "─ FLY-TO-COIN (smooth CFrame) ─")

    makeToggle(TFly.page, "Fly to Coin/Candy", "flyv3_on", false, function(v)
        if v then start() else stop() end
    end)

    local modeBtns = {}
    local function modeBtn(label, value)
        local b = n("TextButton",{
            Parent=TFly.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
            Size=UDim2.new(1,-12,0,32), Font=Enum.Font.GothamBold,
            Text=label, TextColor3=COL.tabText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=6,
        })
        n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
        b.Activated:Connect(function()
            flyState.mode = value
            for k, btn in pairs(modeBtns) do
                btn.BackgroundColor3 = (k == value) and Color3.fromRGB(200,220,255) or COL.btn
            end
        end)
        modeBtns[value] = b
        return b
    end
    modeBtn("🍬 Candy only", "candy")
    modeBtn("🪙 Coin only", "coin")
    modeBtn("🎯 Both", "both")
    task.delay(0.1, function()
        for k, b in pairs(modeBtns) do
            b.BackgroundColor3 = (k == flyState.mode) and Color3.fromRGB(200,220,255) or COL.btn
        end
    end)

    makeSlider(TFly.page, "Fly Speed", "flyv3_speed", 1, 10, 3, function(v)
        flyState.speed = v
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
            local r = safeRoot()
            local t, d = findNearest()
            statusLbl.Text = string.format(
                "enabled: %s\nmode: %s\nspeed: %d\ntarget dist: %s",
                tostring(flyState.enabled), flyState.mode, flyState.speed,
                t and math.floor(d) or "—"
            )
        end
    end)

    getgenv().GodlikeFlyV3 = {start=start, stop=stop, state=flyState}
    print("[FlyV3] loaded — CFrame smooth, твой поиск")
end
-- ==================== END FLY V3 ====================
