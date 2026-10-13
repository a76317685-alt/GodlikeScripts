-- language: Lua, file: lokeii_mm2.lua, runtime: Roblox Executor
-- name: Lokeii MM2 | Full Hub

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
    bg=Color3.fromRGB(0,0,0), bgTrans=0.12, tabBg=Color3.fromRGB(230,230,230),
    tabText=Color3.fromRGB(30,80,200), title=Color3.fromRGB(60,110,220),
    tabAct=Color3.fromRGB(255,255,255), btn=Color3.fromRGB(235,235,235),
    good=Color3.fromRGB(35,140,70), warn=Color3.fromRGB(220,160,40),
    bad=Color3.fromRGB(200,55,55), dim=Color3.fromRGB(120,120,120),
}

for _, g in pairs(CoreGui:GetChildren()) do if g.Name=="LokeiiMM2" then g:Destroy() end end

local registry, whitelist = {}, {}
whitelist[LP.Name:lower()] = true

-- ==================== GUI ====================
local GUI = n("ScreenGui",{Name="LokeiiMM2",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})

local Main = n("Frame",{Parent=GUI,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Position=UDim2.new(0.5,-210,0.5,-290),Size=UDim2.new(0,420,0,580),Active=true,ZIndex=1})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=Main})
n("UIStroke",{Color=Color3.fromRGB(60,60,60),Thickness=1,Parent=Main})

local Top = n("Frame",{Parent=Main,BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=0,Size=UDim2.new(1,0,0,36),ZIndex=10})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=Top})
n("TextLabel",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-80,1,0),Font=Enum.Font.GothamBold,Text="Lokeii MM2",TextColor3=COL.title,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})

local minBtn   = n("TextButton",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(1,-68,0,6),Size=UDim2.new(0,26,0,24),Font=Enum.Font.GothamBold,Text="—",TextColor3=COL.title,TextSize=18,AutoButtonColor=false,ZIndex=11})
local closeBtn = n("TextButton",{Parent=Top,BackgroundTransparency=1,Position=UDim2.new(1,-34,0,6),Size=UDim2.new(0,26,0,24),Font=Enum.Font.GothamBold,Text="×",TextColor3=COL.bad,TextSize=20,AutoButtonColor=false,ZIndex=11})

-- DRAG
local dragging, dragInput, dragStart, startPos
Top.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragInput=input; dragStart=input.Position; startPos=Main.Position
    end
end)
Top.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local d=input.Position-dragStart
        Main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
Top.InputEnded:Connect(function(input) if input==dragInput then dragging=false end end)

-- SIDE
local SideScroll = n("ScrollingFrame",{Parent=Main,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Position=UDim2.new(0,0,0,36),Size=UDim2.new(0,145,1,-36),ScrollBarThickness=3,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ClipsDescendants=true,ZIndex=2})
n("UIListLayout",{Parent=SideScroll,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})
n("UIPadding",{Parent=SideScroll,PaddingTop=UDim.new(0,6),PaddingBottom=UDim.new(0,6),PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)})

-- BODY
local Body = n("Frame",{Parent=Main,BackgroundColor3=COL.bg,BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Position=UDim2.new(0,145,0,36),Size=UDim2.new(1,-145,1,-36),ZIndex=2})
local gradFrame = n("Frame",{Parent=Body,BackgroundColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=COL.bgTrans,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ZIndex=2})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=gradFrame})
n("UIGradient",{Parent=gradFrame,Rotation=90,Color=ColorSequence.new{
    ColorSequenceKeypoint.new(0,Color3.fromRGB(15,15,15)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(90,90,90)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(235,235,235)),
}})

-- TABS
local tabs, activeTab = {}, nil
local function showTab(tab)
    for _,t in pairs(tabs) do t.page.Visible=false; t.btn.BackgroundColor3=COL.tabBg end
    tab.page.Visible=true; tab.btn.BackgroundColor3=COL.tabAct; activeTab=tab
