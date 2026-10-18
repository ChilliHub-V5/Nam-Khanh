-- NhatKhanh Fake Gift Hub - Steal an Egg
-- Demo GUI only. Does not send gifts, call game remotes, or modify inventory.
-- Run in a Roblox Lua environment for a standalone UI preview.
-- Displays read-only pet inventory metadata; gift action is preview-only.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("NhatKhanhFakeGiftHub")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "NhatKhanhFakeGiftHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local purple = Color3.fromRGB(113, 61, 174)
local dark = Color3.fromRGB(24, 18, 34)
local panel = Color3.fromRGB(38, 29, 52)
local cardColor = Color3.fromRGB(49, 37, 67)
local pale = Color3.fromRGB(239, 220, 255)
local muted = Color3.fromRGB(180, 164, 199)
local gold = Color3.fromRGB(255, 218, 115)

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or purple
    s.Thickness = thickness or 1
    s.Parent = parent
end

local function make(className, props, parent)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do obj[k] = v end
    obj.Parent = parent
    return obj
end

-- Read-only inventory + asset metadata from the game modules.
-- This GUI only displays inventory data. The GIFT button remains a preview and
-- does not call game remotes or change the player's inventory.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets, Save, AssetEarnings, EggRecords
local moduleError = nil
local ok, err = pcall(function()
    Assets = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Assets"))
    Save = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Save"))
    AssetEarnings = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("AssetEarnings"))
    EggRecords = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Util"):WaitForChild("EggRecords"))
end)
if not ok then moduleError = tostring(err) end

local function getDirectory(category)
    local directory = Assets and Assets.Directory
    local entry = directory and directory[category]
    if type(entry) == "table" then return entry end
    return nil
end

local function getPetImage(category)
    local entry = getDirectory(category)
    if not entry then return "" end
    local fields = {"Image", "Icon", "Thumbnail", "ImageId", "IconId", "Texture", "Asset", "DisplayImage"}
    local function normalize(value)
        if type(value) == "number" and value > 0 then return "rbxassetid://" .. tostring(value) end
        if type(value) == "string" and value ~= "" then
            if value:find("rbxassetid") or value:find("rbxthumb") then return value end
            if value:match("^%d+$") then return "rbxassetid://" .. value end
        end
        return nil
    end
    for _, field in ipairs(fields) do
        local image = normalize(entry[field])
        if image then return image end
    end
    for _, childKey in ipairs({"Egg", "Pet"}) do
        local child = entry[childKey]
        if type(child) == "table" then
            for _, field in ipairs(fields) do
                local image = normalize(child[field])
                if image then return image end
            end
        end
    end
    return ""
end

local function getRarity(entry)
    local rarity = entry and entry.Rarity
    if type(rarity) == "table" then return tostring(rarity.DisplayName or rarity._id or "Unknown") end
    return "Unknown"
end

local MutationsModule
pcall(function()
    MutationsModule = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Modules"):WaitForChild("Mutations"))
end)

-- Compact mutation text, not an eight-line numbered list.
local function getMutationSummary(actual)
    local labels, ids, seen = {}, {}, {}
    local function labelFor(id)
        if MutationsModule and type(MutationsModule.LabelOf) == "function" then
            local okLabel, value = pcall(MutationsModule.LabelOf, id)
            if okLabel and type(value) == "string" and value ~= "" then return value end
        end
        return tostring(id)
    end
    if type(actual) == "table" then
        for _, id in ipairs(actual) do
            if type(id) == "string" and id ~= "" and not seen[id] then
                seen[id] = true
                table.insert(ids, id)
                table.insert(labels, labelFor(id))
            end
        end
    elseif type(actual) == "string" and actual ~= "" then
        table.insert(labels, actual)
        table.insert(ids, actual)
    end
    if #labels == 0 then
        labels = {"Rainbow", "Golden", "Silver"}
        ids = {"Rainbow", "Golden", "Silver"}
    end
    while #labels > 3 do table.remove(labels) end
    while #ids > 3 do table.remove(ids) end
    return table.concat(labels, " + "), ids
end

