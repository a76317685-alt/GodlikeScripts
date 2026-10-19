-- MM2 Halloween Farm (own script)
-- Собирает конфеты и монеты, стоп на 50 конфет / 40 монет

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local MAX_CANDY = 50
local MAX_COINS = 40

local collectedCandy = 0
local collectedCoins = 0
local running = true

-- Поиск объектов по имени (конфеты/монеты в ивенте)
local function findTargets()
    local targets = {}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not obj:IsA("BasePart") then continue end
        local n = obj.Name:lower()
        if n:find("candy") or n:find("coin") or n:find("money") then
            table.insert(targets, obj)
        end
    end
    return targets
end

-- Проверка: это конфета или монета
local function isCandy(name)
    return name:lower():find("candy") ~= nil
end

local function isCoin(name)
    local n = name:lower()
    return n:find("coin") or n:find("money")
end

-- Телепорт к объекту и подбор
local function collect(obj)
    if not obj or not obj.Parent then return end
    hrp.CFrame = obj.CFrame
    task.wait(0.1)
    -- попытка активировать ProximityPrompt, если есть
    for _, d in ipairs(obj:GetDescendants()) do
        if d:IsA("ProximityPrompt") then
            d:InputHoldBegin()
            task.wait(0.05)
            d:InputHoldEnd()
        end
    end
end

-- Основной цикл
task.spawn(function()
    while running do
        if collectedCandy >= MAX_CANDY and collectedCoins >= MAX_COINS then
            running = false
            break
        end

        local targets = findTargets()
        for _, obj in ipairs(targets) do
            if not running then break end
            if isCandy(obj.Name) and collectedCandy < MAX_CANDY then
                collect(obj)
                collectedCandy += 1
            elseif isCoin(obj.Name) and collectedCoins < MAX_COINS then
                collect(obj)
                collectedCoins += 1
            end
            task.wait(0.05)
        end

        task.wait(0.5)
    end
end)
