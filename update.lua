-- language: Lua, file: godlike_mm2.lua, runtime: Roblox Executor
-- name: Godlike MM2 | Kiti Cube Edition

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TS         = game:GetService("TweenService")
local WS         = game:GetService("Workspace")
local RS         = game:GetService("ReplicatedStorage")
local HS         = game:GetService("HttpService")
local LP         = Players.LocalPlayer
local CoreGui    = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

local function n(c,p) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; return i end

local COL = {
    bg        = Color3.fromRGB(0,0,0),
    bgTrans   = 0.15,
    tabBg     = Color3.fromRGB(230,230,230),
    tabText   = Color3.fromRGB(30,80,200),
    titleText = Color3.fromRGB(60,110,220),
    tabAct    = Color3.fromRGB(255,255,255),
    btn       = Color3.fromRGB(235,235,235),
    good      = Color3.fromRGB(35,140,70),
    bad       = Color3.fromRGB(200,55,55),
}

for _, g in pairs(CoreGui:GetChildren()) do
    if g.Name == "GodlikeScripts" then g:Destroy() end
end

local registry  = {}
local whitelist = {}
whitelist[LP.Name:lower()] = true

-- ==================== GUI ====================
local GUI = n("ScreenGui",{Name="GodlikeScripts",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})

local Main = n("Frame",{Parent=GUI,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Position=UDim2.new(0.5,-440,0.5,-200),Size=UDim2.new(0,880,0,400),Active=true,ZIndex=1})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=Main})
n("UIStroke",{Color=Color3.fromRGB(60,60,60),Thickness=1,Parent=Main})

local Top = n("Frame",{Parent=Main,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Size=UDim2.new(1,0,0,36),Active=true,ZIndex=10})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=Top})
n("TextLabel",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(0.5,0,1,0),Font=Enum.Font.GothamBold,Text="Godlike Scripts",TextColor3=COL.titleText,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
n("TextLabel",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(0.5,0,0,0),Size=UDim2.new(0.4,0,1,0),Font=Enum.Font.GothamBold,Text="Tg:godlike_rb",TextColor3=COL.titleText,TextSize=12,ZIndex=11})

local minBtn   = n("TextButton",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(1,-68,0,6),Size=UDim2.new(0,26,0,24),Font=Enum.Font.GothamBold,Text="—",TextColor3=Color3.fromRGB(60,110,220),TextSize=18,AutoButtonColor=false,ZIndex=11})
local closeBtn = n("TextButton",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(1,-34,0,6),Size=UDim2.new(0,26,0,24),Font=Enum.Font.GothamBold,Text="×",TextColor3=Color3.fromRGB(200,60,60),TextSize=20,AutoButtonColor=false,ZIndex=11})

-- DRAG
local dragging, dragInput, dragStart, startPos
Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragInput = input; dragStart = input.Position; startPos = Main.Position
    end
end)
Top.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
Top.InputEnded:Connect(function(input) if input == dragInput then dragging = false end end)

-- ==================== SIDE ====================
local SideScroll = n("ScrollingFrame",{
    Parent=Main, BackgroundColor3=COL.bg, BackgroundTransparency=COL.bgTrans, BorderSizePixel=0,
    Position=UDim2.new(0,0,0,36), Size=UDim2.new(0,165,1,-36),
    ScrollBarThickness=3, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
    ClipsDescendants=true, ZIndex=2,
})
n("UIListLayout",{Parent=SideScroll,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
n("UIPadding",{Parent=SideScroll,PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)})

-- ==================== BODY ====================
local Body = n("Frame",{Parent=Main,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Position=UDim2.new(0,165,0,36),Size=UDim2.new(1,-165,1,-36),ZIndex=2})
local gradFrame = n("Frame",{Parent=Body,BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=2})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=gradFrame})
n("UIGradient",{Parent=gradFrame,Rotation=90,Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15,15,15)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90,90,90)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(235,235,235)),
}})

-- ==================== TABS ====================
local tabs, activeTab = {}, nil

local function showTab(tab)
    for _, t in pairs(tabs) do
        t.page.Visible = false
        t.btn.BackgroundColor3 = COL.tabBg
    end
    tab.page.Visible = true
    tab.btn.BackgroundColor3 = COL.tabAct
    activeTab = tab
end

local function makeTab(name)
    local btn = n("TextButton",{
        Parent=SideScroll, BackgroundColor3=COL.tabBg, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,44), Font=Enum.Font.GothamBold, Text=name,
        TextColor3=COL.tabText, TextSize=18, TextXAlignment=Enum.TextXAlignment.Left,
        AutoButtonColor=false, ZIndex=4,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=btn})
    n("UIPadding",{Parent=btn,PaddingLeft=UDim.new(0,15)})

    local page = n("ScrollingFrame",{
        Parent=Body, BackgroundTransparency=1, BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0), ScrollBarThickness=3,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
        Visible=false, ClipsDescendants=true, ZIndex=3,
    })
    n("UIListLayout",{Parent=page,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
    n("UIPadding",{Parent=page,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,15),PaddingRight=UDim.new(0,15)})

    local tab = {name=name, btn=btn, page=page}
    table.insert(tabs, tab)
    btn.Activated:Connect(function() showTab(tab) end)
    return tab
end

-- ==================== HELPERS ====================
local function char() return LP.Character or LP.CharacterAdded:Wait() end
local function hum() return char():FindFirstChildOfClass("Humanoid") end
local function root() return char():FindFirstChild("HumanoidRootPart") end
local function tp(cf) if root() then root().CFrame = cf end end

local function getRole(p)
    local t = p or LP
    local c = t.Character
    if not c then return "UNKNOWN" end
    local bp = t:FindFirstChild("Backpack")
    local function hasTool(name)
        if c:FindFirstChild(name) then return true end
        if bp and bp:FindFirstChild(name) then return true end
        return false
    end
    for _, nm in ipairs({"Knife","Dagger","MurdererKnife"}) do
        if hasTool(nm) then return "MURDERER" end
    end
    for _, nm in ipairs({"Gun","Revolver","Pistol","SheriffGun"}) do
        if hasTool(nm) then return "SHERIFF" end
    end
    for _, obj in pairs(c:GetChildren()) do
        if obj:IsA("Tool") then return "ARMED" end
    end
    return "INNOCENT"
end
local function isMurderer(p) return getRole(p)=="MURDERER" end
local function isWL(p) return whitelist[p.Name:lower()] end
local function getNearest(pred)
    local best, bd = nil, math.huge
    if not root() then return nil end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not pred or pred(p) then
                local d = (root().Position - p.Character.HumanoidRootPart.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best, bd
end

-- ==================== ELEMENTS ====================
local function makeRealBtn(parent, txt, cb)
    local b = n("TextButton",{
        Parent=parent, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,36), Font=Enum.Font.GothamBold, Text=txt,
        TextColor3=COL.tabText, TextSize=14, AutoButtonColor=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    b.Activated:Connect(cb)
    return b
end

local function makeToggle(parent, txt, key, default, cb)
    local state = default
    local b = n("TextButton",{
        Parent=parent, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,36), Font=Enum.Font.GothamBold, Text=txt,
        TextColor3=COL.tabText, TextSize=14, TextXAlignment=Enum.TextXAlignment.Left,
        AutoButtonColor=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    n("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
    local indicator = n("Frame",{
        Parent=b, BackgroundColor3=state and COL.good or Color3.fromRGB(120,120,120),
        BorderSizePixel=0, Position=UDim2.new(1,-30,0,10), Size=UDim2.new(0,16,0,16), ZIndex=7,
    })
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=indicator})
    local function apply(v)
        state = v
        indicator.BackgroundColor3 = v and COL.good or Color3.fromRGB(120,120,120)
        if cb then cb(v) end
    end
    b.Activated:Connect(function() apply(not state) end)
    registry[key] = {set=apply, get=function() return state end}
    return b
end

local function makeSlider(parent, txt, key, min, max, default, cb)
    local b = n("Frame",{Parent=parent,BackgroundColor3=COL.btn,BorderSizePixel=0,Size=UDim2.new(1,-12,0,50),ZIndex=6})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    n("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-80,0,20),Font=Enum.Font.GothamBold,Text=txt,TextColor3=COL.tabText,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
    local valLbl = n("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(1,-60,0,4),Size=UDim2.new(0,50,0,20),Font=Enum.Font.GothamBold,Text=tostring(default),TextColor3=COL.tabText,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=7})
    local tr = n("Frame",{Parent=b,BackgroundColor3=Color3.fromRGB(180,180,180),BorderSizePixel=0,Position=UDim2.new(0,12,0,32),Size=UDim2.new(1,-24,0,6),ZIndex=7})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=tr})
    local fl = n("Frame",{Parent=tr,BackgroundColor3=Color3.fromRGB(60,140,220),BorderSizePixel=0,Size=UDim2.new((default-min)/(max-min),0,1,0),ZIndex=8})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=fl})
    local cur = default
    local function apply(v) cur=v; fl.Size=UDim2.new((v-min)/(max-min),0,1,0); valLbl.Text=tostring(v); if cb then cb(v) end end
    local drag=false
    local function upd(i) local r = math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); apply(math.floor(min+(max-min)*r+0.5)) end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i) end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    registry[key] = {set=apply, get=function() return cur end}
