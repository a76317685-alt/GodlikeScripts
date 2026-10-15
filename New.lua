-- language: Lua, file: godlike_full.lua, runtime: Roblox Executor
-- name: Godlike | Loader + Links + Credits

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local LP      = Players.LocalPlayer
local CoreGui = (pcall(function() return game:GetService("CoreGui") end) and game:GetService("CoreGui")) or LP:WaitForChild("PlayerGui")

local function n(c,p) local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end; return i end

-- ==================== ЗАГРУЗКА update.lua ====================
local ok, err = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/a76317685-alt/GodlikeScripts/refs/heads/main/update.lua"))()
end)
if not ok then
    warn("[Godlike] load failed: "..tostring(err))
end

-- ==================== LINKS MENU ====================
for _, g in pairs(CoreGui:GetChildren()) do
    if g.Name == "GodlikeLinks" then g:Destroy() end
end

local LINKS = {
    {name = "Telegram", url = "t.me/godlike_rb",    color = Color3.fromRGB(41, 171, 226)},
    {name = "Discord",  url = "discord.gg/godlike", color = Color3.fromRGB(114, 137, 218)},
}

local LinksGui = n("ScreenGui",{Name="GodlikeLinks",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})
local LinksMain = n("Frame",{
    Parent=LinksGui, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.12,
    BorderSizePixel=0, Position=UDim2.new(0,20,0,320), Size=UDim2.new(0,260,0,140),
    Active=true, ZIndex=1,
})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=LinksMain})
n("UIStroke",{Color=Color3.fromRGB(60,110,220),Thickness=1,Parent=LinksMain})

local LinksTop = n("Frame",{Parent=LinksMain,BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=0,Size=UDim2.new(1,0,0,32),ZIndex=10})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=LinksTop})
n("TextLabel",{Parent=LinksTop,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-40,1,0),Font=Enum.Font.GothamBold,Text="Godlike | Links",TextColor3=Color3.fromRGB(60,110,220),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
local LinksClose = n("TextButton",{Parent=LinksTop,BackgroundTransparency=1,Position=UDim2.new(1,-28,0,4),Size=UDim2.new(0,24,0,24),Font=Enum.Font.GothamBold,Text="×",TextColor3=Color3.fromRGB(200,60,60),TextSize=18,AutoButtonColor=false,ZIndex=11})
LinksClose.Activated:Connect(function() LinksGui:Destroy() end)

-- drag Links
local lDrag, lDragIn, lDragS, lDragP
LinksTop.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then lDrag=true; lDragIn=i; lDragS=i.Position; lDragP=LinksMain.Position end end)
LinksTop.InputChanged:Connect(function(i) if lDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-lDragS; LinksMain.Position=UDim2.new(lDragP.X.Scale,lDragP.X.Offset+d.X,lDragP.Y.Scale,lDragP.Y.Offset+d.Y) end end)
LinksTop.InputEnded:Connect(function(i) if i==lDragIn then lDrag=false end end)

local LinksBody = n("Frame",{Parent=LinksMain,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,32),Size=UDim2.new(1,0,1,-32),ZIndex=2})
n("UIListLayout",{Parent=LinksBody,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
n("UIPadding",{Parent=LinksBody,PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})

local LinksStatus = n("TextLabel",{Parent=LinksBody,BackgroundTransparency=1,Size=UDim2.new(1,0,0,18),Font=Enum.Font.Gotham,Text="tap to copy",TextColor3=Color3.fromRGB(140,140,140),TextSize=11,ZIndex=6})

for _, link in ipairs(LINKS) do
    local btn = n("TextButton",{
        Parent=LinksBody, BackgroundColor3=link.color, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,36), Font=Enum.Font.GothamBold,
        Text=link.name.." — "..link.url, TextColor3=Color3.fromRGB(255,255,255),
        TextSize=12, AutoButtonColor=false, ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=btn})
    btn.Activated:Connect(function()
        if setclipboard then
            setclipboard(link.url)
            LinksStatus.Text = "copied: "..link.url
            LinksStatus.TextColor3 = Color3.fromRGB(35,140,70)
            task.delay(2, function()
                LinksStatus.Text = "tap to copy"
                LinksStatus.TextColor3 = Color3.fromRGB(140,140,140)
            end)
        else
            LinksStatus.Text = "no setclipboard"
            LinksStatus.TextColor3 = Color3.fromRGB(200,55,55)
        end
    end)
end

-- ==================== CREDITS MENU ====================
for _, g in pairs(CoreGui:GetChildren()) do
    if g.Name == "GodlikeCredits" then g:Destroy() end
end

local CREDITS = {
    {role = "Developer",   name = "limboi", color = Color3.fromRGB(60,110,220)},
    {role = "Scripter",    name = "lokeii", color = Color3.fromRGB(20,200,90)},
    {role = "Idea Author", name = "Limbo",  color = Color3.fromRGB(180,120,255)},
}

local CrGui = n("ScreenGui",{Name="GodlikeCredits",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,Parent=CoreGui})
local CrMain = n("Frame",{
    Parent=CrGui, BackgroundColor3=Color3.fromRGB(0,0,0), BackgroundTransparency=0.12,
    BorderSizePixel=0, Position=UDim2.new(0,20,0,470), Size=UDim2.new(0,260,0,184),
    Active=true, ZIndex=1,
})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=CrMain})
n("UIStroke",{Color=Color3.fromRGB(60,110,220),Thickness=1,Parent=CrMain})

