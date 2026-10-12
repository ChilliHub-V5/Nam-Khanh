
--[[
    GHOST HUB | Steal An Egg
    Chilli V4 = Auto Sell Pet
    Do Hoa     = Sell Pet Now
    FPS        = Auto Sell Egg
    Anti AFK   = Sell Eggs Now
]]

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local autoPet = true
local autoEgg = true
local busy = false
local running = true

local STATUS_TEXT = "Chờ 1 xíu nhé ^^"

--==================================================
-- MODULES
--==================================================

local function requirePath(root, path)
    local node = root

    for part in string.gmatch(path, "[^%.]+") do
        node = node and node:FindFirstChild(part)
    end

    if not node then
        return nil
    end

    local ok, result = pcall(require, node)

    if ok then
        return result
    end

    return nil
end

local Save = requirePath(RS, "Shared.Save")
    or requirePath(RS, "Client.Save")

local AssetItems = requirePath(
    RS,
    "Shared.Util.AssetItems"
)

local EggRecords = requirePath(
    RS,
    "Shared.Util.EggRecords"
)

local Remotes = requirePath(RS, "Shared.Remotes")

local function getSave()
    if not Save then
        return nil
    end

    local getter = Save.Get or Save.Peek

    if not getter then
        return nil
    end

    local ok, result = pcall(getter)

    if ok and type(result) == "table" then
        return result
    end

    return nil
end

local function decodePet(raw)
    if type(raw) == "table" and raw.Category then
        return raw
    end

    if AssetItems and AssetItems.Decode then
        local ok, result = pcall(
            AssetItems.Decode,
            raw
        )

        if ok and type(result) == "table" then
            return result
        end
    end

    return nil
end

local function decodeEgg(raw)
    if type(raw) == "table"
        and (raw.AssetCategory or raw.Category) then
        return raw
    end

    if EggRecords and EggRecords.Decode then
        local ok, result = pcall(
            EggRecords.Decode,
            raw
        )

        if ok and type(result) == "table" then
            return result
        end
    end

    return nil
end

--==================================================
-- SELL LOGIC
--==================================================

local function canSell()
    local ok, guard = pcall(function()
        return require(RS.Client.ToolGameplayGuard)
    end)

    if ok and guard and guard.IsLocalInsideArena then
        local success, inside = pcall(
            guard.IsLocalInsideArena
        )

        if success and inside then
            return false
        end
    end

    local character = LP.Character

    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool")
                and item:GetAttribute("ItemType") == "AssetEgg" then
                return false
            end
        end
    end

    return true
end

local function getSellRemote()
    local remote = Remotes
        and Remotes.PetSatchel
        and Remotes.PetSatchel.SellSelection

    if remote then
        return remote
    end

    local packages = RS:FindFirstChild("Packages")
    local networking = packages
        and packages:FindFirstChild("Networking")

    return networking
        and networking:FindFirstChild(
            "RE/PetSatchel/SellSelection"
        )
end

local function sellSelection(petIds, eggIds)
    if not canSell() then
        return false
    end

    if #petIds == 0 and #eggIds == 0 then
        return false
    end

    local remote = getSellRemote()

    if not remote then
        return false
    end

    local ok = pcall(function()
        remote:FireServer({
            Assets = petIds,
            Eggs = eggIds
        })
    end)

    return ok
end

local function collectPets()
    local save = getSave()

    if not save then
        return {}
    end

    local inventory = save.Inventory or {}
    local equipped = {}

    for _, uid in ipairs(save.EquippedAssets or {}) do
        equipped[uid] = true
    end

    local ids = {}

    for uid, raw in pairs(inventory) do
        local pet = decodePet(raw)

        if pet
            and pet.Category
            and not equipped[uid]
            and pet.IsFavorite ~= true
            and pet.Favorite ~= true
            and pet.Locked ~= true
            and not pet.InFuse then

            -- Common trở lên
            table.insert(ids, uid)
        end
    end

    return ids
end

local function collectEggs()
    local save = getSave()

    if not save then
        return {}
    end

    local inventory = save.EggInventory or {}
    local ids = {}

    for uid, raw in pairs(inventory) do
        local egg = decodeEgg(raw)

        if egg
            and (egg.AssetCategory or egg.Category)
            and egg.Placement == nil
            and egg.IsFavorite ~= true
            and egg.Favorite ~= true
            and egg.Locked ~= true
            and not (
                type(egg.Mutations) == "table"
                and next(egg.Mutations) ~= nil
            ) then

            -- Common trở lên
            table.insert(ids, uid)
        end
    end

    return ids