end

-- ==================== TABS INIT ====================
local T = {}
T.Main    = makeTab("main")
T.Visual  = makeTab("visual")
T.Combat  = makeTab("combat")
T.Pvp     = makeTab("pvp")
T.Farm    = makeTab("farm")
T.Setting = makeTab("setting")
showTab(T.Main)

-- ==================== MAIN ====================
makeToggle(T.Main.page,"Infinite Jump","ij",false)
makeToggle(T.Main.page,"Noclip","noclip",false)
makeToggle(T.Main.page,"Fly","fly",false)
makeSlider(T.Main.page,"WalkSpeed","ws",16,300,16,function(v) if hum() then hum().WalkSpeed=v end end)
makeSlider(T.Main.page,"JumpPower","jp",50,500,50,function(v) if hum() then hum().JumpPower=v end end)
makeToggle(T.Main.page,"Freeze","freeze",false)
makeToggle(T.Main.page,"God Mode","god",false)
makeToggle(T.Main.page,"Anti Void","antivoid",true)
makeToggle(T.Main.page,"Infinite Stamina","stam",false)
makeToggle(T.Main.page,"Hide Character","hide",false)
makeToggle(T.Main.page,"Ghost","ghost",false)
makeToggle(T.Main.page,"Headless","headless",false)
makeToggle(T.Main.page,"Anti AFK","afk",true)
makeToggle(T.Main.page,"Auto Pickup","pickup",false)
makeToggle(T.Main.page,"Auto Equip Role","auto_equip",true)
makeRealBtn(T.Main.page,"Respawn",function() if LP.Character then LP.Character:BreakJoints() end end)
makeRealBtn(T.Main.page,"Rejoin",function() game:GetService("TeleportService"):Teleport(game.PlaceId, LP, game.JobId) end)
makeRealBtn(T.Main.page,"Server Hop",function()
    local req = (syn and syn.request) or (http and http.request) or http_request
    if not req then return end
    local ok, r = pcall(function() return req({Url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"}) end)
    if not ok then return end
    local ok2, d = pcall(function() return HS:JSONDecode(r.Body) end)
    if not ok2 then return end
    for _, s in pairs(d.data) do
        if s.playing < s.maxPlayers and s.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, s.id, LP)
            return
        end
    end
end)

-- ==================== VISUAL ====================
makeToggle(T.Visual.page,"Player ESP","esp",false)
makeToggle(T.Visual.page,"Murderer ESP","mesp",true)
makeToggle(T.Visual.page,"Sheriff ESP","sesp",true)
makeToggle(T.Visual.page,"Innocent ESP","iesp",false)
makeToggle(T.Visual.page,"Rainbow ESP","rainbow",false)
makeToggle(T.Visual.page,"Name Tags","nt",true)
makeToggle(T.Visual.page,"Distance Tags","dt",true)
makeToggle(T.Visual.page,"Box ESP","box",false)
makeToggle(T.Visual.page,"Tracer Lines","tracer",false)
makeToggle(T.Visual.page,"Skeleton ESP","skel",false)
makeSlider(T.Visual.page,"ESP Distance","esp_dist",100,2000,500)
makeToggle(T.Visual.page,"Fullbright","fb",false)
makeToggle(T.Visual.page,"No Fog","nofog",false)
makeToggle(T.Visual.page,"Night Vision","night",false)
makeSlider(T.Visual.page,"Camera FOV","fov",70,120,70,function(v) if WS.CurrentCamera then WS.CurrentCamera.FieldOfView=v end end)
makeToggle(T.Visual.page,"Watermark","wm",true)
makeToggle(T.Visual.page,"Keybind List","kbl",false)
makeToggle(T.Visual.page,"Role Icons","role_i",true)
makeToggle(T.Visual.page,"Health Bars","hp_bar",true)
makeToggle(T.Visual.page,"Weapon Tags","wtag",false)
makeToggle(T.Visual.page,"Hub User Tags","hubt",true)
makeToggle(T.Visual.page,"FOV Circle","fovc",false)
makeToggle(T.Visual.page,"Anti Flash","aflash",false)

-- ==================== COMBAT ====================
makeRealBtn(T.Combat.page,"Kill Murderer",function()
    local t = getNearest(isMurderer)
    if not t then return end
    local g = LP.Backpack:FindFirstChild("Gun") or char():FindFirstChild("Gun")
    if g and root() then hum():EquipTool(g); root().CFrame = CFrame.new(root().Position, t.Character.HumanoidRootPart.Position); task.wait(0.05); g:Activate() end
end)
makeToggle(T.Combat.page,"Auto Shoot Murderer","autoshoot",false)
makeToggle(T.Combat.page,"Silent Aim","silent",false)
makeToggle(T.Combat.page,"Trigger Bot","trigger",false)
makeSlider(T.Combat.page,"Aim FOV","aim_fov",10,500,150)
makeSlider(T.Combat.page,"Shot Delay (ms)","sdelay",30,500,100)
makeToggle(T.Combat.page,"Infinite Ammo","iammo",false)
makeToggle(T.Combat.page,"Fast Reload","freload",false)
makeToggle(T.Combat.page,"No Recoil","norecoil",false)
makeToggle(T.Combat.page,"Hitbox Expander","hitbox",false)
makeSlider(T.Combat.page,"Hitbox Size","hsize",2,20,5)
makeToggle(T.Combat.page,"Auto Stab","autostab",false)
makeSlider(T.Combat.page,"Stab Range","srange",3,15,8)
makeToggle(T.Combat.page,"Anti Backstab","abs",false)
makeToggle(T.Combat.page,"Auto Dodge Knife","dodge",false)
makeToggle(T.Combat.page,"Kill Aura","kaura",false)
makeSlider(T.Combat.page,"Aura Range","arange",3,20,8)
makeToggle(T.Combat.page,"Spam Activate","spam",false)
makeToggle(T.Combat.page,"Anti Fling","antifling",true)
makeRealBtn(T.Combat.page,"Unlock Mouse",function() UIS.MouseBehavior = Enum.MouseBehavior.Default end)
makeRealBtn(T.Combat.page,"Equip Gun",function() local g = LP.Backpack:FindFirstChild("Gun"); if g then hum():EquipTool(g) end end)
makeRealBtn(T.Combat.page,"Equip Knife",function() local k = LP.Backpack:FindFirstChild("Knife"); if k then hum():EquipTool(k) end end)

-- ==================== PVP ====================
makeToggle(T.Pvp.page,"Fling Nearby","fling_near",false)
makeToggle(T.Pvp.page,"Fling All","fling_all",false)
makeSlider(T.Pvp.page,"Fling Range","fling_r",5,50,15)
makeToggle(T.Pvp.page,"Anti Fling (Strong)","antifling2",true)
makeToggle(T.Pvp.page,"Anti Ragdoll","anorag",false)
makeToggle(T.Pvp.page,"Anti Stun","anstun",false)
makeToggle(T.Pvp.page,"Anti Blind","anblind",false)
makeToggle(T.Pvp.page,"Anti Slow","anslow",false)
makeToggle(T.Pvp.page,"Anti Aim","anaim",false)
makeToggle(T.Pvp.page,"Bhop","bhop",false)
makeToggle(T.Pvp.page,"No Jump Cooldown","njc",false)
makeToggle(T.Pvp.page,"Auto Fire","afire",false)
makeToggle(T.Pvp.page,"Auto Reload","areload",false)
makeToggle(T.Pvp.page,"Auto Respawn","arespawn",false)
makeToggle(T.Pvp.page,"Spawn Protection","spawnp",false)
makeRealBtn(T.Pvp.page,"Bring All",function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and root() then
            p.Character.HumanoidRootPart.CFrame = root().CFrame + Vector3.new(0,3,0)
        end
    end
end)
makeRealBtn(T.Pvp.page,"Freeze All",function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.zero; bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
            bv.Parent = p.Character.HumanoidRootPart
            game:GetService("Debris"):AddItem(bv, 2)
        end
    end
end)
makeRealBtn(T.Pvp.page,"Force Jump All",function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            pcall(function() p.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end
end)

-- ==================== FARM ====================
makeToggle(T.Farm.page,"Auto Farm Coins","cfarm",false)
makeToggle(T.Farm.page,"Coin Magnet","magnet",false)
makeSlider(T.Farm.page,"Farm Radius","cradius",10,500,100)
makeToggle(T.Farm.page,"Auto Collect Drops","drop",false)
makeToggle(T.Farm.page,"Follow Murderer","f_murd",false)
makeToggle(T.Farm.page,"Follow Coin","f_coin",false)
makeToggle(T.Farm.page,"Follow Innocent","f_inno",false)
makeToggle(T.Farm.page,"Anti Idle","aidle",true)
makeToggle(T.Farm.page,"Keep Alive","kalive",true)
makeToggle(T.Farm.page,"Low Graphics","lowg",false)
makeToggle(T.Farm.page,"Anti Lag","alag",false)
makeRealBtn(T.Farm.page,"TP Random",function()
    local l = Players:GetPlayers(); local t = l[math.random(1,#l)]
    if t and t ~= LP and t.Character then tp(t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)) end
end)
makeRealBtn(T.Farm.page,"TP Murderer",function()
    local t = getNearest(isMurderer); if t then tp(t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)) end
end)
makeRealBtn(T.Farm.page,"TP Gun",function()
    for _, g in pairs(WS:GetDescendants()) do
        if g.Name == "Gun" and g:IsA("BasePart") then tp(CFrame.new(g.Position + Vector3.new(0,3,0))); return end
    end
end)
makeRealBtn(T.Farm.page,"TP Coin",function()
    for _, c in pairs(WS:GetDescendants()) do
        if c.Name == "Coin" and c:IsA("BasePart") then tp(CFrame.new(c.Position + Vector3.new(0,3,0))); return end
    end
end)
makeRealBtn(T.Farm.page,"TP Spawn",function() tp(CFrame.new(0,50,0)) end)

-- ==================== SETTING ====================
makeToggle(T.Setting.page,"UI Toggle (RightCtrl)","uikey",true)
makeToggle(T.Setting.page,"Whitelist Friends","wl_f",false)

-- Config system с именами
if writefile and readfile and isfile and makefolder and listfiles then
    pcall(function() if not isfolder("godlike") then makefolder("godlike") end end)

    local cfgBox = n("TextBox",{
        Parent=T.Setting.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,36), Font=Enum.Font.GothamBold, Text="",
        PlaceholderText="имя конфига (мх)", TextColor3=COL.tabText,
        PlaceholderColor3=Color3.fromRGB(140,140,140), TextSize=14,
        ClearTextOnFocus=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=cfgBox})
    n("UIPadding",{Parent=cfgBox,PaddingLeft=UDim.new(0,12)})

    local function cfgPath()
        local nm = cfgBox.Text ~= "" and cfgBox.Text or "default"
        nm = nm:gsub("[^%w_%-]","_")
        return "godlike/"..nm..".json"
    end

    makeRealBtn(T.Setting.page,"Save Config (by name)",function()
        local p = cfgPath()
        local o = {}
        for k,v in pairs(registry) do pcall(function() o[k]=v.get() end) end
        local ok = pcall(function() writefile(p, HS:JSONEncode(o)) end)
        print(ok and ("[Godlike] saved → "..p) or "[Godlike] save failed")
    end)
    makeRealBtn(T.Setting.page,"Load Config (by name)",function()
        local p = cfgPath()
        if not isfile(p) then print("[Godlike] no file: "..p); return end
        local ok, d = pcall(function() return HS:JSONDecode(readfile(p)) end)
        if not ok then print("[Godlike] bad json"); return end
        for k,v in pairs(d) do if registry[k] then pcall(function() registry[k].set(v) end) end end
        print("[Godlike] loaded "..p)
    end)
    makeRealBtn(T.Setting.page,"List Configs",function()
        local files = listfiles("godlike")
        local txt = ""
        for _, f in pairs(files) do
            if f:sub(-5) == ".json" then txt = txt .. f:match("[^/\\]+$") .. "\n" end
        end
        if setclipboard then setclipboard(txt) end
        print("[Godlike] configs:\n"..txt)
    end)
    makeRealBtn(T.Setting.page,"Delete Config",function()
        local p = cfgPath()
        if delfile and isfile(p) then delfile(p); print("[Godlike] deleted "..p) end
    end)
else
    makeRealBtn(T.Setting.page,"Configs: NO FILE API",function() warn("[Godlike] executor has no filesystem") end)
end

makeRealBtn(T.Setting.page,"Copy JobId",function() if setclipboard then setclipboard(game.JobId) end end)
makeRealBtn(T.Setting.page,"Show Player Count",function() print("[Godlike] "..#Players:GetPlayers().."/"..Players.MaxPlayers) end)
makeRealBtn(T.Setting.page,"Dump Remotes",function()
    local txt = ""
    for _, o in pairs(RS:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then txt = txt..o:GetFullName().."\n" end
    end
    if setclipboard then setclipboard(txt) end
end)
makeRealBtn(T.Setting.page,"Panic (All Off)",function()
    for k,v in pairs(registry) do if k~="uikey" then v.set(false) end end
    print("[Godlike] PANIC")
end)
makeRealBtn(T.Setting.page,"Unload Script",function() GUI:Destroy() end)

-- ==================== CUBE MINIMIZE ====================
local CUBE = 54
local minimized = false
local savedPos, savedSize = Main.Position, Main.Size

local CubeFrame = n("TextButton",{
    Parent=GUI, BackgroundColor3=COL.bg, BackgroundTransparency=0.15, BorderSizePixel=0,
    Size=UDim2.new(0,CUBE,0,CUBE), Position=UDim2.new(0,20,0,20),
    Text="G", Font=Enum.Font.GothamBold, TextColor3=COL.titleText, TextSize=26,
    AutoButtonColor=false, Visible=false, ZIndex=50,
})
n("UICorner",{CornerRadius=UDim.new(0,12),Parent=CubeFrame})
n("UIStroke",{Color=Color3.fromRGB(60,110,220),Thickness=2,Parent=CubeFrame})

local cubeDrag, cubeStart, cubePos
CubeFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        cubeDrag = true; cubeStart = i.Position; cubePos = CubeFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if cubeDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - cubeStart
        CubeFrame.Position = UDim2.new(cubePos.X.Scale, cubePos.X.Offset + d.X, cubePos.Y.Scale, cubePos.Y.Offset + d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then cubeDrag = false end
end)

local function toCube()
    savedPos, savedSize = Main.Position, Main.Size
    minimized = true
    CubeFrame.Position = Main.Position
    CubeFrame.Visible = true
    Main.Visible = false
end
local function fromCube()
    minimized = false
    Main.Position = savedPos
    Main.Size = savedSize
    Main.Visible = true
    CubeFrame.Visible = false
end
minBtn.Activated:Connect(toCube)
local cubeMoved = false
CubeFrame.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        cubeMoved = false
        task.delay(0.15, function() cubeMoved = true end)
    end
end)
CubeFrame.Activated:Connect(function() if not cubeMoved then fromCube() end end)
closeBtn.Activated:Connect(function() GUI:Destroy() end)

-- ==================== LOOPS ====================
-- ESP через Highlight
task.spawn(function()
    while task.wait(0.4) do
        if not (registry.esp.get() or registry.mesp.get() or registry.sesp.get() or registry.iesp.get() or registry.rainbow.get()) then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not p.Character then continue end
            local role = getRole(p)
            local show, color
            if registry.rainbow.get() then show=true; color=Color3.fromHSV(tick()%1,0.8,1)
            elseif role=="MURDERER" and registry.mesp.get() then show,color=true,COL.bad
            elseif role=="SHERIFF" and registry.sesp.get() then show,color=true,Color3.fromRGB(60,120,255)
            elseif role=="INNOCENT" and registry.iesp.get() then show,color=true,COL.good
            elseif registry.esp.get() then show,color=true,Color3.fromRGB(180,180,180) end
            local hl = p.Character:FindFirstChild("G_ESP")
            if show then
                if not hl then
                    hl = Instance.new("Highlight"); hl.Name="G_ESP"; hl.Adornee=p.Character
                    hl.OutlineColor=Color3.new(1,1,1); hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent=p.Character
                end
                hl.FillColor = color
            elseif hl then hl:Destroy() end
        end
    end
end)

-- Nametags
task.spawn(function()
    while task.wait(0.3) do
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not p.Character then
                if p.Character then local t = p.Character:FindFirstChild("G_Tags"); if t then t:Destroy() end end
                continue
            end
            local want = registry.nt.get() or registry.dt.get() or registry.hp_bar.get() or registry.role_i.get() or registry.wtag.get() or registry.hubt.get()
            local bg = p.Character:FindFirstChild("G_Tags")
            if not want then if bg then bg:Destroy() end continue end
            if not bg then
                bg = Instance.new("BillboardGui")
                bg.Name="G_Tags"; bg.Size=UDim2.new(0,200,0,60)
                bg.StudsOffset=Vector3.new(0,4,0); bg.AlwaysOnTop=true
                bg.Parent=p.Character
            end
            local role = getRole(p)
            local roleCol = role=="MURDERER" and COL.bad or (role=="SHERIFF" and Color3.fromRGB(60,120,255) or COL.good)
            local dist = root() and math.floor((root().Position - p.Character.HumanoidRootPart.Position).Magnitude) or 0
            local txt = ""
            if registry.nt.get() then txt = p.Name end
            if registry.role_i.get() then txt = txt.." ["..role:sub(1,1).."]" end
            if registry.dt.get() then txt = txt.." "..dist.."m" end
            if registry.wtag.get() then
                local tool = p.Character:FindFirstChildOfClass("Tool")
                if tool then txt = txt.." | "..tool.Name end
            end
            if registry.hubt.get() then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                if h and h.WalkSpeed > 25 then txt = txt.." ⚡" end
            end
            local lbl = bg:FindFirstChildOfClass("TextLabel")
            if not lbl then
                lbl = Instance.new("TextLabel")
                lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0.5,0)
                lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14; lbl.TextStrokeTransparency=0.3
                lbl.Parent=bg
            end
            lbl.Text = txt; lbl.TextColor3 = roleCol
            if registry.hp_bar.get() then
                local h = p.Character:FindFirstChildOfClass("Humanoid")
                local bar = bg:FindFirstChild("G_HP")
                if not bar then
                    bar = Instance.new("Frame"); bar.Name="G_HP"
                    bar.BackgroundColor3=Color3.fromRGB(40,40,40); bar.BorderSizePixel=0
                    bar.Position=UDim2.new(0.2,0,0.55,0); bar.Size=UDim2.new(0.6,0,0.15,0)
                    bar.Parent=bg
                    local fill = Instance.new("Frame"); fill.Name="Fill"
                    fill.BackgroundColor3=Color3.fromRGB(80,220,120); fill.BorderSizePixel=0
                    fill.Size=UDim2.new(1,0,1,0); fill.Parent=bar
                end
                if h and bar then
                    local f = bar:FindFirstChild("Fill")
                    if f then f.Size = UDim2.new(h.Health/h.MaxHealth, 0, 1, 0) end
                end
            end
        end
    end
end)

-- Coin farm
task.spawn(function()
    while task.wait(0.3) do
        if registry.cfarm.get() or registry.magnet.get() then
            for _, c in pairs(WS:GetDescendants()) do
                if c.Name == "Coin" and c:IsA("BasePart") and root() then
                    if (root().Position-c.Position).Magnitude < registry.cradius.get() then
                        tp(CFrame.new(c.Position)); task.wait(0.03)
                    end
                end
            end
        end
    end
end)

-- Auto shoot
task.spawn(function()
    while task.wait(math.max(registry.sdelay.get(),30)/1000) do
        if not registry.autoshoot.get() then continue end
        local g = char():FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
        if g then
            local t = getNearest(function(p) return isMurderer(p) and not isWL(p) end)
            if t and root() then
                if char():FindFirstChild("Gun") ~= g then hum():EquipTool(g) end
                root().CFrame = CFrame.new(root().Position, t.Character.HumanoidRootPart.Position)
                task.wait(0.02); g:Activate()
            end
        end
    end
end)

-- Auto stab
task.spawn(function()
    while task.wait(0.4) do
        if registry.autostab.get() then
            local k = char():FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then
                local t = getNearest(function(p) return not isMurderer(p) and not isWL(p) end)
                if t and root() then
                    local d = (root().Position - t.Character.HumanoidRootPart.Position).Magnitude
                    if d < registry.srange.get() then
                        if char():FindFirstChild("Knife") ~= k then hum():EquipTool(k) end
                        root().CFrame = CFrame.new(root().Position, t.Character.HumanoidRootPart.Position)
                        task.wait(0.05); k:Activate()
                    end
                end
            end
        end
    end
end)

-- Kill aura
task.spawn(function()
    while task.wait(0.2) do
        if not registry.kaura.get() then continue end
        local c = LP.Character
        if not c then continue end
        local tool = c:FindFirstChildOfClass("Tool")
        if not tool then
            tool = LP.Backpack:FindFirstChild("Knife")
            if tool then c.Humanoid:EquipTool(tool) end
        end
        local range = registry.arange.get() or 8
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not p.Character or isWL(p) then continue end
            local d = root() and (root().Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d and d < range then
                pcall(function()
                    if root() then root().CFrame = CFrame.new(root().Position, p.Character.HumanoidRootPart.Position) end
                    if tool then tool:Activate() end
                end)
            end
        end
    end
end)

-- Fling
task.spawn(function()
    while task.wait(0.5) do
        if not (registry.fling_all.get() or registry.fling_near.get()) then continue end
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or isWL(p) then continue end
            if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then continue end
            local doFling = false
            if registry.fling_all.get() then doFling = true end
            if registry.fling_near.get() and root() and (root().Position-p.Character.HumanoidRootPart.Position).Magnitude < registry.fling_r.get() then doFling = true end
            if doFling then
                pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(1e5,1e5,1e5)
                    bv.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
                    bv.Parent = p.Character.HumanoidRootPart
                    game:GetService("Debris"):AddItem(bv, 1)
                end)
            end
        end
    end
end)

-- Follow
task.spawn(function()
    while task.wait(0.3) do
        if not root() then continue end
        local tgt
        if registry.f_murd.get() then tgt = getNearest(isMurderer) end
        if registry.f_inno.get() and not tgt then tgt = getNearest(function(p) return not isMurderer(p) end) end
        if registry.f_coin.get() and not tgt then
            for _, c in pairs(WS:GetDescendants()) do
                if c.Name == "Coin" and c:IsA("BasePart") then tp(CFrame.new(c.Position + Vector3.new(0,3,0))); break end
            end
        end
        if tgt and tgt.Character then
            local d = (root().Position - tgt.Character.HumanoidRootPart.Position).Magnitude
            if d > 8 then tp(tgt.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)) end
        end
    end
end)

-- Auto pickup
task.spawn(function()
    while task.wait(0.4) do
        if not (registry.pickup.get() or registry.drop.get()) then continue end
        for _, obj in pairs(WS:GetDescendants()) do
            if obj:IsA("Tool") and obj.Parent ~= LP.Backpack and root() then
                local d = (root().Position - obj:GetPivot().Position).Magnitude
                if d < 30 then pcall(function() obj.Parent = LP.Backpack end) end
            end
        end
    end
end)

-- Auto equip role
task.spawn(function()
    while task.wait(1) do
        if not registry.auto_equip.get() then continue end
        local c = LP.Character; if not c then continue end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h then continue end
        local role = getRole()
        if role == "SHERIFF" then
            local g = LP.Backpack:FindFirstChild("Gun")
            if g and c:FindFirstChildOfClass("Tool") ~= g then h:EquipTool(g) end
        elseif role == "MURDERER" then
            local k = LP.Backpack:FindFirstChild("Knife")
            if k and c:FindFirstChildOfClass("Tool") ~= k then h:EquipTool(k) end
        end
    end
end)

-- Auto respawn
task.spawn(function()
    while task.wait(1) do
        if registry.arespawn.get() then
            if not LP.Character or not LP.Character:FindFirstChildOfClass("Humanoid") then
                task.wait(1)
                pcall(function() LP:LoadCharacter() end)
            end
        end
    end
end)

-- Anti-fling на Heartbeat (быстро)
local lastGoodPos = nil
RunService.Heartbeat:Connect(function()
    local c = LP.Character; if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not h then return end

    if registry.antifling.get() or registry.antifling2.get() then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro")
               or v:IsA("BodyThrust") or v:IsA("BodyForce") or v:IsA("VectorForce")
               or v:IsA("AngularVelocity") or v:IsA("LinearVelocity") then
                if v.Name ~= "G_SAFE" and v.Name ~= "G_Air" then v:Destroy() end
            end
        end
        if hrp.Velocity.Magnitude > 200 then
            hrp.Velocity = Vector3.zero
            hrp.RotVelocity = Vector3.zero
            h.PlatformStand = false
        end
        pcall(function() hrp:SetNetworkOwner(LP) end)
    end

    if registry.antivoid.get() then
        if hrp.Position.Y < -50 or hrp.Position.Magnitude > 100000 then
            if lastGoodPos then hrp.CFrame = lastGoodPos end
            hrp.Velocity = Vector3.zero
        elseif hrp.Position.Y > 0 and hrp.Position.Y < 500 then
            lastGoodPos = hrp.CFrame
        end
    end

    if registry.anorag.get() then
        h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
    if registry.anstun.get() then h.PlatformStand = false end
    if registry.freeze.get() then hrp.Velocity = Vector3.zero end
    if registry.noclip.get() or registry.fly.get() then
        for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
end)

-- Fly
task.spawn(function()
    while task.wait() do
        if registry.fly.get() and root() then
            local spd = 100
            local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir += WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir += WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            root().Velocity = dir.Magnitude > 0 and (dir.Unit * spd) or Vector3.zero
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if registry.ij.get() and hum() then hum():ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- God mode
task.spawn(function()
    while task.wait(0.5) do
        if registry.god.get() and hum() then hum().MaxHealth=math.huge; hum().Health=math.huge end
    end
end)

-- Hide / Ghost
RunService.Heartbeat:Connect(function()
    local c = LP.Character; if not c then return end
    if registry.hide.get() then
        for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier=1 end end
    end
    if registry.ghost.get() then
        for _, p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.Transparency=0.7 end end
    end
end)

-- Lighting
task.spawn(function()
    while task.wait(0.5) do
        local L = game:GetService("Lighting")
        if registry.fb.get() then L.Ambient=Color3.fromRGB(200,200,200); L.OutdoorAmbient=Color3.fromRGB(200,200,200); L.Brightness=2 end
        if registry.nofog.get() then L.FogEnd=9e9 end
        if registry.night.get() then L.Ambient=Color3.fromRGB(80,80,80); L.OutdoorAmbient=Color3.fromRGB(80,80,80) end
        if registry.aflash.get() then
            for _, v in pairs(L:GetChildren()) do if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") then v.Enabled=false end end
        end
        if registry.lowg.get() or registry.alag.get() then
            L.GlobalShadows=false
            for _, v in pairs(L:GetChildren()) do
                if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then v.Enabled=false end
            end
        end
    end
end)

-- Anti AFK
task.spawn(function()
    while task.wait(60) do
        if registry.afk.get() or registry.aidle.get() or registry.kalive.get() then
            local v = Instance.new("VirtualUser")
            v.Parent = LP
            pcall(function() v:Button1Down(Vector2.new(0,0), WS.CurrentCamera.CFrame) end)
            task.wait(0.5)
            v:Destroy()
        end
    end
end)

-- Headless
task.spawn(function()
    while task.wait(1) do
        local c = LP.Character; if not c then continue end
        if registry.headless.get() then
            local h = c:FindFirstChild("Head")
            if h then for _, o in pairs(h:GetChildren()) do if o:IsA("Decal") then o:Destroy() end end end
        end
    end
end)

-- Hitbox
task.spawn(function()
    while task.wait(0.3) do
        if not registry.hitbox.get() then continue end
        local size = registry.hsize.get()
        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or not p.Character then continue end
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.Size = Vector3.new(size, size, size) end
        end
    end
end)

-- Ammo / reload / recoil
task.spawn(function()
    while task.wait(0.3) do
        local c = LP.Character
        if not c then continue end
        local tool = c:FindFirstChildOfClass("Tool")
        if not tool then continue end
        if registry.iammo.get() then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("IntValue") or v:IsA("NumberValue") then
                    if v.Name:lower():find("ammo") or v.Name:lower():find("clip") then v.Value = 999 end
                end
            end
        end
        if registry.freload.get() then
            for _, v in pairs(tool:GetDescendants()) do
                if v:IsA("NumberValue") and v.Name:lower():find("reload") then v.Value = 0 end
            end
        end
        if registry.norecoil.get() then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then hum.CameraOffset = Vector3.new(0,0,0) end
        end
    end
end)

-- Spam
task.spawn(function()
    while task.wait(0.1) do
        if registry.spam.get() then
            local c = LP.Character
            if c then local tool = c:FindFirstChildOfClass("Tool"); if tool then tool:Activate() end end
        end
    end
end)

-- Auto fire / reload
task.spawn(function()
    while task.wait(0.2) do
        if registry.afire.get() or registry.areload.get() then
            local c = LP.Character
            if c then
                local tool = c:FindFirstChildOfClass("Tool")
                if tool then
                    if registry.afire.get() then pcall(function() tool:Activate() end) end
                    if registry.areload.get() then
                        for _, v in pairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") and v.Name:lower():find("reload") then v.Value = 0 end
                        end
                    end
                end
            end
        end
    end
end)

-- Dodge
task.spawn(function()
    while task.wait(0.1) do
        if not registry.dodge.get() then continue end
        local m = getNearest(isMurderer)
        if m and m.Character and root() and m.Character:FindFirstChild("Knife") then
            local d = (root().Position - m.Character.HumanoidRootPart.Position).Magnitude
            if d < 6 then
                local dir = (root().Position - m.Character.HumanoidRootPart.Position).Unit
                root().Velocity = dir * 60
            end
        end
    end
end)

-- Anti aim
task.spawn(function()
    while task.wait(0.3) do
        if registry.anaim.get() then
            local c = LP.Character
            if c then
                local head = c:FindFirstChild("Head")
                if head then head.Size = Vector3.new(0.5,0.5,0.5) end
            end
        end
    end
end)

-- Bhop / no jump cooldown
task.spawn(function()
    while task.wait(0.05) do
        if registry.bhop.get() or registry.njc.get() then
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then
                h:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Spawn protection
task.spawn(function()
    while task.wait(1) do
        if registry.spawnp.get() and LP.Character then
            if not LP.Character:FindFirstChildOfClass("ForceField") then
                local f = Instance.new("ForceField"); f.Parent = LP.Character
            end
        end
    end
end)

-- Anti slow / stun / blind
task.spawn(function()
    while task.wait(0.3) do
        local c = LP.Character; if not c then continue end
        local h = c:FindFirstChildOfClass("Humanoid"); if not h then continue end
        if registry.anslow.get() and h.WalkSpeed < 16 then h.WalkSpeed = 16 end
        if registry.anstun.get() then h.PlatformStand = false end
        if registry.anblind.get() then
            local L = game:GetService("Lighting")
            L.Brightness = math.max(L.Brightness, 2)
        end
    end
end)

-- Watermark
local wm = n("TextLabel",{Parent=GUI,BackgroundTransparency=1,Position=UDim2.new(0,10,0,10),Size=UDim2.new(0,300,0,20),Font=Enum.Font.GothamBold,Text="",TextColor3=COL.titleText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,Visible=false})
task.spawn(function()
    while task.wait(1) do
        wm.Visible = registry.wm.get()
        if wm.Visible then wm.Text = "Godlike | "..LP.Name.." | "..getRole() end
    end
end)

-- Keybind list
local kbList = n("TextLabel",{Parent=GUI,BackgroundTransparency=1,Position=UDim2.new(1,-260,0,10),Size=UDim2.new(0,250,0,100),Font=Enum.Font.Code,Text="",TextColor3=COL.titleText,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,Visible=false})
task.spawn(function()
    while task.wait(0.5) do
        kbList.Visible = registry.kbl.get()
        if kbList.Visible then
            local active = {}
            for k,v in pairs(registry) do if v.get() then table.insert(active, k) end end
            kbList.Text = "ACTIVE: "..#active.."\n"..table.concat(active, " | ")
        end
    end
end)

-- UI toggle
UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if registry.uikey.get() and i.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)
-- language: Lua, file: godlike_status_block.lua, runtime: Roblox Executor, deps: none
-- *watch for: Ping через Stats.Network.ServerStatsItem — есть не во всех играх, fallback 0*
-- *watch for: CoreGui.TextLabel поверх — некоторые executors режут, тогда Parent = GUI*

-- ==================== SECRET STATUS BLOCK ====================
-- вставляется ровно перед финальным print("[Godlike MM2] ...")

do
    -- === загрузка ===
    local loadGui = n("ScreenGui",{Name="G_Load",ResetOnSpawn=false,Parent=CoreGui})
    local loadBg = n("Frame",{Parent=loadGui,BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.35,Size=UDim2.fromScale(1,1),BorderSizePixel=0,ZIndex=999})
    local loadCard = n("Frame",{Parent=loadBg,BackgroundColor3=Color3.fromRGB(15,15,15),BackgroundTransparency=0.05,Size=UDim2.new(0,360,0,110),Position=UDim2.fromScale(0.5,0.5),AnchorPoint=Vector2.new(0.5,0.5),BorderSizePixel=0,ZIndex=1000})
    n("UICorner",{CornerRadius=UDim.new(0,12),Parent=loadCard})
    n("UIStroke",{Color=Color3.fromRGB(60,110,220),Thickness=1,Parent=loadCard})
    n("TextLabel",{Parent=loadCard,BackgroundTransparency=1,Position=UDim2.new(0,0,0,22),Size=UDim2.new(1,0,0,30),Font=Enum.Font.GothamBold,Text="godlike load",TextColor3=Color3.fromRGB(120,160,255),TextSize=26,ZIndex=1001})
    n("TextLabel",{Parent=loadCard,BackgroundTransparency=1,Position=UDim2.new(0,0,0,58),Size=UDim2.new(1,0,0,20),Font=Enum.Font.Gotham,Text="Discord-godlike",TextColor3=Color3.fromRGB(180,180,180),TextSize=13,ZIndex=1001})
    local loadBarBg = n("Frame",{Parent=loadCard,BackgroundColor3=Color3.fromRGB(45,45,45),BorderSizePixel=0,Position=UDim2.new(0,20,0,86),Size=UDim2.new(1,-40,0,6),ZIndex=1001})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=loadBarBg})
    local loadBar = n("Frame",{Parent=loadBarBg,BackgroundColor3=Color3.fromRGB(60,140,220),BorderSizePixel=0,Size=UDim2.new(0,0,1,0),ZIndex=1002})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=loadBar})
    TS:Create(loadBar,TweenInfo.new(1.1,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.new(1,0,1,0)}):Play()
    task.delay(1.35, function() loadGui:Destroy() end)

    -- === значок "юзает хаб" ===
    local badge = n("TextLabel",{
        Parent=GUI, BackgroundTransparency=1,
        Position=UDim2.new(0,10,0,32), Size=UDim2.new(0,300,0,16),
        Font=Enum.Font.GothamBold, Text="● hub active",
        TextColor3=Color3.fromRGB(90,255,120), TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, Visible=false, ZIndex=200,
    })
    task.spawn(function()
        while task.wait(1) do
            badge.Visible = registry.hub_badge and registry.hub_badge.get() or false
            if badge.Visible then
                local t = tick() % 1
                badge.TextTransparency = 0.15 + math.abs(math.sin(t*math.pi)) * 0.5
            end
        end
    end)

    -- === метка на игрока ===
    local hubTags = {}
    local function makeHubTag(target)
        if not target or not target.Character then return end
        local head = target.Character:FindFirstChild("Head")
        if not head then return end
        if hubTags[target] then return end
        local bb = n("BillboardGui",{
            Name="G_HubTag", Size=UDim2.new(0,180,0,32),
            StudsOffset=Vector3.new(0,3.4,0), AlwaysOnTop=true,
            Parent=head, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        })
        local lbl = n("TextLabel",{
            Parent=bb, BackgroundTransparency=1, Size=UDim2.fromScale(1,1),
            Font=Enum.Font.GothamBold, Text="◈ USING HUB ◈",
            TextColor3=Color3.fromRGB(255,80,80),
            TextStrokeColor3=Color3.fromRGB(0,0,0), TextStrokeTransparency=0.2,
            TextSize=13,
        })
        hubTags[target] = {bb=bb, lbl=lbl}
    end
    local function clearHubTag(target)
        if hubTags[target] then
            pcall(function() hubTags[target].bb:Destroy() end)
            hubTags[target] = nil
        end
    end
    task.spawn(function()
        while task.wait(0.6) do
            local on = registry.hub_tag and registry.hub_tag.get() or false
            if not on then
                for t in pairs(hubTags) do clearHubTag(t) end
            else
                makeHubTag(LP)
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local w = p.Character:FindFirstChildOfClass("Humanoid")
                        if w and w.WalkSpeed > 25 then makeHubTag(p) else clearHubTag(p) end
                    end
                end
            end
        end
    end)

    -- === статы: FPS / PING / MEMORY, лево-верх, 3 блока вниз ===
    local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
    local statW, statH, statGap = isMobile and 78 or 96, 22, 4
    local statsHolder = n("Frame",{
        Parent=GUI, BackgroundTransparency=1,
        Position=UDim2.new(0,10,0,52),
        Size=UDim2.new(0, statW, 0, statH*3 + statGap*2),
        ZIndex=200,
    })
    n("UIListLayout",{Parent=statsHolder,Padding=UDim.new(0,statGap),SortOrder=Enum.SortOrder.LayoutOrder})

    local function makeStat(order, col)
        local box = n("Frame",{
            Parent=statsHolder, BackgroundColor3=Color3.fromRGB(0,0,0),
            BackgroundTransparency=0.35, BorderSizePixel=0,
            Size=UDim2.new(1,0,0,statH), LayoutOrder=order, ZIndex=200,
        })
        n("UICorner",{CornerRadius=UDim.new(0,5),Parent=box})
        n("UIStroke",{Color=col,Thickness=1,Transparency=0.4,Parent=box})
        local acc = n("Frame",{Parent=box,BackgroundColor3=col,BorderSizePixel=0,Position=UDim2.new(0,0,0,5),Size=UDim2.new(0,3,0,statH-10),ZIndex=201})
        n("UICorner",{CornerRadius=UDim.new(1,0),Parent=acc})
        local lbl = n("TextLabel",{
            Parent=box, BackgroundTransparency=1,
            Position=UDim2.new(0,9,0,0), Size=UDim2.new(1,-12,1,0),
            Font=Enum.Font.GothamBold, Text="--", TextColor3=col,
            TextSize=isMobile and 10 or 11, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=201,
        })
        return box, lbl
    end

    local fpsBox, fpsLbl = makeStat(1, Color3.fromRGB(120,255,140))
    local pingBox, pingLbl = makeStat(2, Color3.fromRGB(120,180,255))
    local memBox, memLbl = makeStat(3, Color3.fromRGB(255,180,120))

    local fpsFrames, fpsAccum, fpsLast = 0, 0, tick()
    RunService.RenderStepped:Connect(function()
        fpsFrames = fpsFrames + 1
        fpsAccum = fpsAccum + (1/60)
        local now = tick()
        if now - fpsLast >= 1 then
            local fps = math.floor(fpsFrames / (now - fpsLast) + 0.5)
            fpsLbl.Text = string.format("FPS  %d", fps)
            fpsFrames = 0
            fpsLast = now
        end
    end)

    task.spawn(function()
        while task.wait(1) do
            local ping = 0
            pcall(function()
                local stats = game:GetService("Stats")
                local item = stats.Network.ServerStatsItem["Data Ping"]
                if item then ping = math.floor(item:GetValue()) end
            end)
            pingLbl.Text = string.format("PING %dms", ping)
        end
    end)

    task.spawn(function()
        while task.wait(2) do
            local mb = 0
            pcall(function()
                mb = math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb() or 0)
            end)
            memLbl.Text = string.format("MEM  %dMB", mb)
        end
    end)

    -- === тогглы в Setting ===
    makeToggle(T.Setting.page, "Hub Badge (значок)", "hub_badge", true)
    makeToggle(T.Setting.page, "Hub Tag (метка игрока)", "hub_tag", true)
    makeToggle(T.Setting.page, "Stats Overlay (FPS/Ping/Mem)", "stats_ov", true)

    -- stats overlay можно выключить
    task.spawn(function()
        while task.wait(0.4) do
            local on = registry.stats_ov and registry.stats_ov.get() or false
            statsHolder.Visible = on
            badge.Visible = on and (registry.hub_badge and registry.hub_badge.get() or false)
        end
    end)