end
local function makeTab(name)
    local btn = n("TextButton",{Parent=SideScroll,BackgroundColor3=COL.tabBg,BorderSizePixel=0,Size=UDim2.new(1,-12,0,42),Font=Enum.Font.GothamBold,Text=name,TextColor3=COL.tabText,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=4})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=btn})
    n("UIPadding",{Parent=btn,PaddingLeft=UDim.new(0,15)})
    local page = n("ScrollingFrame",{Parent=Body,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,1,0),ScrollBarThickness=4,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,ClipsDescendants=true,ZIndex=3})
    n("UIListLayout",{Parent=page,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
    n("UIPadding",{Parent=page,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})
    local tab={name=name,btn=btn,page=page}
    table.insert(tabs,tab); btn.Activated:Connect(function() showTab(tab) end)
    return tab
end

-- HELPERS
local function char() return LP.Character or LP.CharacterAdded:Wait() end
local function hum() return char():FindFirstChildOfClass("Humanoid") end
local function root() return char():FindFirstChild("HumanoidRootPart") end
local function tp(cf) if root() then root().CFrame=cf end end

local function getRole(p)
    local t=p or LP; local c=t.Character
    if not c then return "UNKNOWN" end
    local bp=t:FindFirstChild("Backpack")
    local function hasTool(name)
        if c:FindFirstChild(name) then return true end
        if bp and bp:FindFirstChild(name) then return true end
        return false
    end
    for _,nm in ipairs({"Knife","Dagger","MurdererKnife"}) do if hasTool(nm) then return "MURDERER" end end
    for _,nm in ipairs({"Gun","Revolver","Pistol","SheriffGun"}) do if hasTool(nm) then return "SHERIFF" end end
    for _,obj in pairs(c:GetChildren()) do if obj:IsA("Tool") then return "ARMED" end end
    return "INNOCENT"
end
local function isMurderer(p) return getRole(p)=="MURDERER" end
local function isWL(p) return whitelist[p.Name:lower()] end
local function getNearest(pred)
    local best,bd=nil,math.huge
    if not root() then return nil end
    for _,p in pairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not pred or pred(p) then
                local d=(root().Position-p.Character.HumanoidRootPart.Position).Magnitude
                if d<bd then bd=d; best=p end
            end
        end
    end
    return best,bd
end

-- ELEMENTS
local function makeRealBtn(parent,txt,cb,color)
    local b=n("TextButton",{Parent=parent,BackgroundColor3=color or COL.btn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,34),Font=Enum.Font.GothamBold,Text=txt,TextColor3=Color3.fromRGB(30,80,200),TextSize=13,AutoButtonColor=false,ZIndex=6})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    b.Activated:Connect(cb); return b
end
local function makeToggle(parent,txt,key,default,cb)
    local state=default
    local b=n("TextButton",{Parent=parent,BackgroundColor3=COL.btn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,34),Font=Enum.Font.GothamBold,Text=txt,TextColor3=COL.tabText,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,AutoButtonColor=false,ZIndex=6})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    n("UIPadding",{Parent=b,PaddingLeft=UDim.new(0,12)})
    local ind=n("Frame",{Parent=b,BackgroundColor3=state and COL.good or COL.dim,BorderSizePixel=0,Position=UDim2.new(1,-28,0,9),Size=UDim2.new(0,16,0,16),ZIndex=7})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=ind})
    local function apply(v) state=v; ind.BackgroundColor3=v and COL.good or COL.dim; if cb then cb(v) end end
    b.Activated:Connect(function() apply(not state) end)
    registry[key]={set=apply,get=function() return state end}
    return b
end
local function makeSlider(parent,txt,key,min,max,default,cb)
    local b=n("Frame",{Parent=parent,BackgroundColor3=COL.btn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,48),ZIndex=6})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    n("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,12,0,4),Size=UDim2.new(1,-80,0,20),Font=Enum.Font.GothamBold,Text=txt,TextColor3=COL.tabText,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
    local valLbl=n("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(1,-60,0,4),Size=UDim2.new(0,50,0,20),Font=Enum.Font.GothamBold,Text=tostring(default),TextColor3=COL.tabText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=7})
    local tr=n("Frame",{Parent=b,BackgroundColor3=Color3.fromRGB(180,180,180),BorderSizePixel=0,Position=UDim2.new(0,12,0,30),Size=UDim2.new(1,-24,0,6),ZIndex=7})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=tr})
    local fl=n("Frame",{Parent=tr,BackgroundColor3=Color3.fromRGB(60,140,220),BorderSizePixel=0,Size=UDim2.new((default-min)/(max-min),0,1,0),ZIndex=8})
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=fl})
    local cur=default
    local function apply(v) cur=v; fl.Size=UDim2.new((v-min)/(max-min),0,1,0); valLbl.Text=tostring(v); if cb then cb(v) end end
    local drag=false
    local function upd(i) local r=math.clamp((i.Position.X-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1); apply(math.floor(min+(max-min)*r+0.5)) end
    tr.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i) end end)
    UIS.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
    registry[key]={set=apply,get=function() return cur end}
end
local function makeTextbox(parent,txt,key,default,cb)
    local b=n("Frame",{Parent=parent,BackgroundColor3=COL.btn,BorderSizePixel=0,Size=UDim2.new(1,-8,0,34),ZIndex=6})
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=b})
    n("TextLabel",{Parent=b,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(0,100,1,0),Font=Enum.Font.GothamBold,Text=txt,TextColor3=COL.tabText,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7})
    local t=n("TextBox",{Parent=b,BackgroundColor3=Color3.fromRGB(255,255,255),BorderSizePixel=0,Position=UDim2.new(0,110,0,5),Size=UDim2.new(1,-118,0,24),Font=Enum.Font.Code,Text=default,TextColor3=COL.tabText,TextSize=12,ClearTextOnFocus=false,PlaceholderText="...",ZIndex=7})
    t.FocusLost:Connect(function() if cb then cb(t.Text) end end)
    registry[key]={set=function(v) t.Text=v end,get=function() return t.Text end}