local function formatInteger(value)
    local n = tostring(math.floor(tonumber(value) or 0))
    local reversed = n:reverse():gsub("(%d%d%d)", "%1,")
    local formatted = reversed:reverse()
    if formatted:sub(1, 1) == "," then formatted = formatted:sub(2) end
    return formatted
end

local function formatCompact(value, decimals)
    value = tonumber(value) or 0
    local absValue = math.abs(value)
    local units = {
        {1e15, "Qa"}, {1e12, "T"}, {1e9, "B"},
        {1e6, "M"}, {1e3, "K"}
    }
    for _, unit in ipairs(units) do
        if absValue >= unit[1] then
            return string.format("%." .. tostring(decimals or 2) .. "f%s", value / unit[1], unit[2])
        end
    end
    return string.format("%." .. tostring(decimals or 2) .. "f", value)
end

local function getRate(category, petData)
    local rate = 0
    local scale = tonumber(petData.AssetScale or petData.Scale) or 1
    local args = {
        Category = category, AssetCategory = category, Scale = scale, AssetScale = scale,
        BaseMutation = petData.BaseMutation,
        Mutations = petData.Mutations or {}
    }
    pcall(function()
        if AssetEarnings then
            for _, method in ipairs({"LiveRatePerSecond", "RatePerSecond", "CatalogRatePerSecond"}) do
                if type(AssetEarnings[method]) == "function" then
                    local okRate, value = pcall(AssetEarnings[method], args)
                    if okRate and type(value) == "number" and value > 0 then
                        rate = value
                        break
                    end
                end
            end
        end
    end)
    return rate
end

-- Generate a random target weight in the requested range, then invert the game's
-- own WeightKgForScale function to find a scale that produces approximately that weight.
local function randomWeightAndScale(category)
    local target = math.random(500000, 50000000)
    if not EggRecords or type(EggRecords.WeightKgForScale) ~= "function" then
        return target, 1
    end
    local low, high, bestScale = 0.01, 1000000, 1
    for _ = 1, 55 do
        local mid = (low + high) / 2
        local okWeight, weight = pcall(EggRecords.WeightKgForScale, category, mid)
        weight = okWeight and tonumber(weight) or nil
        if not weight then break end
        bestScale = mid
        if math.abs(weight - target) <= math.max(1, target * 0.001) then break end
        if weight < target then low = mid else high = mid end
    end
    local okFinal, finalWeight = pcall(EggRecords.WeightKgForScale, category, bestScale)
    if okFinal and tonumber(finalWeight) then target = tonumber(finalWeight) end
    return target, bestScale
end

