
-- Nhat Khanh Auto | Steal An Egg
-- Chỉ đổi tên nút, giữ nguyên chức năng bán Pet/Egg

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local running = true
local autoPet = false
local autoEgg = false
local busy = false

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

local Save = requirePath(RS, "Shared.Save")
    or requirePath(RS, "Client.Save")
local AssetItems = requirePath(RS, "Shared.Util.AssetItems")
local EggRecords = requirePath(RS, "Shared.Util.EggRecords")
local Remotes = requirePath(RS, "Shared.Remotes")

local function getSave()
    if not Save then return nil end
    local getter = Save.Get or Save.Peek
    if not getter then return nil end
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
        local ok, result = pcall(AssetItems.Decode, raw)
        if ok and type(result) == "table" then
            return result
        end
    end
    return nil
end

local function decodeEgg(raw)
    if type(raw) == "table" and
        (raw.AssetCategory or raw.Category) then
        return raw
    end
    if EggRecords and EggRecords.Decode then
        local ok, result = pcall(EggRecords.Decode, raw)
        if ok and type(result) == "table" then
            return result
        end
    end
    return nil
end

local function canSell()
    local ok, guard = pcall(function()
        return require(RS.Client.ToolGameplayGuard)
    end)

    if ok and guard and guard.IsLocalInsideArena then
        local success, inside = pcall(guard.IsLocalInsideArena)
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

local function sellSelection(petIds, eggIds)
    if not canSell() then
        return false, "Hay ve vung an toan truoc khi ban"
    end

    if #petIds == 0 and #eggIds == 0 then
        return false, "Khong co Pet/Egg phu hop"
    end

    local remote = Remotes
        and Remotes.PetSatchel
        and Remotes.PetSatchel.SellSelection

    if not remote then
        local packages = RS:FindFirstChild("Packages")
        local networking = packages and packages:FindFirstChild("Networking")
        remote = networking and networking:FindFirstChild(
            "RE/PetSatchel/SellSelection"
        )
    end

    if not remote then
        return false, "Khong tim thay SellSelection remote"
    end

    local ok, err = pcall(function()
        remote:FireServer({
            Assets = petIds,
            Eggs = eggIds
        })
    end)

    if not ok then
        return false, tostring(err)
    end

    return true, "Da gui yeu cau ban"
end

local function collectPets()
    local save = getSave()
    if not save then return {} end

    local inventory = save.Inventory or {}
    local equipped = {}

    for _, uid in ipairs(save.EquippedAssets or {}) do
        equipped[uid] = true
    end

    local ids = {}

    for uid, raw in pairs(inventory) do
        local pet = decodePet(raw)

        if pet and pet.Category
            and not equipped[uid]
            and pet.IsFavorite ~= true
            and pet.Favorite ~= true
            and pet.Locked ~= true
            and not pet.InFuse then
            table.insert(ids, uid)
        end
    end

    return ids
end

local function collectEggs()
    local save = getSave()
    if not save then return {} end

    local inventory = save.EggInventory or {}
    local ids = {}

    for uid, raw in pairs(inventory) do
        local egg = decodeEgg(raw)

        if egg and (egg.AssetCategory or egg.Category)
            and egg.Placement == nil
            and egg.IsFavorite ~= true
            and egg.Favorite ~= true
            and egg.Locked ~= true
            and not (type(egg.Mutations) == "table"
                and next(egg.Mutations) ~= nil) then
            table.insert(ids, uid)
        end
    end

    return ids
end

local function sellPets()
    local ids = collectPets()
    return sellSelection(ids, {}), #ids
end

local function sellEggs()
    local ids = collectEggs()
    return sellSelection({}, ids), #ids
end

-- GUI
local old = LP.PlayerGui:FindFirstChild("NhatKhanhAuto")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NhatKhanhAuto"
gui.ResetOnSpawn = false
gui.Parent = LP:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(230, 220)
main.Position = UDim2.new(0.5, -115, 0.35, 0)
main.BackgroundColor3 = Color3.fromRGB(255, 225, 243)
main.BorderSizePixel = 0
main.Active = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 75, 170)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 34)
title.Position = UDim2.fromOffset(10, 3)
title.BackgroundTransparency = 1
title.Text = "♡ NHAT KHANH AUTO ♡"
title.TextColor3 = Color3.fromRGB(190, 30, 115)
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(27, 27)
close.Position = UDim2.new(1, -31, 0, 5)
close.Text = "×"
close.TextSize = 20
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.fromRGB(190, 30, 115)
close.BackgroundColor3 = Color3.fromRGB(255, 190, 225)
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -16, 0, 24)
status.Position = UDim2.fromOffset(8, 34)
status.BackgroundTransparency = 1
status.Text = "Ready | Common+"
status.TextColor3 = Color3.fromRGB(140, 35, 95)
status.Font = Enum.Font.Gotham
status.TextSize = 11
status.Parent = main

local function makeButton(label, y, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 34)
    button.Position = UDim2.fromOffset(10, y)
    button.BackgroundColor3 = Color3.fromRGB(255, 105, 185)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Text = label
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius =
        UDim.new(0, 8)

    button.MouseButton1Click:Connect(callback)
    return button
end

local chilliButton, fpsButton

local function refreshButtons()
    chilliButton.Text = "Chilli V4 | " ..
        (autoPet and "ON" or "OFF")
    fpsButton.Text = "FPS | " ..
        (autoEgg and "ON" or "OFF")
end

-- Nút 1: vẫn bật/tắt Auto Sell Pet
chilliButton = makeButton("Chilli V4 | OFF", 64, function()
    autoPet = not autoPet
    refreshButtons()
end)

-- Nút 2: vẫn bán Pet ngay
makeButton("Do Hoa", 104, function()
    if busy then return end
    busy = true

    local ok, success, message = pcall(function()
        local ids = collectPets()
        local result, msg = sellSelection(ids, {})
        return result, msg
    end)

    status.Text = ok and tostring(message) or "Pet error"
    busy = false
end)

-- Nút 3: vẫn bật/tắt Auto Sell Egg
fpsButton = makeButton("FPS | OFF", 144, function()
    autoEgg = not autoEgg
    refreshButtons()
end)

-- Nút 4: vẫn bán Egg ngay
makeButton("Anti AFK", 184, function()
    if busy then return end
    busy = true

    local ok, success, message = pcall(function()
        local ids = collectEggs()
        local result, msg = sellSelection({}, ids)
        return result, msg
    end)

    status.Text = ok and tostring(message) or "Egg error"
    busy = false
end)

close.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

-- Kéo GUI bằng thanh tiêu đề
local dragging = false
local dragStart, startPos

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

-- Vòng lặp Auto Sell
task.spawn(function()
    while running and gui.Parent do
        task.wait(2.5)

        if not busy and (autoPet or autoEgg) and canSell() then
            busy = true

            local ok, err = pcall(function()
                local pets = autoPet and collectPets() or {}
                local eggs = autoEgg and collectEggs() or {}

                if #pets > 0 or #eggs > 0 then
                    local success, message = sellSelection(pets, eggs)
                    status.Text = success
                        and ("Sell sent | P:" .. #pets ..
                            " E:" .. #eggs)
                        or tostring(message)
                else
                    status.Text = "No eligible items"
                end
            end)

            if not ok then
                status.Text = "Sell error: " .. tostring(err)
            end

            busy = false
        end
    end
end)

refreshButtons()
