--[[
    GHOST HUB | Steal An Egg
    1. Chilli V4       = Auto Sell Pet (toggle)
    2. Do Hoa          = Sell Pet Now
    3. FPS             = Auto Sell Egg (toggle)
    4. Anti AFK        = Sell Eggs Now
    5. Sieu Cap AntiCheat = Auto unfavorite all pets
    6. Hop Sever 1 nguoi  = Auto unequip all equipped pets
    GUI has no close button; no exit-game button.
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local autoPet, autoEgg = true, true
local autoUnfavorite, autoUnequip = true, true -- always ON; no GUI toggles
local busy, running = false, true
local STATUS_TEXT = "Chờ 1 xíu nhé ^^"

local function requirePath(root, path)
    local node = root
    for part in string.gmatch(path, "[^%.]+") do
        node = node and node:FindFirstChild(part)
    end
    if not node then return nil end
    local ok, result = pcall(require, node)
    if ok then return result end
    return nil
end

local Save = requirePath(RS, "Shared.Save") or requirePath(RS, "Client.Save")
local AssetItems = requirePath(RS, "Shared.Util.AssetItems")
local EggRecords = requirePath(RS, "Shared.Util.EggRecords")
local Remotes = requirePath(RS, "Shared.Remotes")

local function getSave()
    if not Save then return nil end
    local getter = Save.Get or Save.Peek
    if not getter then return nil end
    local ok, result = pcall(getter)
    if ok and type(result) == "table" then return result end
    return nil
end

local function decodePet(raw)
    if type(raw) == "table" and raw.Category then return raw end
    if AssetItems and AssetItems.Decode then
        local ok, result = pcall(AssetItems.Decode, raw)
        if ok and type(result) == "table" then return result end
    end
    return nil
end

local function decodeEgg(raw)
    if type(raw) == "table" and (raw.AssetCategory or raw.Category) then return raw end
    if EggRecords and EggRecords.Decode then
        local ok, result = pcall(EggRecords.Decode, raw)
        if ok and type(result) == "table" then return result end
    end
    return nil
end

local function canSell()
    local ok, guard = pcall(function() return require(RS.Client.ToolGameplayGuard) end)
    if ok and guard and guard.IsLocalInsideArena then
        local success, inside = pcall(guard.IsLocalInsideArena)
        if success and inside then return false end
    end
    local character = LP.Character
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item:GetAttribute("ItemType") == "AssetEgg" then
                return false
            end
        end
    end
    return true
end

local function getRemote(parentName, childName, networkName)
    local parent = Remotes and Remotes:FindFirstChild(parentName)
    local remote = parent and parent:FindFirstChild(childName)
    if remote then return remote end
    local packages = RS:FindFirstChild("Packages")
    local networking = packages and packages:FindFirstChild("Networking")
    return networking and networking:FindFirstChild(networkName)
end

local function getSellRemote()
    local parent = Remotes and Remotes:FindFirstChild("PetSatchel")
    local remote = parent and parent:FindFirstChild("SellSelection")
    if remote then return remote end
    local packages = RS:FindFirstChild("Packages")
    local networking = packages and packages:FindFirstChild("Networking")
    return networking and networking:FindFirstChild("RE/PetSatchel/SellSelection")
end

local function sellSelection(petIds, eggIds)
    if not canSell() or (#petIds == 0 and #eggIds == 0) then return false end
    local remote = getSellRemote()
    if not remote then return false end
    return pcall(function() remote:FireServer({Assets = petIds, Eggs = eggIds}) end)
end

local function isCommon(pet)
    local values = {pet.Rarity, pet.RarityName, pet.Tier, pet.RarityType, pet.DisplayRarity}
    for _, value in ipairs(values) do
        if type(value) == "string" and string.lower(value) == "common" then
            return true
        end
    end
    return false
end

local function collectPets()
    local save = getSave()
    if not save then return {} end
    local inventory = save.Inventory or {}
    local equipped = {}
    for _, uid in ipairs(save.EquippedAssets or {}) do equipped[uid] = true end
    local ids = {}
    for uid, raw in pairs(inventory) do
        local pet = decodePet(raw)
        if pet and pet.Category and not equipped[uid]
            and pet.IsFavorite ~= true and pet.Favorite ~= true
            and pet.Locked ~= true and not pet.InFuse then
            table.insert(ids, uid)
        end
    end
    return ids
end

local function collectEggs()
    local save = getSave()
    if not save then return {} end
    local ids = {}
    for uid, raw in pairs(save.EggInventory or {}) do
        local egg = decodeEgg(raw)
        if egg and (egg.AssetCategory or egg.Category) and egg.Placement == nil
            and egg.IsFavorite ~= true and egg.Favorite ~= true and egg.Locked ~= true
            and not (type(egg.Mutations) == "table" and next(egg.Mutations) ~= nil) then
            table.insert(ids, uid)
        end
    end
    return ids
end

local function sellPets() return sellSelection(collectPets(), {}) end
local function sellEggs() return sellSelection({}, collectEggs()) end

-- These remotes are listed in the supplied remote inventory. Invocation signatures
-- may differ by game version; calls are protected with pcall to avoid breaking loops.
local function unfavoriteAllPets()
    local save = getSave()
    if not save then return end
    local remote = getRemote("PetSatchel", "WriteFavourite", "RE/PetSatchel/WriteFavourite")
    if not remote or not remote:IsA("RemoteEvent") then return end
    for uid, raw in pairs(save.Inventory or {}) do
        if not running then break end
        local pet = decodePet(raw)
        if pet and (pet.IsFavorite == true or pet.Favorite == true) then
            pcall(function() remote:FireServer(uid, false) end)
            task.wait(0.03)
        end
    end
end

local function unequipAllPets()
    local save = getSave()
    if not save then return end
    local remote = getRemote("PenRoster", "AskDoff", "RF/PenRoster/AskDoff")
    if not remote or not remote:IsA("RemoteFunction") then return end
    local inventory = save.Inventory or {}
    for _, uid in ipairs(save.EquippedAssets or {}) do
        if not running then break end
        local pet = decodePet(inventory[uid])
        if pet then
            pcall(function() remote:InvokeServer(uid) end)
            task.wait(0.03)
        end
    end
end

-- GUI
local old = PlayerGui:FindFirstChild("GhostHub")
if old then old:Destroy() end
local gui = Instance.new("ScreenGui")
gui.Name = "GhostHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(260, 300)
main.Position = UDim2.new(0.5, -130, 0.28, 0)
main.BackgroundColor3 = Color3.fromRGB(7, 6, 15)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 13)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(183, 83, 255)
stroke.Thickness = 2.5

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -42, 0, 37)
title.Position = UDim2.fromOffset(10, 2)
title.BackgroundTransparency = 1
title.Text = "👻  GHOST HUB"
title.TextColor3 = Color3.fromRGB(220, 190, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 17
title.Parent = main

local bat = Instance.new("TextLabel")
bat.Size = UDim2.fromOffset(30, 30)
bat.Position = UDim2.new(1, -37, 0, 4)
bat.BackgroundTransparency = 1
bat.Text = "🦇"
bat.TextSize = 20
bat.Parent = main

local status = Instance.new("TextLabel")
status.Name = "Status"
status.Size = UDim2.new(1, -16, 0, 22)
status.Position = UDim2.fromOffset(8, 34)
status.BackgroundTransparency = 1
status.Text = STATUS_TEXT
status.TextColor3 = Color3.fromRGB(190, 150, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = main

local function setStatus(message)
    if status and status.Parent then status.Text = message or STATUS_TEXT end
end

local function makeButton(label, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -22, 0, 32)
    button.Position = UDim2.fromOffset(11, y)
    button.BackgroundColor3 = Color3.fromRGB(28, 17, 43)
    button.TextColor3 = Color3.fromRGB(247, 236, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 11
    button.Text = label
    button.AutoButtonColor = true
    button.Parent = main
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    local outline = Instance.new("UIStroke", button)
    outline.Color = Color3.fromRGB(144, 67, 220)
    outline.Thickness = 1
    button.MouseButton1Click:Connect(function()
        if running then
            local ok, err = pcall(callback)
            if not ok then setStatus("Lỗi: " .. tostring(err)) end
        end
    end)
    return button
end

local chilliButton, fpsButton
local function refreshButtons()
    if chilliButton then chilliButton.Text = "Chilli V4  |  " .. (autoPet and "ON" or "OFF") end
    if fpsButton then fpsButton.Text = "FPS  |  " .. (autoEgg and "ON" or "OFF") end
end

chilliButton = makeButton("✦  Chilli V4  ·  ON", 62, function()
    autoPet = not autoPet
    refreshButtons()
end)
makeButton("✧  Đồ Hoạ  ·  Bán pet ngay", 98, function()
    if busy then return end
    busy = true
    task.spawn(function() pcall(sellPets); busy = false; setStatus() end)
end)
fpsButton = makeButton("⚡  FPS  ·  ON", 134, function()
    autoEgg = not autoEgg
    refreshButtons()
end)
makeButton("☾  Anti AFK  ·  Bán trứng ngay", 170, function()
    if busy then return end
    busy = true
    task.spawn(function() pcall(sellEggs); busy = false; setStatus() end)
end)
-- Two utility functions are permanently ON; buttons do not toggle them off.
makeButton("🛡  AntiCheat  ·  LUÔN BẬT", 206, function()
    task.spawn(function() pcall(unfavoriteAllPets) end)
    setStatus("Đang bỏ yêu thích pet")
end)
makeButton("👻  Tháo pet  ·  LUÔN BẬT", 242, function()
    task.spawn(function() pcall(unequipAllPets) end)
    setStatus("Đang tháo pet đang trang bị")
end)
-- Drag GUI on touch or mouse
autoPet = true
autoEgg = true
local dragging, dragStart, startPos = false, nil, nil
local function beginDrag(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end
title.InputBegan:Connect(beginDrag)
bat.InputBegan:Connect(beginDrag)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Always-on background loops for the two new functions
task.spawn(function()
    while running and gui.Parent do
        task.wait(1)
        pcall(unfavoriteAllPets)
    end
end)
task.spawn(function()
    while running and gui.Parent do
        task.wait(1)
        pcall(unequipAllPets)
    end
end)

-- Original auto-sell loop
task.spawn(function()
    while running and gui.Parent do
        task.wait(1)
        if not busy and (autoPet or autoEgg) then
            busy = true
            pcall(function()
                if not canSell() then return end
                local pets, eggs = {}, {}
                if autoPet then pets = collectPets() end
                if autoEgg then eggs = collectEggs() end
                if #pets > 0 or #eggs > 0 then sellSelection(pets, eggs) end
            end)
            busy = false
            setStatus()
        end
    end
end)

refreshButtons()
setStatus()