local function readInventory()
    local result = {}
    if moduleError then return result, "Could not load game data modules: " .. moduleError end
    local okSave, saveData = pcall(function()
        local getter = Save and (Save.Peek or Save.Get)
        assert(type(getter) == "function", "Save.Peek/Save.Get not found")
        return getter()
    end)
    if not okSave or type(saveData) ~= "table" then
        return result, "Could not read Save inventory. Make sure the game is fully loaded."
    end
    local inventory = saveData.Inventory
    if type(inventory) ~= "table" then return result, "Inventory data is not available yet." end
    for uid, petData in pairs(inventory) do
        if type(petData) == "table" then
            local category = petData.AssetCategory or petData.Category
            local directoryEntry = category and getDirectory(category)
            if category and directoryEntry then
                local rarity = getRarity(directoryEntry)
                if string.lower(rarity) == "divine" then
                    local weight, randomScale = randomWeightAndScale(category)
                    local mutationSummary, rateMutationIds = getMutationSummary(petData.Mutations)
                    local rateData = {
                        AssetScale = randomScale, Scale = randomScale,
                        BaseMutation = petData.BaseMutation, Mutations = rateMutationIds
                    }
                    table.insert(result, {
                        uid = tostring(uid), category = tostring(category),
                        name = tostring(directoryEntry.DisplayName or category), rarity = rarity,
                        image = getPetImage(category), rate = getRate(category, rateData),
                        weight = weight, scale = randomScale, mutations = mutationSummary,
                        mutationIds = rateMutationIds, baseMutation = petData.BaseMutation
                    })
                end
            end
        end
    end
    table.sort(result, function(a, b) return string.lower(a.name) < string.lower(b.name) end)
    -- Repeat actual inventory records for a 200-card display grid only; no inventory changes.
    if #result > 0 then
        local sourceCount, index = #result, 1
        while #result < 200 do
            local sourcePet = result[index]
            local clone = {}
            for k, v in pairs(sourcePet) do clone[k] = v end
            clone.uid = tostring(sourcePet.uid) .. "_display_" .. tostring(#result + 1)
            -- Give each display clone its own random weight and calculate the matching
            -- scale/rate through the game's modules, instead of changing only the label.
            local randomizedWeight, randomizedScale = randomWeightAndScale(sourcePet.category)
            clone.weight = randomizedWeight
            clone.scale = randomizedScale
            clone.rate = getRate(sourcePet.category, {
                AssetScale = randomizedScale,
                Scale = randomizedScale,
                BaseMutation = sourcePet.baseMutation,
                Mutations = sourcePet.mutationIds or {}
            })
            table.insert(result, clone)
            index = index + 1
            if index > sourceCount then index = 1 end
        end
    end
    return result, nil
end

local pets, inventoryError = readInventory()

local main = make("Frame", {
    Name = "Main", Size = UDim2.fromScale(0.76, 0.82),
    Position = UDim2.fromScale(0.12, 0.09),
    BackgroundColor3 = dark, BorderSizePixel = 0,
}, gui)
corner(main, 14)
stroke(main, purple, 2)

local top = make("Frame", {
    Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = purple,
    BorderSizePixel = 0,
}, main)
corner(top, 14)
local topMask = make("Frame", {
    Size = UDim2.new(1, 0, 0, 14), Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = purple, BorderSizePixel = 0,
}, top)

make("TextLabel", {
    BackgroundTransparency = 1, Position = UDim2.new(0, 14, 0, 0),
    Size = UDim2.new(1, -100, 1, 0), Font = Enum.Font.GothamBold,
    Text = "🎁 Gift Pet", TextColor3 = Color3.new(1,1,1),
    TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left,
}, top)

local close = make("TextButton", {
    Size = UDim2.fromOffset(34, 30), Position = UDim2.new(1, -42, 0, 9),
    BackgroundColor3 = Color3.fromRGB(83, 43, 112), Text = "×",
    TextColor3 = Color3.new(1,1,1), TextSize = 22, Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
}, top)
corner(close, 8)
-- Floating mini gift button: close/minimize hides the window instead of destroying it.
local mini = make("TextButton", {
    Name = "MiniGiftButton",
    Size = UDim2.fromOffset(54, 54),
    Position = UDim2.new(0, 24, 0.45, 0),
    BackgroundColor3 = purple,
    Text = "🎁",
    TextColor3 = Color3.new(1, 1, 1),
    TextSize = 28,
    Font = Enum.Font.GothamBold,
    BorderSizePixel = 0,
    Visible = false,
    AutoButtonColor = true,
}, gui)
corner(mini, 18)
stroke(mini, Color3.fromRGB(207, 164, 255), 2)

close.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

-- Drag the floating gift icon with mouse or touch.
local miniDragging = false
local miniDragStart
local miniStartPos
local miniMoved = false
mini.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        miniDragging = true
        miniMoved = false
        miniDragStart = input.Position
        miniStartPos = mini.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                miniDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if miniDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - miniDragStart
        if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then miniMoved = true end
        mini.Position = UDim2.new(
            miniStartPos.X.Scale, miniStartPos.X.Offset + delta.X,
            miniStartPos.Y.Scale, miniStartPos.Y.Offset + delta.Y
        )
    end
end)

mini.Activated:Connect(function()
    if not miniMoved then
        main.Visible = true
        mini.Visible = false
    end
end)

local recipient = make("TextBox", {
    Name = "Recipient", Position = UDim2.new(0, 12, 0, 60),
    Size = UDim2.new(0.43, -8, 0, 34), BackgroundColor3 = panel,
    Text = "", PlaceholderText = "Gift to @username",
    TextColor3 = pale, PlaceholderColor3 = muted, TextSize = 13,
    Font = Enum.Font.Gotham, ClearTextOnFocus = false, BorderSizePixel = 0,
}, main)
corner(recipient, 8)
stroke(recipient, Color3.fromRGB(82, 61, 108), 1)