local CrTop = n("Frame",{Parent=CrMain,BackgroundColor3=Color3.fromRGB(15,15,15),BorderSizePixel=0,Size=UDim2.new(1,0,0,32),ZIndex=10})
n("UICorner",{CornerRadius=UDim.new(0,10),Parent=CrTop})
n("TextLabel",{Parent=CrTop,BackgroundTransparency=1,Position=UDim2.new(0,12,0,0),Size=UDim2.new(1,-40,1,0),Font=Enum.Font.GothamBold,Text="Godlike | Credits",TextColor3=Color3.fromRGB(60,110,220),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11})
local CrClose = n("TextButton",{Parent=CrTop,BackgroundTransparency=1,Position=UDim2.new(1,-28,0,4),Size=UDim2.new(0,24,0,24),Font=Enum.Font.GothamBold,Text="×",TextColor3=Color3.fromRGB(200,60,60),TextSize=18,AutoButtonColor=false,ZIndex=11})
CrClose.Activated:Connect(function() CrGui:Destroy() end)

-- drag Credits
local cDrag, cDragIn, cDragS, cDragP
CrTop.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then cDrag=true; cDragIn=i; cDragS=i.Position; cDragP=CrMain.Position end end)
CrTop.InputChanged:Connect(function(i) if cDrag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-cDragS; CrMain.Position=UDim2.new(cDragP.X.Scale,cDragP.X.Offset+d.X,cDragP.Y.Scale,cDragP.Y.Offset+d.Y) end end)
CrTop.InputEnded:Connect(function(i) if i==cDragIn then cDrag=false end end)

local CrBody = n("Frame",{Parent=CrMain,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(0,0,0,32),Size=UDim2.new(1,0,1,-32),ZIndex=2})
n("UIListLayout",{Parent=CrBody,Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
n("UIPadding",{Parent=CrBody,PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)})

for _, person in ipairs(CREDITS) do
    local row = n("Frame",{
        Parent=CrBody, BackgroundColor3=Color3.fromRGB(20,20,20),
        BorderSizePixel=0, Size=UDim2.new(1,0,0,40), ZIndex=6,
    })
    n("UICorner",{CornerRadius=UDim.new(0,6),Parent=row})

    local accent = n("Frame",{
        Parent=row, BackgroundColor3=person.color,
        BorderSizePixel=0, Position=UDim2.new(0,0,0,6),
        Size=UDim2.new(0,3,0,28), ZIndex=7,
    })
    n("UICorner",{CornerRadius=UDim.new(1,0),Parent=accent})

    n("TextLabel",{
        Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,4), Size=UDim2.new(1,-20,0,14),
        Font=Enum.Font.Gotham, Text=person.role,
        TextColor3=Color3.fromRGB(140,140,140), TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7,
    })

    n("TextLabel",{
        Parent=row, BackgroundTransparency=1,
        Position=UDim2.new(0,12,0,17), Size=UDim2.new(1,-20,0,20),
        Font=Enum.Font.GothamBold, Text=person.name,
        TextColor3=person.color, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left, ZIndex=7,
    })
end

print("[Godlike] full loaded: update.lua + Links + Credits.")