end

local function sellPets()
    local ids = collectPets()
    return sellSelection(ids, {})
end

local function sellEggs()
    local ids = collectEggs()
    return sellSelection({}, ids)
end

--==================================================
-- GUI
--==================================================

local old = PlayerGui:FindFirstChild("GhostHub")

if old then
    old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "GhostHub"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(235, 230)
main.Position = UDim2.new(0.5, -117, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(9, 8, 17)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 13)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(145, 65, 220)
mainStroke.Thickness = 2
mainStroke.Parent = main

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -42, 0, 37)
title.Position = UDim2.fromOffset(10, 2)
title.BackgroundTransparency = 1
title.Text = "GHOST HUB"
title.TextColor3 = Color3.fromRGB(220, 190, 255)
title.Font = Enum.Font.GothamBlack
title.TextSize = 18
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
status.Position = UDim2.fromOffset(8, 36)
status.BackgroundTransparency = 1
status.Text = STATUS_TEXT
status.TextColor3 = Color3.fromRGB(190, 150, 255)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = main

local function setStatus()
    if status and status.Parent then
        status.Text = STATUS_TEXT
    end
end

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(24, 24)
close.Position = UDim2.new(1, -29, 0, 39)
close.BackgroundColor3 = Color3.fromRGB(55, 25, 75)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255, 220, 255)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = main

Instance.new("UICorner", close).CornerRadius =
    UDim.new(0, 6)

local chilliButton
local fpsButton

local function makeButton(label, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 34)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(38, 23, 54)
    button.TextColor3 = Color3.fromRGB(235, 220, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Text = label
    button.AutoButtonColor = true
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(125, 55, 190)
    outline.Thickness = 1
    outline.Parent = button

    button.MouseButton1Click:Connect(function()
        if not running then
            return
        end

        callback()
        setStatus()
    end)

    return button
end

local function refreshButtons()
    chilliButton.Text = "Chilli V4  |  "
        .. (autoPet and "ON" or "OFF")

    fpsButton.Text = "FPS  |  "
        .. (autoEgg and "ON" or "OFF")
end

--==================================================
-- FOUR BUTTONS
--==================================================

-- 1. Chilli V4 = Auto Sell Pet
chilliButton = makeButton(
    "Chilli V4 | ON",
    65,
    function()
        autoPet = not autoPet
        refreshButtons()
    end
)

-- 2. Do Hoa = Sell Pet Now
makeButton(
    "Đồ Hoạ",
    105,
    function()
        if busy then
            return
        end

        busy = true
        task.spawn(function()
            pcall(sellPets)
            busy = false
            setStatus()
        end)
    end
)

-- 3. FPS = Auto Sell Egg
fpsButton = makeButton(
    "FPS | ON",
    145,
    function()
        autoEgg = not autoEgg
        refreshButtons()
    end
)

-- 4. Anti AFK = Sell Eggs Now
makeButton(
    "Anti AFK",
    185,
    function()
        if busy then
            return
        end

        busy = true
        task.spawn(function()
            pcall(sellEggs)
            busy = false
            setStatus()
        end)
    end
)

--==================================================
-- DRAG GUI
--==================================================

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

bat.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPos = main.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--==================================================
-- CLOSE GUI
--==================================================

close.MouseButton1Click:Connect(function()
    running = false
    autoPet = false
    autoEgg = false
    gui:Destroy()
end)

--==================================================
-- AUTO SELL LOOP
--==================================================

task.spawn(function()
    while running and gui.Parent do
        task.wait(2.5)

        if not busy and (autoPet or autoEgg) then
            busy = true

            pcall(function()
                if not canSell() then
                    return
                end

                local pets = {}
                local eggs = {}

                if autoPet then
                    pets = collectPets()
                end

                if autoEgg then
                    eggs = collectEggs()
                end

                if #pets > 0 or #eggs > 0 then
                    sellSelection(pets, eggs)
                end
            end)

            busy = false
            setStatus()
        end
    end
end)

--==================================================
-- STARTUP
--==================================================

refreshButtons()
setStatus()

-- AutoPet và AutoEgg đã bật ngay khi GUI mở.
-- Hai nút bán thủ công chỉ chạy khi được nhấn.