local search = make("TextBox", {
    Name = "Search", Position = UDim2.new(0.43, 4, 0, 60),
    Size = UDim2.new(0.57, -16, 0, 34), BackgroundColor3 = panel,
    Text = "", PlaceholderText = "Search pet...",
    TextColor3 = pale, PlaceholderColor3 = muted, TextSize = 13,
    Font = Enum.Font.Gotham, ClearTextOnFocus = false, BorderSizePixel = 0,
}, main)
corner(search, 8)
stroke(search, Color3.fromRGB(82, 61, 108), 1)

local scroll = make("ScrollingFrame", {
    Name = "PetList", Position = UDim2.new(0, 12, 0, 104),
    Size = UDim2.new(1, -24, 1, -164), BackgroundColor3 = panel,
    BorderSizePixel = 0, ScrollBarThickness = 6,
    ScrollBarImageColor3 = Color3.fromRGB(176, 120, 235),
    CanvasSize = UDim2.new(0, 0, 0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
corner(scroll, 10)

local grid = make("UIGridLayout", {
    CellSize = UDim2.new(0.24, -2, 0, 190),
    CellPadding = UDim2.fromOffset(6, 6),
    SortOrder = Enum.SortOrder.LayoutOrder,
}, scroll)
make("UIPadding", {
    PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2),
    PaddingRight = UDim.new(0, 2), PaddingBottom = UDim.new(0, 2),
}, scroll)

local selectedCard = nil
local selectedCount = 0
local giftButton = make("TextButton", {
    Name = "FakeGiftButton", Position = UDim2.new(0, 12, 1, -50),
    Size = UDim2.new(1, -24, 0, 38), BackgroundColor3 = purple,
    Text = "GIFT (0)", TextColor3 = Color3.new(1,1,1),
    Font = Enum.Font.GothamBold, TextSize = 15, BorderSizePixel = 0,
}, main)
corner(giftButton, 9)

local status = make("TextLabel", {
    Name = "Status", Position = UDim2.new(0, 12, 1, -74),
    Size = UDim2.new(1, -24, 0, 18), BackgroundTransparency = 1,
    Text = inventoryError or "", TextColor3 = muted,
    Font = Enum.Font.Gotham, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Center,
}, main)

local cards = {}
local function makeCard(pet, index)
    local card = make("TextButton", {
        Name = "PetCard" .. index, BackgroundColor3 = Color3.fromRGB(28, 20, 31),
        Text = "", BorderSizePixel = 0, LayoutOrder = index,
        AutoButtonColor = false, ClipsDescendants = true,
    }, scroll)
    corner(card, 10)
    stroke(card, Color3.fromRGB(70, 45, 63), 1)

    -- Large pet artwork fills the card, matching the reference inventory grid.
    local icon = make("ImageLabel", {
        Name = "PetThumbnail", Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
        BorderSizePixel = 0, Image = pet.image or "", ScaleType = Enum.ScaleType.Fit,
    }, card)
    if not pet.image or pet.image == "" then
        make("TextLabel", {
            BackgroundTransparency = 1, Size = UDim2.fromScale(1, 0.72),
            Text = "NO IMAGE", TextColor3 = muted, TextSize = 11, Font = Enum.Font.GothamBold,
        }, card)
    end

    -- Mutation labels sit over the top of the pet image in yellow.
    local mutationText = tostring(pet.mutations or "")
    make("TextLabel", {
        Name = "MutationLabel", BackgroundTransparency = 1,
        Position = UDim2.new(0, 3, 0, 3), Size = UDim2.new(1, -6, 0, 18),
        Font = Enum.Font.GothamBold, Text = mutationText,
        TextColor3 = gold, TextSize = 10, TextWrapped = false,
        TextStrokeColor3 = Color3.new(0, 0, 0), TextStrokeTransparency = 0.25,
        TextXAlignment = Enum.TextXAlignment.Center, TextYAlignment = Enum.TextYAlignment.Top,
    }, card)

    -- Pet name and weight remain on the image, just above the green income line.
    make("TextLabel", {
        Name = "PetName", BackgroundColor3 = Color3.fromRGB(12, 9, 14),
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 3, 1, -57), Size = UDim2.new(1, -6, 0, 18),
        Font = Enum.Font.GothamBold, Text = pet.name,
        TextColor3 = Color3.new(1, 1, 1), TextSize = 11,
        TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd,
        TextStrokeColor3 = Color3.new(0, 0, 0), TextStrokeTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, card)
    make("TextLabel", {
        Name = "WeightLabel", BackgroundColor3 = Color3.fromRGB(12, 9, 14),
        BackgroundTransparency = 0.3,
        Position = UDim2.new(0, 3, 1, -39), Size = UDim2.new(1, -6, 0, 15),
        Font = Enum.Font.GothamBold,
        Text = formatInteger(pet.weight) .. " Kg",
        TextColor3 = Color3.fromRGB(255, 218, 70), TextSize = 11, TextTruncate = Enum.TextTruncate.AtEnd,
        TextStrokeColor3 = Color3.new(0, 0, 0), TextStrokeTransparency = 0.2,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, card)

    -- Green compact rate at the bottom of each pet image.
    local rateLabel = make("TextLabel", {
        Name = "RateLabel", BackgroundColor3 = Color3.fromRGB(9, 28, 7),
        BackgroundTransparency = 0.18,
        Position = UDim2.new(0, 2, 1, -24), Size = UDim2.new(1, -4, 0, 22),
        Font = Enum.Font.GothamBlack, Text = "$" .. formatCompact(pet.rate, 1) .. "/s",
        TextColor3 = Color3.fromRGB(55, 255, 35), TextSize = 17,
        TextStrokeColor3 = Color3.fromRGB(0, 0, 0), TextStrokeTransparency = 0,
        TextScaled = true, TextWrapped = false,
        TextXAlignment = Enum.TextXAlignment.Center,
    }, card)

    local mark = make("TextLabel", {
        Name = "SelectedMark", BackgroundColor3 = purple,
        Position = UDim2.new(1, -22, 0, 4), Size = UDim2.fromOffset(18, 18),
        Text = "✓", TextColor3 = Color3.new(1,1,1), TextSize = 13,
        Font = Enum.Font.GothamBold, Visible = false, BorderSizePixel = 0,
    }, card)
    corner(mark, 10)

    card.MouseButton1Click:Connect(function()
        if selectedCard and selectedCard ~= card then
            selectedCard.BackgroundColor3 = Color3.fromRGB(28, 20, 31)
            selectedCard:FindFirstChild("SelectedMark").Visible = false
        end
        if selectedCard == card then
            selectedCard = nil
            mark.Visible = false
            card.BackgroundColor3 = Color3.fromRGB(28, 20, 31)
        else
            selectedCard = card
            mark.Visible = true
            card.BackgroundColor3 = Color3.fromRGB(75, 48, 103)
        end
        selectedCount = selectedCard and 1 or 0
        giftButton.Text = "GIFT (" .. selectedCount .. ")"
    end)
    cards[#cards + 1] = {card = card, pet = pet}
end

for i, pet in ipairs(pets) do makeCard(pet, i) end

local function applySearch()
    local query = string.lower(search.Text or "")
    for _, entry in ipairs(cards) do
        entry.card.Visible = query == "" or string.find(string.lower(entry.pet.name), query, 1, true) ~= nil
    end
end
search:GetPropertyChangedSignal("Text"):Connect(applySearch)

giftButton.MouseButton1Click:Connect(function()
    if not selectedCard then
        status.Text = "Select one Divine pet first."
        return
    end
    local name = recipient.Text
    if name == "" then name = "@username" end
    status.Text = "Gift Success! " .. name
    status.TextColor3 = Color3.fromRGB(100, 255, 105)
end)

-- Drag window by the top bar.
local dragging, dragInput, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
top.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

if inventoryError then
    warn("[NhatKhanh Gift Pet] " .. inventoryError)
elseif #pets == 0 then
    status.Text = "No Divine pets found in readable inventory."
end

print("NhatKhanh Gift Pet UI loaded. Cards are local display clones; no game gift transaction is performed.")