end

-- TABS INIT
local T={}
T.Combat=makeTab("combat")
T.Visual=makeTab("visual")
T.Trade =makeTab("trade")
T.Map   =makeTab("map")
T.Misc  =makeTab("misc")
T.Settings=makeTab("settings")
showTab(T.Combat)

-- ==================== COMBAT ====================
makeToggle(T.Combat.page,"Auto Shoot Murderer","autoshoot",false)
makeToggle(T.Combat.page,"Auto Stab","autostab",false)
makeSlider(T.Combat.page,"Stab Range","srange",3,15,8)
makeToggle(T.Combat.page,"Kill Aura","kaura",false)
makeSlider(T.Combat.page,"Aura Range","arange",3,20,8)
makeToggle(T.Combat.page,"Fling All","fling_all",false)
makeToggle(T.Combat.page,"Fling Nearby","fling_near",false)
makeSlider(T.Combat.page,"Fling Range","fling_r",5,50,15)
makeToggle(T.Combat.page,"Anti Fling","antifling",true)
makeToggle(T.Combat.page,"Spam Activate","spam",false)
makeSlider(T.Combat.page,"Shot Delay (ms)","sdelay",30,500,100)
makeRealBtn(T.Combat.page,"Equip Gun",function() local g=LP.Backpack:FindFirstChild("Gun"); if g then hum():EquipTool(g) end end)
makeRealBtn(T.Combat.page,"Equip Knife",function() local k=LP.Backpack:FindFirstChild("Knife"); if k then hum():EquipTool(k) end end)