end
-- ==================== END SECRET STATUS BLOCK ====================
-- language: Lua, file: godlike_settings_plus.lua, runtime: Roblox Executor, deps: none
-- *watch for: сохранение клавиши через setclipboard/JSON — executor должен иметь writefile*
-- *watch for: применение цветов идёт через реестр объектов — собираем всё что надо перекрасить*

-- ==================== SETTINGS+ BLOCK ====================
-- вставляется после основного блока Secret Status Block, до print("[Godlike MM2] ...")
do
    -- === реестр перекрашиваемых элементов ===
    -- сюда попадут: заголовки, кнопки тогглов, слайдеры, табы, топбар, куб
    local skins = {
        titleLabels = {},   -- заголовки/текст
        buttons     = {},   -- фоны кнопок
        accents     = {},   -- индикаторы/ползунки/topbar stroke
        sliders     = {},   -- треки слайдеров
    }
    local function track(list, inst) table.insert(list, inst); return inst end

    -- патчим makeToggle/makeSlider через registry — добавляем хук на создание
    -- проще: собрать текущие элементы обходом GUI
    local function collectSkin()
        skins.titleLabels = {}
        skins.buttons     = {}
        skins.accents     = {}
        skins.sliders     = {}
        for _, d in pairs(GUI:GetDescendants()) do
            if d:IsA("TextLabel") and (d.TextColor3 == COL.titleText or d.TextColor3 == COL.tabText) then
                track(skins.titleLabels, d)
            elseif d:IsA("TextButton") and (d.BackgroundColor3 == COL.btn or d.BackgroundColor3 == COL.tabBg or d.BackgroundColor3 == COL.tabAct) then
                track(skins.buttons, d)
            elseif d:IsA("Frame") then
                if d.BackgroundColor3 == Color3.fromRGB(60,140,220) or d.BackgroundColor3 == COL.good or d.BackgroundColor3 == Color3.fromRGB(120,120,120) then
                    track(skins.accents, d)
                elseif d.BackgroundColor3 == Color3.fromRGB(180,180,180) then
                    track(skins.sliders, d)
                end
            end
        end
    end
    collectSkin()

    -- === палитра ===
    local palettes = {
        default = {
            title = Color3.fromRGB(60,110,220),
            text  = Color3.fromRGB(30,80,200),
            btn   = Color3.fromRGB(235,235,235),
            tabBg = Color3.fromRGB(230,230,230),
            tabAct= Color3.fromRGB(255,255,255),
            accent= Color3.fromRGB(60,140,220),
            good  = Color3.fromRGB(35,140,70),
            bad   = Color3.fromRGB(200,55,55),
        },
        crimson = {
            title = Color3.fromRGB(255,80,90),
            text  = Color3.fromRGB(200,40,50),
            btn   = Color3.fromRGB(240,225,225),
            tabBg = Color3.fromRGB(235,215,215),
            tabAct= Color3.fromRGB(255,245,245),
            accent= Color3.fromRGB(255,70,70),
            good  = Color3.fromRGB(220,60,60),
            bad   = Color3.fromRGB(120,20,20),
        },
        emerald = {
            title = Color3.fromRGB(50,220,120),
            text  = Color3.fromRGB(20,140,70),
            btn   = Color3.fromRGB(225,240,230),
            tabBg = Color3.fromRGB(215,235,220),
            tabAct= Color3.fromRGB(245,255,248),
            accent= Color3.fromRGB(60,200,110),
            good  = Color3.fromRGB(35,160,80),
            bad   = Color3.fromRGB(200,55,55),
        },
        violet = {
            title = Color3.fromRGB(180,120,255),
            text  = Color3.fromRGB(130,70,220),
            btn   = Color3.fromRGB(235,228,245),
            tabBg = Color3.fromRGB(225,218,240),
            tabAct= Color3.fromRGB(250,245,255),
            accent= Color3.fromRGB(170,100,255),
            good  = Color3.fromRGB(130,200,120),
            bad   = Color3.fromRGB(220,80,120),
        },
        mono = {
            title = Color3.fromRGB(200,200,200),
            text  = Color3.fromRGB(150,150,150),
            btn   = Color3.fromRGB(60,60,60),
            tabBg = Color3.fromRGB(40,40,40),
            tabAct= Color3.fromRGB(80,80,80),
            accent= Color3.fromRGB(140,140,140),
            good  = Color3.fromRGB(80,180,80),
            bad   = Color3.fromRGB(200,60,60),
        },
    }

    local function applyPalette(pal)
        for k,v in pairs(pal) do COL[k] = v end
        -- перекраска
        for _, d in pairs(skins.titleLabels) do d.TextColor3 = pal.title end
        for _, d in pairs(skins.buttons) do
            if d.Name == "tabBtn" then
                d.BackgroundColor3 = pal.tabBg
            elseif d.BackgroundColor3 == COL.tabAct then
                d.BackgroundColor3 = pal.tabAct
            else
                d.BackgroundColor3 = pal.btn
            end
        end
        for _, d in pairs(skins.accents) do
            if d.BackgroundColor3 == COL.bad then
                d.BackgroundColor3 = pal.bad
            else
                d.BackgroundColor3 = pal.accent
            end
        end
        for _, d in pairs(skins.sliders) do d.BackgroundColor3 = pal.accent end
        -- Topbar stroke
        local stroke = Main:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color = pal.accent end
        -- CubeFrame stroke
        local cube = GUI:FindFirstChild("G") or CubeFrame
        if CubeFrame then
            local cs = CubeFrame:FindFirstChildOfClass("UIStroke")
            if cs then cs.Color = pal.accent end
            CubeFrame.TextColor3 = pal.title
        end
        print("[Godlike] palette applied")
    end

    -- === сброс к дефолту ===
    local function resetToDefault()
        applyPalette(palettes.default)
        -- клавиша
        if registry.ui_key then registry.ui_key.set(Enum.KeyCode.RightControl) end
        print("[Godlike] reset → default")
    end

    -- === клавиша открытия/закрытия ===
    -- отдельная запись в registry, чтобы конфиг её тоже сохранял
    local openKey = Enum.KeyCode.RightControl
    registry.ui_key = {
        set = function(v)
            if typeof(v) == "EnumItem" then openKey = v
            elseif type(v) == "string" then
                local ok, code = pcall(function() return Enum.KeyCode[v] end)
                if ok then openKey = code end
            end
            if uiKeyLabel then uiKeyLabel.Text = openKey.Name end
        end,
        get = function() return openKey.Name end,
    }

    -- отвяз старого хэндлера? он на InputBegan — заводим свой и старый срабатывать не будет
    -- чтобы старый не дёргал Main.Visible — временно переназначим uikey
    if registry.uikey then registry.uikey.set(false) end

    UIS.InputBegan:Connect(function(i, gp)
        if gp then return end
        if i.KeyCode == openKey then
            Main.Visible = not Main.Visible
        end
    end)

    -- === UI в Setting ===
    local function head(parent, txt)
        local l = n("TextLabel",{
            Parent=parent, BackgroundTransparency=1,
            Size=UDim2.new(1,-12,0,22), Font=Enum.Font.GothamBold,
            Text=txt, TextColor3=COL.titleText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7,
        })
        track(skins.titleLabels, l)
        return l
    end

    head(T.Setting.page, "─ KEYBIND ─")

    local keyBtn = n("TextButton",{
        Parent=T.Setting.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,36), Font=Enum.Font.GothamBold,
        Text="Change Open Key", TextColor3=COL.tabText, TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=keyBtn})
    n("UIPadding",{Parent=keyBtn,PaddingLeft=UDim.new(0,12)})
    track(skins.buttons, keyBtn)

    local uiKeyLabel = n("TextLabel",{
        Parent=keyBtn, BackgroundTransparency=1,
        Position=UDim2.new(1,-140,0,0), Size=UDim2.new(0,130,1,0),
        Font=Enum.Font.GothamBold, Text=openKey.Name,
        TextColor3=COL.titleText, TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Right, ZIndex=7,
    })
    track(skins.titleLabels, uiKeyLabel)

    local waitingKey = false
    keyBtn.Activated:Connect(function()
        waitingKey = true
        uiKeyLabel.Text = "press any..."
        uiKeyLabel.TextColor3 = Color3.fromRGB(255,180,60)
    end)
    UIS.InputBegan:Connect(function(i, gp)
        if not waitingKey then return end
        if gp then return end
        if i.UserInputType == Enum.UserInputType.Keyboard then
            registry.ui_key.set(i.KeyCode)
            waitingKey = false
            uiKeyLabel.TextColor3 = COL.titleText
        end
    end)

    head(T.Setting.page, "─ THEME ─")

    local function themeBtn(parent, label, key)
        local b = n("TextButton",{
            Parent=parent, BackgroundColor3=COL.btn, BorderSizePixel=0,
            Size=UDim2.new(1,-12,0,32), Font=Enum.Font.GothamBold,
            Text=label, TextColor3=COL.tabText, TextSize=13,
            TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=6,
        })
        n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
        n("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
        track(skins.buttons, b)
        b.Activated:Connect(function() applyPalette(palettes[key]) end)
        return b
    end

    themeBtn(T.Setting.page, "Theme: Default (blue)", "default")
    themeBtn(T.Setting.page, "Theme: Crimson", "crimson")
    themeBtn(T.Setting.page, "Theme: Emerald", "emerald")
    themeBtn(T.Setting.page, "Theme: Violet", "violet")
    themeBtn(T.Setting.page, "Theme: Mono (dark)", "mono")

    head(T.Setting.page, "─ RESET ─")

    local resetBtn = n("TextButton",{
        Parent=T.Setting.page, BackgroundColor3=COL.btn, BorderSizePixel=0,
        Size=UDim2.new(1,-12,0,36), Font=Enum.Font.GothamBold,
        Text="↺ Reset to Default", TextColor3=Color3.fromRGB(200,55,55), TextSize=14,
        TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=resetBtn})
    n("UIPadding",{Parent=resetBtn,PaddingLeft=UDim.new(0,12)})
    track(skins.buttons, resetBtn)
    resetBtn.Activated:Connect(resetToDefault)

    -- === экспорт в getgenv ===
    getgenv().GodlikeSkin = {
        apply = applyPalette,
        reset = resetToDefault,
        palettes = palettes,
        skins = skins,
        recollect = collectSkin,
    }

    print("[Godlike] Settings+ loaded — keybind, themes, reset")
end
-- ==================== END SETTINGS+ BLOCK ====================

print("[Godlike MM2] Kiti Cube Edition loaded.")
print("[Godlike MM2] Kiti Cube Edition loaded.")
print("[Godlike MM2] Kiti Cube Edition loaded.")