-- ==================== VISUAL ====================
makeToggle(T.Visual.page,"Player ESP","esp",false)
makeToggle(T.Visual.page,"Murderer ESP","mesp",true)
makeToggle(T.Visual.page,"Sheriff ESP","sesp",true)
makeToggle(T.Visual.page,"Innocent ESP","iesp",false)
makeToggle(T.Visual.page,"Rainbow ESP","rainbow",false)
makeToggle(T.Visual.page,"Name Tags","nt",true)
makeToggle(T.Visual.page,"Distance Tags","dt",true)
makeToggle(T.Visual.page,"Health Bars","hp_bar",true)
makeToggle(T.Visual.page,"Role Icons","role_i",true)
makeToggle(T.Visual.page,"Weapon Tags","wtag",false)
makeToggle(T.Visual.page,"Fullbright","fb",false)
makeToggle(T.Visual.page,"No Fog","nofog",false)
makeToggle(T.Visual.page,"Anti Flash","aflash",false)
makeToggle(T.Visual.page,"Skin Changer","skin",false)
makeTextbox(T.Visual.page,"Skin ID","skin_id","",function(txt) end)
makeRealBtn(T.Visual.page,"Apply Skin",function()
    local id = tonumber(registry.skin_id.get())
    if not id then return end
    local c = LP.Character; if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then
        for _, d in pairs(tool:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                pcall(function() d.Texture = "rbxassetid://"..id end)
            end
        end
    end
    print("[Skin] applied to tool")
end)

-- ==================== TRADE ====================
makeToggle(T.Trade.page,"Freeze Trade","freeze_trade",false)
makeToggle(T.Trade.page,"Auto Accept (Green)","auto_accept",false)
makeTextbox(T.Trade.page,"My Value","my_val","0",function(txt) end)
makeTextbox(T.Trade.page,"Their Value","their_val","0",function(txt) end)

local tradeVerdict = n("TextLabel",{Parent=T.Trade.page,BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Size=UDim2.new(1,-8,0,40),Font=Enum.Font.GothamBold,Text="Введи цены и нажми Calculate",TextColor3=COL.dim,TextSize=13})
n("UICorner",{CornerRadius=UDim.new(0,6),Parent=tradeVerdict})

makeRealBtn(T.Trade.page,"Calculate",function()
    local mv = tonumber(registry.my_val.get()) or 0
    local tv = tonumber(registry.their_val.get()) or 0
    local diff = tv - mv
    local pct = mv > 0 and (diff/mv*100) or 0
    if diff > 0 then
        tradeVerdict.Text = string.format("ОКУПАЕТСЯ: +%d (+%.0f%%)", diff, pct)
        tradeVerdict.TextColor3 = COL.good
    elseif diff < 0 then
        tradeVerdict.Text = string.format("В МИНУС: %d (%.0f%%)", diff, pct)
        tradeVerdict.TextColor3 = COL.bad
    else
        tradeVerdict.Text = "РОВНО: 0"
        tradeVerdict.TextColor3 = COL.warn
    end
end)

-- Freeze trade — заглушка, отключает кнопки Accept визуально
task.spawn(function()
    while task.wait(0.3) do
        if registry.freeze_trade.get() then
            for _, g in pairs(LP.PlayerGui:GetDescendants()) do
                if g:IsA("TextButton") and (g.Name:lower():find("accept") or g.Text:lower():find("accept")) then
                    g.Active = false
                    g.BackgroundColor3 = Color3.fromRGB(120,120,120)
                end
            end
        end
    end
end)

-- ==================== MAP (ДЮП) ====================
local votePads = {}
local selectedPad = nil
local running = false
local cycleCount = 0
local delay = 0.3

local infoLbl = n("TextLabel",{Parent=T.Map.page,BackgroundColor3=Color3.fromRGB(30,30,30),BorderSizePixel=0,Size=UDim2.new(1,-8,0,26),Font=Enum.Font.GothamBold,Text="Pads: 0 | Selected: none",TextColor3=Color3.fromRGB(180,180,180),TextSize=11})
n("UICorner",{CornerRadius=UDim.new(0,6),Parent=infoLbl})

local statusLbl = n("TextLabel",{Parent=T.Map.page,BackgroundColor3=Color3.fromRGB(20,20,20),BorderSizePixel=0,Size=UDim2.new(1,-8,0,26),Font=Enum.Font.GothamBold,Text="Status: IDLE | Cycles: 0",TextColor3=COL.bad,TextSize=12})
n("UICorner",{CornerRadius=UDim.new(0,6),Parent=statusLbl})

local padListHolder = n("Frame",{Parent=T.Map.page,BackgroundTransparency=1,Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y})
n("UIListLayout",{Parent=padListHolder,Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder})

local function clearPads()
    for _,e in pairs(votePads) do if e.highlight then e.highlight:Destroy() end end
    votePads = {}
    for _,c in pairs(padListHolder:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
end

local function detectPads()
    clearPads()
    local palette = {
        Color3.fromRGB(60,140,220), Color3.fromRGB(35,200,90),
        Color3.fromRGB(220,180,40), Color3.fromRGB(220,80,80),
        Color3.fromRGB(180,80,220), Color3.fromRGB(80,220,220),
    }
    local containers = {}
    for _,obj in pairs(WS:GetDescendants()) do
        if obj.Name=="VotePads" or (obj:IsA("Folder") and obj.Name:lower():find("vote")) then
            table.insert(containers, obj)
        end
    end
    if #containers > 0 then
        for _,container in ipairs(containers) do
            for _,pad in pairs(container:GetChildren()) do
                if pad:IsA("BasePart") then votePads[pad.Name]={part=pad} end
            end
        end
    end
    if #votePads == 0 then
        local lobby=WS:FindFirstChild("RegularLobby")
        if lobby then
            local pads=lobby:FindFirstChild("VotePads")
            if pads then
                for _,pad in pairs(pads:GetChildren()) do
                    if pad:IsA("BasePart") then votePads[pad.Name]={part=pad} end
                end
            end
        end
    end
    local i=0
    for name,entry in pairs(votePads) do
        i+=1
        local color=palette[((i-1)%#palette)+1]
        entry.color=color
        entry.highlight=n("Highlight",{Name="VotePadHL",Adornee=entry.part,FillColor=color,FillTransparency=0.5,OutlineColor=color,OutlineTransparency=0,DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Parent=entry.part})
        local btn=n("TextButton",{Parent=padListHolder,BackgroundColor3=color,BorderSizePixel=0,Size=UDim2.new(1,0,0,32),Font=Enum.Font.GothamBold,Text=name,TextColor3=Color3.fromRGB(255,255,255),TextSize=13,AutoButtonColor=false})
        n("UICorner",{CornerRadius=UDim.new(0,6),Parent=btn})
        n("UIPadding",{Parent=btn,PaddingLeft=UDim.new(0,12)})
        btn.Activated:Connect(function()
            selectedPad=name
            infoLbl.Text="Pads: "..#votePads.." | Selected: "..name
        end)
    end
    infoLbl.Text="Pads: "..i.." | Selected: "..(selectedPad or "none")
end

makeRealBtn(T.Map.page,"Detect Vote Pads",function() detectPads() end)
makeRealBtn(T.Map.page,"Test Reset",function() local h=hum(); if h then pcall(function() h.Health=0 end) end end)
makeRealBtn(T.Map.page,"Test Teleport",function()
    if not selectedPad then return end
    local e=votePads[selectedPad]
    if e and e.part and root() then root().CFrame=CFrame.new(e.part.Position+Vector3.new(0,3,0)) end
end)

makeRealBtn(T.Map.page,"START (green)",function()
    if running then return end
    if not selectedPad then warn("select pad"); return end
    running=true
    statusLbl.Text="Status: RUNNING | Cycles: 0"
    statusLbl.TextColor3=COL.good
    task.spawn(function()
        while running do
            cycleCount+=1
            local h=hum(); if h then pcall(function() h.Health=0 end) end
            local waited=0
            while (not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") or LP.Character:FindFirstChildOfClass("Humanoid").Health<=0) and waited<5 do task.wait(0.1); waited+=0.1 end
            task.wait(delay)
            local e=votePads[selectedPad]
            if e and e.part and root() then root().CFrame=CFrame.new(e.part.Position+Vector3.new(0,3,0)) end
            task.wait(0.5)
            task.wait(delay)
            statusLbl.Text="Status: RUNNING | Cycles: "..cycleCount
        end
    end)
end, COL.good)

makeRealBtn(T.Map.page,"STOP",function()
    running=false
    statusLbl.Text="Status: STOPPED | Cycles: "..cycleCount
    statusLbl.TextColor3=COL.bad
end, COL.bad)

-- ==================== MISC ====================
makeSlider(T.Misc.page,"WalkSpeed","ws",16,300,16,function(v) if hum() then hum().WalkSpeed=v end end)
makeSlider(T.Misc.page,"JumpPower","jp",50,500,50,function(v) if hum() then hum().JumpPower=v end end)
makeToggle(T.Misc.page,"Fly","fly",false)
makeToggle(T.Misc.page,"Noclip","noclip",false)
makeToggle(T.Misc.page,"Infinite Jump","ij",false)
makeToggle(T.Misc.page,"God Mode","god",false)
makeToggle(T.Misc.page,"Anti Void","antivoid",true)
makeToggle(T.Misc.page,"Anti AFK","afk",true)
makeToggle(T.Misc.page,"FPS Boost","fpsb",false)

-- ==================== SETTINGS ====================
makeTextbox(T.Settings.page,"Config Name","cfg_name","default",function(txt) end)
makeRealBtn(T.Settings.page,"Save Config",function()
    if not writefile then return end
    pcall(function() if not isfolder("lokeii") then makefolder("lokeii") end end)
    local name=(registry.cfg_name.get() or "default"):gsub("[^%w_%-]","_")
    local o={}
    for k,v in pairs(registry) do if k~="cfg_name" then pcall(function() o[k]=v.get() end) end end
    pcall(function() writefile("lokeii/"..name..".json", HS:JSONEncode(o)) end)
    print("[Lokeii] saved → lokeii/"..name..".json")
end)
makeRealBtn(T.Settings.page,"Load Config",function()
    if not (isfile and readfile) then return end
    local name=(registry.cfg_name.get() or "default"):gsub("[^%w_%-]","_")
    local path="lokeii/"..name..".json"
    if not isfile(path) then print("[Lokeii] not found: "..path); return end
    local ok,d=pcall(function() return HS:JSONDecode(readfile(path)) end)
    if ok then for k,v in pairs(d) do if registry[k] and k~="cfg_name" then pcall(function() registry[k].set(v) end) end end; print("[Lokeii] loaded") end
end)
makeRealBtn(T.Settings.page,"Panic (All Off)",function()
    for k,v in pairs(registry) do if k~="cfg_name" then pcall(function() v.set(false) end) end end
    print("[Lokeii] PANIC")
end)
makeRealBtn(T.Settings.page,"Unload",function() GUI:Destroy() end)

-- ==================== LOOPS ====================
task.spawn(function()
    while task.wait(math.max(registry.sdelay.get(),30)/1000) do
        if not registry.autoshoot.get() then continue end
        local g=char():FindFirstChild("Gun") or LP.Backpack:FindFirstChild("Gun")
        if g then
            local t=getNearest(function(p) return isMurderer(p) and not isWL(p) end)
            if t and root() then
                if char():FindFirstChild("Gun")~=g then hum():EquipTool(g) end
                root().CFrame=CFrame.new(root().Position, t.Character.HumanoidRootPart.Position)
                task.wait(0.02); g:Activate()
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.4) do
        if registry.autostab.get() then
            local k=char():FindFirstChild("Knife") or LP.Backpack:FindFirstChild("Knife")
            if k then
                local t=getNearest(function(p) return not isMurderer(p) and not isWL(p) end)
                if t and root() then
                    local d=(root().Position-t.Character.HumanoidRootPart.Position).Magnitude
                    if d<registry.srange.get() then
                        if char():FindFirstChild("Knife")~=k then hum():EquipTool(k) end
                        root().CFrame=CFrame.new(root().Position, t.Character.HumanoidRootPart.Position)
                        task.wait(0.05); k:Activate()
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if not registry.kaura.get() then continue end
        local c=LP.Character; if not c then continue end
        local tool=c:FindFirstChildOfClass("Tool") or LP.Backpack:FindFirstChild("Knife")
        if tool and tool.Parent~=c then hum():EquipTool(tool) end
        local range=registry.arange.get() or 8
        for _,p in pairs(Players:GetPlayers()) do
            if p==LP or not p.Character or isWL(p) then continue end
            local d=root() and (root().Position-p.Character.HumanoidRootPart.Position).Magnitude
            if d and d<range then
                pcall(function()
                    if root() then root().CFrame=CFrame.new(root().Position, p.Character.HumanoidRootPart.Position) end
                    if tool then tool:Activate() end
                end)
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not (registry.fling_all.get() or registry.fling_near.get()) then continue end
        for _,p in pairs(Players:GetPlayers()) do
            if p==LP or isWL(p) or not p.Character then continue end
            local hrp=p.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local doFling=false
            if registry.fling_all.get() then doFling=true end
            if registry.fling_near.get() and root() and (root().Position-hrp.Position).Magnitude<registry.fling_r.get() then doFling=true end
            if doFling then
                pcall(function()
                    local bv=Instance.new("BodyVelocity")
                    bv.Velocity=Vector3.new(1e5,1e5,1e5)
                    bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
                    bv.Parent=hrp
                    game:GetService("Debris"):AddItem(bv,1)
                end)
            end
        end
    end
end)

-- Anti-fling + God + AntiVoid + Fly + Noclip
local lastGoodPos = nil
RunService.Heartbeat:Connect(function()
    local c=LP.Character; if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart")
    local h=c:FindFirstChildOfClass("Humanoid")
    if not hrp or not h then return end
    if registry.antifling.get() then
        for _,v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro")
            or v:IsA("BodyThrust") or v:IsA("BodyForce") or v:IsA("VectorForce")
            or v:IsA("AngularVelocity") or v:IsA("LinearVelocity") then
                if v.Name~="G_SAFE" and v.Name~="G_Air" then v:Destroy() end
            end
        end
        if hrp.Velocity.Magnitude>200 then
            hrp.Velocity=Vector3.zero; hrp.RotVelocity=Vector3.zero; h.PlatformStand=false
        end
        pcall(function() hrp:SetNetworkOwner(LP) end)
    end
    if registry.antivoid.get() then
        if hrp.Position.Y<-50 or hrp.Position.Magnitude>100000 then
            if lastGoodPos then hrp.CFrame=lastGoodPos end
            hrp.Velocity=Vector3.zero
        elseif hrp.Position.Y>0 and hrp.Position.Y<500 then
            lastGoodPos=hrp.CFrame
        end
    end
    if registry.noclip.get() or registry.fly.get() then
        for _,p in pairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end
    end
end)

task.spawn(function()
    while task.wait() do
        if registry.fly.get() and root() then
            local spd=100; local dir=Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir+=WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir-=WS.CurrentCamera.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir-=WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir+=WS.CurrentCamera.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir+=Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir-=Vector3.new(0,1,0) end
            root().Velocity=dir.Magnitude>0 and (dir.Unit*spd) or Vector3.zero
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if registry.ij.get() and hum() then hum():ChangeState(Enum.HumanoidStateType.Jumping) end
end)

task.spawn(function()
    while task.wait(0.5) do
        if registry.god.get() and hum() then hum().MaxHealth=math.huge; hum().Health=math.huge end
    end
end)

-- ESP + nametags
task.spawn(function()
    while task.wait(0.4) do
        if not (registry.esp.get() or registry.mesp.get() or registry.sesp.get() or registry.iesp.get() or registry.rainbow.get()) then continue end
        for _,p in pairs(Players:GetPlayers()) do
            if p==LP or not p.Character then continue end
            local role=getRole(p)
            local show,color
            if registry.rainbow.get() then show=true; color=Color3.fromHSV(tick()%1,0.8,1)
            elseif role=="MURDERER" and registry.mesp.get() then show,color=true,COL.bad
            elseif role=="SHERIFF" and registry.sesp.get() then show,color=true,Color3.fromRGB(60,120,255)
            elseif role=="INNOCENT" and registry.iesp.get() then show,color=true,COL.good
            elseif registry.esp.get() then show,color=true,Color3.fromRGB(180,180,180) end
            local hl=p.Character:FindFirstChild("G_ESP")
            if show then
                if not hl then
                    hl=Instance.new("Highlight"); hl.Name="G_ESP"; hl.Adornee=p.Character
                    hl.OutlineColor=Color3.new(1,1,1); hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent=p.Character
                end
                hl.FillColor=color
            elseif hl then hl:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(0.3) do
        for _,p in pairs(Players:GetPlayers()) do
            if p==LP or not p.Character then
                if p.Character then local t=p.Character:FindFirstChild("G_Tags"); if t then t:Destroy() end end
                continue
            end
            local want=registry.nt.get() or registry.dt.get() or registry.hp_bar.get() or registry.role_i.get() or registry.wtag.get()
            local bg=p.Character:FindFirstChild("G_Tags")
            if not want then if bg then bg:Destroy() end continue end
            if not bg then
                bg=Instance.new("BillboardGui"); bg.Name="G_Tags"; bg.Size=UDim2.new(0,200,0,60)
                bg.StudsOffset=Vector3.new(0,4,0); bg.AlwaysOnTop=true; bg.Parent=p.Character
            end
            local role=getRole(p)
            local roleCol=role=="MURDERER" and COL.bad or (role=="SHERIFF" and Color3.fromRGB(60,120,255) or COL.good)
            local dist=root() and math.floor((root().Position-p.Character.HumanoidRootPart.Position).Magnitude) or 0
            local txt=""
            if registry.nt.get() then txt=p.Name end
            if registry.role_i.get() then txt=txt.." ["..role:sub(1,1).."]" end
            if registry.dt.get() then txt=txt.." "..dist.."m" end
            if registry.wtag.get() then
                local tool=p.Character:FindFirstChildOfClass("Tool")
                if tool then txt=txt.." | "..tool.Name end
            end
            local lbl=bg:FindFirstChildOfClass("TextLabel")
            if not lbl then
                lbl=Instance.new("TextLabel"); lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,0,0.5,0)
                lbl.Font=Enum.Font.GothamBold; lbl.TextSize=14; lbl.TextStrokeTransparency=0.3; lbl.Parent=bg
            end
            lbl.Text=txt; lbl.TextColor3=roleCol
            if registry.hp_bar.get() then
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                local bar=bg:FindFirstChild("G_HP")
                if not bar then
                    bar=Instance.new("Frame"); bar.Name="G_HP"; bar.BackgroundColor3=Color3.fromRGB(40,40,40)
                    bar.BorderSizePixel=0; bar.Position=UDim2.new(0.2,0,0.55,0); bar.Size=UDim2.new(0.6,0,0.15,0); bar.Parent=bg
                    local fill=Instance.new("Frame"); fill.Name="Fill"; fill.BackgroundColor3=Color3.fromRGB(80,220,120); fill.BorderSizePixel=0; fill.Size=UDim2.new(1,0,1,0); fill.Parent=bar
                end
                if h and bar then local f=bar:FindFirstChild("Fill"); if f then f.Size=UDim2.new(h.Health/h.MaxHealth,0,1,0) end end
            end
        end
    end
end)

-- Lighting
task.spawn(function()
    while task.wait(0.5) do
        local L=game:GetService("Lighting")
        if registry.fb.get() then L.Ambient=Color3.fromRGB(200,200,200); L.OutdoorAmbient=Color3.fromRGB(200,200,200); L.Brightness=2 end
        if registry.nofog.get() then L.FogEnd=9e9 end
        if registry.aflash.get() then for _,v in pairs(L:GetChildren()) do if v:IsA("BlurEffect") then v.Enabled=false end end end
        if registry.fpsb.get() then L.GlobalShadows=false end
    end
end)

-- Anti AFK
task.spawn(function()
    while task.wait(60) do
        if registry.afk.get() then
            local v=Instance.new("VirtualUser"); v.Parent=LP
            pcall(function() v:Button1Down(Vector2.new(0,0), WS.CurrentCamera.CFrame) end)
            task.wait(0.5); v:Destroy()
        end
    end
end)

-- ==================== CUBE MINIMIZE ====================
local CUBE = 54
local minimized = false
local savedPos, savedSize = Main.Position, Main.Size
local CubeFrame = n("TextButton",{Parent=GUI,BackgroundColor3=COL.bg,BackgroundTransparency=0.15,BorderSizePixel=0,Size=UDim2.new(0,CUBE,0,CUBE),Position=UDim2.new(0,20,0,20),Text="L",Font=Enum.Font.GothamBold,TextColor3=COL.title,TextSize=26,AutoButtonColor=false,Visible=false,ZIndex=50})
n("UICorner",{CornerRadius=UDim.new(0,12),Parent=CubeFrame})
n("UIStroke",{Color=COL.title,Thickness=2,Parent=CubeFrame})

local cubeDrag, cubeStart, cubePos
CubeFrame.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        cubeDrag=true; cubeStart=i.Position; cubePos=CubeFrame.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if cubeDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-cubeStart
        CubeFrame.Position=UDim2.new(cubePos.X.Scale,cubePos.X.Offset+d.X,cubePos.Y.Scale,cubePos.Y.Offset+d.Y)
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then cubeDrag=false end
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
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        cubeMoved=false
        task.delay(0.15,function() cubeMoved=true end)
    end
end)
CubeFrame.Activated:Connect(function() if not cubeMoved then fromCube() end end)
closeBtn.Activated:Connect(function() GUI:Destroy() end)
-- ==================== SIZE CONTROL ====================
task.defer(function()
    if not (T and T.Settings and T.Settings.page) then return end

    local defaultW, defaultH = 420, 580
    local minW, minH = 300, 300
    local maxW, maxH = 900, 900

    -- Заголовок
    local sizeLabel = n("TextLabel",{
        Parent=T.Settings.page,
        BackgroundColor3=Color3.fromRGB(30,30,30),
        BorderSizePixel=0,
        Size=UDim2.new(1,-8,0,26),
        Font=Enum.Font.GothamBold,
        Text="— MENU SIZE —",
        TextColor3=Color3.fromRGB(140,140,140),
        TextSize=11,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=sizeLabel})

    -- Слайдер Width
    makeSlider(T.Settings.page, "Width", "ui_w", minW, maxW, defaultW, function(v)
        Main.Size = UDim2.new(0, v, 0, Main.Size.Y.Offset)
        -- Центрируем по X, если было по центру
        Main.Position = UDim2.new(0.5, -v/2, Main.Position.Y.Scale, Main.Position.Y.Offset)
    end)

    -- Слайдер Height
    makeSlider(T.Settings.page, "Height", "ui_h", minH, maxH, defaultH, function(v)
        Main.Size = UDim2.new(0, Main.Size.X.Offset, 0, v)
        Main.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset, 0.5, -v/2)
    end)

    -- Пресеты
    local function setSize(w, h)
        Main.Size = UDim2.new(0, w, 0, h)
        Main.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
        if registry.ui_w then registry.ui_w.set(w) end
        if registry.ui_h then registry.ui_h.set(h) end
    end

    makeRealBtn(T.Settings.page, "Preset: Small (340x460)", function() setSize(340, 460) end)
    makeRealBtn(T.Settings.page, "Preset: Medium (420x580)", function() setSize(420, 580) end)
    makeRealBtn(T.Settings.page, "Preset: Large (600x700)", function() setSize(600, 700) end)
    makeRealBtn(T.Settings.page, "Preset: XL (800x850)", function() setSize(800, 850) end)
    makeRealBtn(T.Settings.page, "Preset: Wide (700x500)", function() setSize(700, 500) end)
    makeRealBtn(T.Settings.page, "Reset Size", function() setSize(defaultW, defaultH) end, Color3.fromRGB(200,55,55))
end)
-- ==================== ANTI-CAMPER / MURDERER PUNISH ====================
makeToggle(T.Combat.page, "Anti-Camper (TP+Fling)", "anticamper", false)
makeSlider(T.Combat.page, "Trigger Range", "ac_range", 5, 50, 15)
makeToggle(T.Combat.page, "Auto-Kick Murderer", "ac_kick", true)

local punishCooldown = {}
local PUNISH_DELAY = 2  -- сек между наказаниями одного игрока

task.spawn(function()
    while task.wait(0.15) do
        if not registry.anticamper.get() then continue end
        if not root() or not LP.Character then continue end

        local range = registry.ac_range.get()
        local now = tick()

        for _, p in pairs(Players:GetPlayers()) do
            if p == LP or isWL(p) then continue end
            if not p.Character then continue end

            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if not hrp or not h or h.Health <= 0 then continue end

            -- проверяем что это murderer
            if not isMurderer(p) then continue end

            -- кулдаун на игрока
            if punishCooldown[p] and now - punishCooldown[p] < PUNISH_DELAY then continue end

            local dist = (root().Position - hrp.Position).Magnitude
            if dist <= range then
                punishCooldown[p] = now
                print("[AntiCamper] punishing:", p.Name, "dist:", math.floor(dist))

                -- 1. Телепорт себя к murderer'у
                pcall(function()
                    root().CFrame = hrp.CFrame + Vector3.new(0, 3, 5)
                end)

                task.wait(0.05)

                -- 2. Забираем ownership (чтобы его анти-флинг не спас)
                pcall(function() hrp:SetNetworkOwner(LP) end)

                -- 3. Флинг его в космос — 1e5
                pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(1e5, 1e5, 1e5)
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.P = 1250
                    bv.Parent = hrp
                    game:GetService("Debris"):AddItem(bv, 1.5)

                    local av = Instance.new("BodyAngularVelocity")
                    av.AngularVelocity = Vector3.new(1e5, 1e5, 1e5)
                    av.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                    av.Parent = hrp
                    game:GetService("Debris"):AddItem(av, 1.5)

                    hrp.Velocity = Vector3.new(1e5, 1e5, 1e5)
                    hrp.RotVelocity = Vector3.new(1e5, 1e5, 1e5)
                end)

                task.wait(0.1)

                -- 4. Возвращаем себя в безопасную точку (последняя нормальная позиция)
                pcall(function()
                    root().Velocity = Vector3.zero
                    root().RotVelocity = Vector3.zero
                end)
            end
        end
    end
end)

-- Anti-fling для себя — на случай если он отреагирует
RunService.Heartbeat:Connect(function()
    if not registry.anticamper.get() then return end
    local c = LP.Character
    if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local h = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not h then return end
    -- чистим чужие силы на себе
    for _, v in pairs(hrp:GetChildren()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyAngularVelocity") or v:IsA("BodyGyro") then
            if v.Name ~= "G_SAFE" then v:Destroy() end
        end
    end
    if hrp.Velocity.Magnitude > 300 then
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
    end
end)

makeRealBtn(T.Combat.page, "Test Anti-Camper (nearest)", function()
    local t = getNearest(isMurderer)
    if not t or not t.Character then
        print("[AntiCamper] no murderer found")
        return
    end
    local hrp = t.Character:FindFirstChild("HumanoidRootPart")
    if not hrp or not root() then return end
    print("[AntiCamper] test on:", t.Name)
    root().CFrame = hrp.CFrame + Vector3.new(0, 3, 5)
    task.wait(0.05)
    pcall(function() hrp:SetNetworkOwner(LP) end)
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(1e5, 1e5, 1e5)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = hrp
        game:GetService("Debris"):AddItem(bv, 1.5)
    end)
end)
print("[Lokeii MM2] loaded. Full hub.")
