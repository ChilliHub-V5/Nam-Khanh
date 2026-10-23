-- Nhat Khanh | Steal An Egg
-- Inventory additions use the game Save module on the client. They are local-only and are not server-authorized.
-- Scale input is restricted to 1x-30x per the requested game limit.
-- Weight and earnings use the game's own utility functions when available.
-- Names are dynamically filtered from Data.Assets.Directory to Eternal/Divine only.
-- Display scale uses the source hub scale mapping.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local old = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("NhatKhanh_StealEgg")
if old then old:Destroy() end

local visualFolder = Workspace:FindFirstChild("__NhatKhanhStealEgg")
if visualFolder then visualFolder:Destroy() end
visualFolder = Instance.new("Folder")
visualFolder.Name = "__NhatKhanhStealEgg"
visualFolder.Parent = Workspace

local function safeRequire(path)
 local ok, result = pcall(require, path)
 if ok then return result end
 return nil
end

-- Do not WaitForChild() on optional game modules before creating the GUI:
-- if the game's folder names differ, WaitForChild can yield forever and no GUI appears.
local dataFolder = ReplicatedStorage:FindFirstChild("Data")
local assetsModule = dataFolder and dataFolder:FindFirstChild("Assets")
local AssetsData = assetsModule and safeRequire(assetsModule) or nil
local Directory = AssetsData and (AssetsData.Directory or AssetsData) or {}

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local saveModule = sharedFolder and sharedFolder:FindFirstChild("Save")
local SaveData = saveModule and safeRequire(saveModule) or nil

local function makeInventoryId(kind)
 return "NKVIS_" .. kind .. "_" .. tostring(math.floor(os.clock() * 1000)) .. "_" .. tostring(math.random(1, 1000000))
end

local function addSelectedToInventory(kind, category, scale)
 if not SaveData or type(SaveData.Amend) ~= "function" or not Directory[category] then
  return false, "Could not load game Save/Assets."
 end

 local uid = makeInventoryId(kind)
 local ok = pcall(function()
  if kind == "Egg" then
   SaveData.Amend("EggInventory", function(inventory)
    inventory[uid] = {
     AssetCategory = category,
     AssetScale = tonumber(scale) or 1,
     AssetColorIndex = 1,
     AssetColorSeed = math.random(1, 2000000000),
     AssetEyeColor = "ffffff",
     HasParasite = false,
     Mutations = {}
    }
   end)
  else
   local petScale = math.clamp(1 + (tonumber(scale) or 1) / 25, 1.2, 5)
   SaveData.Amend("Inventory", function(inventory)
    inventory[uid] = {
     Category = category,
     Scale = petScale,
     ColorIndex = 1,
     ColorSeed = math.random(1, 2000000000),
     EyeColor = "ffffff",
     Gender = "Male",
     Personality = "Normal",
     InFuse = false,
     HasBeenFirstPlaced = false,
     Mutations = {}
    }
   end)
  end
 end)

 if not ok then
  return false, "The game rejected the local Save update."
 end
 return true, uid
end

local ALLOWED_RARITIES = { Eternal = true, Divine = true }
local selectedRarity = "Divine"

local function getRarity(data)
 local rarity = type(data) == "table" and data.Rarity
 if type(rarity) ~= "table" then return nil end
 return rarity.DisplayName or rarity._id
end

local function getModelFolder(kind)
 if kind == "Egg" then
 local assets = ReplicatedStorage:FindFirstChild("Assets")
 local models = assets and assets:FindFirstChild("Models")
 return models and models:FindFirstChild("Eggs")
 end
 return ReplicatedStorage:FindFirstChild("AssetModels")
end

local function getModel(kind, name)
 local folder = getModelFolder(kind)
 return folder and folder:FindFirstChild(name) or nil
end

local function refreshNames(kind)
 local names = {}
 local folder = getModelFolder(kind)
 if not folder then return names end

 for category, data in pairs(Directory) do
 if type(category) == "string"
 and type(data) == "table"
 and ALLOWED_RARITIES[getRarity(data)]
 and getRarity(data) == selectedRarity
 and folder:FindFirstChild(category)
 and (kind ~= "Egg" or data.Egg ~= nil) then
 table.insert(names, category)
 end
 end

 table.sort(names)
 return names
end
local UserInputService = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui")
gui.Name = "NhatKhanh_StealEgg"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

if not AssetsData then
 warn("[Nhat Khanh] KhÃ´ng tÃ¬m tháº¥y ReplicatedStorage.Data.Assets; GUI váº«n ÄÆ°á»£c táº¡o nhÆ°ng danh sÃ¡ch cÃ³ thá» trá»ng.")
end
if not SaveData then
 warn("[Nhat Khanh] KhÃ´ng tÃ¬m tháº¥y Shared.Save; chá»©c nÄng thÃªm vÃ o inventory sáº½ khÃ´ng hoáº¡t Äá»ng.")
end

-- Chinese period-drama inspired palette: dark lacquer, jade, vermilion and antique gold.
local C = {
 lacquer = Color3.fromRGB(35, 25, 24),
 panel = Color3.fromRGB(48, 33, 29),
 inset = Color3.fromRGB(67, 44, 35),
 vermilion = Color3.fromRGB(145, 45, 37),
 jade = Color3.fromRGB(74, 126, 103),
 gold = Color3.fromRGB(218, 177, 95),
 ivory = Color3.fromRGB(246, 229, 190),
 muted = Color3.fromRGB(201, 180, 147),
}

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(320, 530)
frame.Position = UDim2.new(0.5, -160, 0.5, -265)
frame.BackgroundColor3 = C.lacquer
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = C.gold
stroke.Thickness = 1.5
stroke.Parent = frame

local topBar = Instance.new("Frame")
topBar.Name = "DragBar"
topBar.Position = UDim2.fromOffset(0, 0)
topBar.Size = UDim2.new(1, 0, 0, 38)
topBar.BackgroundColor3 = C.vermilion
topBar.BorderSizePixel = 0
topBar.Parent = frame
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local barCover = Instance.new("Frame")
barCover.Position = UDim2.new(0, 0, 1, -10)
barCover.Size = UDim2.new(1, 0, 0, 10)
barCover.BackgroundColor3 = C.vermilion
barCover.BorderSizePixel = 0
barCover.Parent = topBar

local mini = Instance.new("TextButton")
mini.Name = "WatermelonMini"
mini.Size = UDim2.fromOffset(52, 52)
mini.Position = UDim2.new(0, 16, 0.5, -26)
mini.BackgroundColor3 = Color3.fromRGB(48, 105, 63)
mini.Text = "ð"
mini.TextSize = 27
mini.Font = Enum.Font.GothamBold
mini.TextColor3 = C.ivory
mini.Visible = false
mini.AutoButtonColor = true
mini.Parent = gui
mini.ZIndex = 20
Instance.new("UICorner", mini).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke")
miniStroke.Color = C.gold
miniStroke.Thickness = 2
miniStroke.Parent = mini

local function makeDraggable(object, handle, onClick)
 local dragging = false
 local dragInput, startInput, startPosition
 local moved = false
 local clickStart

 handle.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 clickStart = input.Position
 startInput = input.Position
 startPosition = object.Position
 dragInput = input
 end
 end)

 handle.InputChanged:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseMovement
 or input.UserInputType == Enum.UserInputType.Touch then
 dragInput = input
 end
 end)

 UserInputService.InputChanged:Connect(function(input)
 if not dragging then return end
 if input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement then
 local delta = input.Position - startInput
 if math.abs(delta.X) + math.abs(delta.Y) > 6 then
 moved = true
 if object == mini then mini:SetAttribute("WasDragged", true) end
 end
 object.Position = UDim2.new(
 startPosition.X.Scale, startPosition.X.Offset + delta.X,
 startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
 )
 end
 end)

 handle.InputEnded:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1
 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = false
 if onClick and not moved then onClick() end
 end
 end)
end

makeDraggable(frame, topBar)
makeDraggable(mini, mini, function()
 if not mini:GetAttribute("WasDragged") then
 frame.Visible = true
 mini.Visible = false
 end
 mini:SetAttribute("WasDragged", false)
end)

local function label(text, pos, size, fontSize, color)
 local l = Instance.new("TextLabel")
 l.BackgroundTransparency = 1
 l.Position = pos
 l.Size = size
 l.Font = Enum.Font.GothamSemibold
 l.TextSize = fontSize
 l.TextColor3 = color or C.ivory
 l.TextXAlignment = Enum.TextXAlignment.Left
 l.Text = text
 l.Parent = frame
 return l
end

label("NHAT KHANH | DISPLAY", UDim2.fromOffset(14, 10), UDim2.new(1, -50, 0, 24), 14, C.gold)
local subtitle = label("ç Â· JADE COURT", UDim2.fromOffset(14, 33), UDim2.new(1, -50, 0, 15), 8, C.ivory)
subtitle.TextTransparency = 0.12

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 26)
close.Position = UDim2.new(1, -36, 0, 8)
close.BackgroundColor3 = C.vermilion
close.Text = "â"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function()
 frame.Visible = false
 mini.Visible = true
end)

label("RARITY", UDim2.fromOffset(14, 43), UDim2.fromOffset(100, 20), 12, C.muted)

local divineCategory = Instance.new("TextButton")
divineCategory.Position = UDim2.fromOffset(14, 65)
divineCategory.Size = UDim2.fromOffset(140, 30)
divineCategory.BackgroundColor3 = C.jade
divineCategory.TextColor3 = C.ivory
divineCategory.Font = Enum.Font.GothamBold
divineCategory.TextSize = 12
divineCategory.Text = "DIVINE"
divineCategory.Parent = frame
Instance.new("UICorner", divineCategory).CornerRadius = UDim.new(0, 6)

local eternalCategory = Instance.new("TextButton")
eternalCategory.Position = UDim2.fromOffset(164, 65)
eternalCategory.Size = UDim2.fromOffset(140, 30)
eternalCategory.BackgroundColor3 = C.inset
eternalCategory.TextColor3 = C.ivory
eternalCategory.Font = Enum.Font.GothamBold
eternalCategory.TextSize = 12
eternalCategory.Text = "ETERNAL"
eternalCategory.Parent = frame
Instance.new("UICorner", eternalCategory).CornerRadius = UDim.new(0, 6)

label("TYPE", UDim2.fromOffset(14, 99), UDim2.fromOffset(100, 20), 11, C.muted)
local eggCategory = Instance.new("TextButton")
eggCategory.Position = UDim2.fromOffset(14, 120)
eggCategory.Size = UDim2.fromOffset(140, 28)
eggCategory.BackgroundColor3 = C.jade
eggCategory.TextColor3 = C.ivory
eggCategory.Font = Enum.Font.GothamBold
eggCategory.TextSize = 11
eggCategory.Text = "EGG"
eggCategory.Parent = frame
Instance.new("UICorner", eggCategory).CornerRadius = UDim.new(0, 6)

local petCategory = Instance.new("TextButton")
petCategory.Position = UDim2.fromOffset(164, 120)
petCategory.Size = UDim2.fromOffset(140, 28)
petCategory.BackgroundColor3 = C.inset
petCategory.TextColor3 = C.ivory
petCategory.Font = Enum.Font.GothamBold
petCategory.TextSize = 11
petCategory.Text = "PET"
petCategory.Parent = frame
Instance.new("UICorner", petCategory).CornerRadius = UDim.new(0, 6)

label("SELECT NAME", UDim2.fromOffset(14, 151), UDim2.new(1, -28, 0, 18), 11, C.muted)

local nameList = Instance.new("ScrollingFrame")
nameList.Name = "NameList"
nameList.Position = UDim2.fromOffset(14, 171)
nameList.Size = UDim2.new(1, -28, 0, 104)
nameList.BackgroundColor3 = C.inset
nameList.BorderSizePixel = 0
nameList.ScrollBarThickness = 5
nameList.ScrollBarImageColor3 = C.gold
nameList.CanvasSize = UDim2.new(0, 0, 0, 0)
nameList.AutomaticCanvasSize = Enum.AutomaticSize.Y
nameList.ScrollingDirection = Enum.ScrollingDirection.Y
nameList.Parent = frame
Instance.new("UICorner", nameList).CornerRadius = UDim.new(0, 6)

local nameListLayout = Instance.new("UIListLayout")
nameListLayout.Padding = UDim.new(0, 3)
nameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
nameListLayout.Parent = nameList

local nameListPadding = Instance.new("UIPadding")
nameListPadding.PaddingTop = UDim.new(0, 4)
nameListPadding.PaddingBottom = UDim.new(0, 4)
nameListPadding.PaddingLeft = UDim.new(0, 4)
nameListPadding.PaddingRight = UDim.new(0, 4)
nameListPadding.Parent = nameList

label("Scale: 1x-30x (20x=5x size, 30x=7.5x size)", UDim2.fromOffset(14, 278), UDim2.new(1, -28, 0, 20), 10, C.muted)
local scaleBox = Instance.new("TextBox")
scaleBox.Position = UDim2.fromOffset(14, 300)
scaleBox.Size = UDim2.fromOffset(140, 30)
scaleBox.BackgroundColor3 = C.inset
scaleBox.TextColor3 = C.ivory
scaleBox.Text = "1"
scaleBox.ClearTextOnFocus = false
scaleBox.Font = Enum.Font.Gotham
scaleBox.TextSize = 12
scaleBox.Parent = frame
Instance.new("UICorner", scaleBox).CornerRadius = UDim.new(0, 6)

local spawn = Instance.new("TextButton")
spawn.Position = UDim2.fromOffset(164, 300)
spawn.Size = UDim2.fromOffset(140, 30)
spawn.BackgroundColor3 = C.jade
spawn.TextColor3 = Color3.new(1,1,1)
spawn.Text = "SHOW MODEL"
spawn.Font = Enum.Font.GothamBold
spawn.TextSize = 12
spawn.Parent = frame
Instance.new("UICorner", spawn).CornerRadius = UDim.new(0, 6)

local holdButton = Instance.new("TextButton")
holdButton.Position = UDim2.fromOffset(14, 338)
holdButton.Size = UDim2.fromOffset(290, 30)
holdButton.BackgroundColor3 = C.jade
holdButton.TextColor3 = Color3.new(1,1,1)
holdButton.Text = "HOLD / RELEASE LAST MODEL"
holdButton.Font = Enum.Font.GothamBold
holdButton.TextSize = 11
holdButton.Parent = frame
Instance.new("UICorner", holdButton).CornerRadius = UDim.new(0, 6)

local addToBag = Instance.new("TextButton")
addToBag.Position = UDim2.fromOffset(14, 376)
addToBag.Size = UDim2.fromOffset(290, 30)
addToBag.BackgroundColor3 = C.gold
addToBag.TextColor3 = C.lacquer
addToBag.Text = "ADD TO LOCAL BAG"
addToBag.Font = Enum.Font.GothamBold
addToBag.TextSize = 11
addToBag.Parent = frame
Instance.new("UICorner", addToBag).CornerRadius = UDim.new(0, 6)

local clear = Instance.new("TextButton")
clear.Position = UDim2.fromOffset(14, 414)
clear.Size = UDim2.fromOffset(290, 30)
clear.BackgroundColor3 = C.vermilion
clear.TextColor3 = Color3.new(1,1,1)
clear.Text = "CLEAR DISPLAYED MODELS"
clear.Font = Enum.Font.GothamBold
clear.TextSize = 12
clear.Parent = frame
Instance.new("UICorner", clear).CornerRadius = UDim.new(0, 6)

local status = label("Ready.", UDim2.fromOffset(14, 452), UDim2.new(1, -28, 0, 60), 10, C.muted)
status.TextWrapped = true
status.TextYAlignment = Enum.TextYAlignment.Top

local kind = "Egg"
local selectedIndex = { Egg = 1, Pet = 1 }
local selectedName = { Egg = nil, Pet = nil }
local updateNameList
local function clearNameButtons()
    for _, child in ipairs(nameList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

local function updateCategoryColors()
    eggCategory.BackgroundColor3 = kind == "Egg" and C.jade or C.inset
    petCategory.BackgroundColor3 = kind == "Pet" and C.jade or C.inset
    divineCategory.BackgroundColor3 = selectedRarity == "Divine" and C.jade or C.inset
    eternalCategory.BackgroundColor3 = selectedRarity == "Eternal" and C.jade or C.inset
end

divineCategory.MouseButton1Click:Connect(function()
    selectedRarity = "Divine"
    updateCategoryColors()
    updateNameList()
end)

eternalCategory.MouseButton1Click:Connect(function()
    selectedRarity = "Eternal"
    updateCategoryColors()
    updateNameList()
end)

updateNameList = function()
    clearNameButtons()
    local names = refreshNames(kind)
    if #names == 0 then
        local empty = Instance.new("TextLabel")
        empty.BackgroundTransparency = 1
        empty.Size = UDim2.new(1, -8, 0, 28)
        empty.Text = "No Eternal/Divine models found"
        empty.TextColor3 = C.ivory
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 11
        empty.Parent = nameList
        selectedName[kind] = nil
        return
    end

    selectedIndex[kind] = math.clamp(selectedIndex[kind] or 1, 1, #names)
    if not selectedName[kind] or not table.find(names, selectedName[kind]) then
        selectedName[kind] = names[selectedIndex[kind]]
    end

    for i, name in ipairs(names) do
        local item = Instance.new("TextButton")
        item.Name = "Item_" .. name
        item.LayoutOrder = i
        item.Size = UDim2.new(1, -4, 0, 27)
        item.BackgroundColor3 = name == selectedName[kind] and C.vermilion or C.panel
        item.TextColor3 = C.ivory
        item.Text = name
        item.TextSize = 11
        item.Font = Enum.Font.GothamSemibold
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.TextTruncate = Enum.TextTruncate.AtEnd
        item.Parent = nameList
        Instance.new("UICorner", item).CornerRadius = UDim.new(0, 4)
        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 8)
        pad.Parent = item
        item.MouseButton1Click:Connect(function()
            selectedName[kind] = name
            selectedIndex[kind] = i
            updateNameList()
        end)
    end
    nameList.CanvasPosition = Vector2.new(0, 0)
end

eggCategory.MouseButton1Click:Connect(function()
    kind = "Egg"
    updateCategoryColors()
    updateNameList()
end)

petCategory.MouseButton1Click:Connect(function()
    kind = "Pet"
    updateCategoryColors()
    updateNameList()
end)

updateCategoryColors()
updateNameList()

addToBag.MouseButton1Click:Connect(function()
    local name = selectedName[kind]
    local scale = tonumber(scaleBox.Text)
    if not name then
        status.Text = "Select an Egg/Pet first."
        return
    end
    if not scale or scale < 1 or scale > 30 then
        status.Text = "Scale must be between 1x and 30x."
        return
    end
    local ok, result = addSelectedToInventory(kind, name, scale)
    if ok then
        status.Text = "Added a local-only inventory preview for " .. name .. ". The server may not save it."
    else
        status.Text = tostring(result)
    end
end)

local function anchorModel(model)
 for _, obj in ipairs(model:GetDescendants()) do
 if obj:IsA("BasePart") then
 obj.Anchored = true
 obj.CanCollide = false
 obj.CanTouch = false
 obj.CanQuery = false
 end
 end
end

local displayedSpecs = {}
local modelStates = {}
local heldModel = nil
local heldOffset = CFrame.new(0.9, -0.45, -0.7) * CFrame.Angles(0, math.rad(90), math.rad(12))

-- Client-only motion: pets gently bob and turn; held models follow the player's hand.
RunService.RenderStepped:Connect(function(dt)
    local now = os.clock()
    local character = LocalPlayer.Character
    local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm") or character:FindFirstChild("RightLowerArm"))
    for model, state in pairs(modelStates) do
        if not model or not model.Parent then
            modelStates[model] = nil
        elseif model == heldModel and hand then
            local target = hand.CFrame * heldOffset
            pcall(function() model:PivotTo(target) end)
        elseif state.kind == "Pet" then
            local bob = math.sin(now * 2.6 + state.phase) * 0.28
            local yaw = now * 0.55 + state.phase
            pcall(function()
                model:PivotTo(state.baseCFrame * CFrame.new(0, bob, 0) * CFrame.Angles(0, yaw, 0))
            end)
        end
    end
end)

local function addSparkles(model)
    -- Bright local glow plus multiple emitters so the effect surrounds the whole model.
    local highlight = Instance.new("Highlight")
    highlight.Name = "NhatKhanhGlow"
    highlight.Adornee = model
    highlight.FillColor = Color3.fromRGB(255, 224, 126)
    highlight.OutlineColor = Color3.fromRGB(255, 248, 207)
    highlight.FillTransparency = 0.78
    highlight.OutlineTransparency = 0.12
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    local parts = {}
    for _, obj in ipairs(model:GetDescendants()) do
        if obj:IsA("BasePart") then table.insert(parts, obj) end
    end
    if #parts == 0 then return end

    local rootPart = model.PrimaryPart or parts[1]
    local light = Instance.new("PointLight")
    light.Name = "NhatKhanhEggGlow"
    light.Color = Color3.fromRGB(255, 226, 145)
    light.Brightness = 1.8
    light.Range = 18
    light.Shadows = false
    light.Parent = rootPart

    for index, part in ipairs(parts) do
        if index <= 8 then
            local emitter = Instance.new("ParticleEmitter")
            emitter.Name = "NhatKhanhSparkles"
            emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
            emitter.Rate = 9
            emitter.Lifetime = NumberRange.new(0.65, 1.5)
            emitter.Speed = NumberRange.new(0.15, 0.8)
            emitter.SpreadAngle = Vector2.new(180, 180)
            emitter.LightEmission = 1
            emitter.Rotation = NumberRange.new(0, 360)
            emitter.RotSpeed = NumberRange.new(-110, 110)
            emitter.Color = ColorSequence.new(
                Color3.fromRGB(255, 244, 183),
                Color3.fromRGB(255, 255, 255)
            )
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.18),
                NumberSequenceKeypoint.new(0.4, 0.42),
                NumberSequenceKeypoint.new(1, 0)
            })
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.05),
                NumberSequenceKeypoint.new(0.75, 0.18),
                NumberSequenceKeypoint.new(1, 1)
            })
            emitter.Parent = part
        end
    end
end

local function showModel(kindToShow, name, scale, remember)
    local sourceModel = getModel(kindToShow, name)
    if not sourceModel or not sourceModel:IsA("Model") then
        return false, "Model not found: " .. tostring(name)
    end
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return false, "Character not found." end

    local ok, model = pcall(function() return sourceModel:Clone() end)
    if not ok or not model then return false, "Could not clone this model." end

    anchorModel(model)
    model.Name = "_" .. name .. "_" .. tostring(#visualFolder:GetChildren() + 1)
    model.Parent = visualFolder

    -- 20x -> 5x model size; 30x -> 7.5x model size.
    local scaleFactor = math.max(1, scale / 4)
    local okPosition = pcall(function()
        model:ScaleTo(scaleFactor)
        -- Place in front of the player using a downward ray that accepts only floor-like surfaces.
        -- This avoids wall/base decorations moving the model to a bad height.
        local targetPosition = (root.CFrame * CFrame.new(0, 0, -7)).Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {character, model, visualFolder}
        local rayOrigin = Vector3.new(targetPosition.X, root.Position.Y + 80, targetPosition.Z)
        local hit = Workspace:Raycast(rayOrigin, Vector3.new(0, -250, 0), rayParams)
        local groundY = root.Position.Y - 3
        if hit and hit.Normal.Y > 0.5 then
            groundY = hit.Position.Y
        end
        local pivotBefore = model:GetPivot()
        local boxCF, boxSize = model:GetBoundingBox()
        local pivotToBox = pivotBefore:ToObjectSpace(boxCF)
        local targetBox = CFrame.new(
            targetPosition.X,
            groundY + boxSize.Y * 0.5 + 0.05,
            targetPosition.Z
        )
        model:PivotTo(targetBox * pivotToBox:Inverse())
    end)

    if not okPosition then
        model:Destroy()
        return false, "Could not scale or position the model."
    end

    addSparkles(model)
    modelStates[model] = {
        kind = kindToShow,
        phase = math.random() * math.pi * 2,
        baseCFrame = model:GetPivot()
    }
    if remember then
        table.insert(displayedSpecs, {
            kind = kindToShow,
            name = name,
            scale = scale
        })
    end
    return true
end

spawn.MouseButton1Click:Connect(function()
    local name = selectedName[kind]
    local scale = tonumber(scaleBox.Text)
    if not name then
        status.Text = "Select a name from the list first."
        return
    end
    if not scale or scale < 1 or scale > 30 then
        status.Text = "Scale must be between 1x and 30x."
        return
    end
    local ok, err = showModel(kind, name, scale, true)
    if ok then
        status.Text = "Displayed " .. name .. " | scale " .. scale .. "x | sparkle effect enabled."
    else
        status.Text = tostring(err)
    end
end)

holdButton.MouseButton1Click:Connect(function()
    if heldModel and heldModel.Parent then
        modelStates[heldModel] = nil
        heldModel = nil
        holdButton.Text = "HOLD / RELEASE LAST MODEL"
        status.Text = "Released model; local display remains in front of you."
        return
    end
    local children = visualFolder:GetChildren()
    local lastModel = nil
    for i = #children, 1, -1 do
        if children[i]:IsA("Model") then
            lastModel = children[i]
            break
        end
    end
    if not lastModel then
        status.Text = "Show an Egg/Pet model first."
        return
    end
    heldModel = lastModel
    modelStates[heldModel] = modelStates[heldModel] or {
        kind = kind, phase = math.random() * math.pi * 2,
        baseCFrame = heldModel:GetPivot()
    }
    holdButton.Text = "RELEASE HELD MODEL"
    status.Text = "Holding last model locally. This is visual only."
end)

clear.MouseButton1Click:Connect(function()
    heldModel = nil
    holdButton.Text = "HOLD / RELEASE LAST MODEL"
    for _, obj in ipairs(visualFolder:GetChildren()) do
        modelStates[obj] = nil
        obj:Destroy()
    end
    table.clear(displayedSpecs)
    status.Text = "Cleared all displayed Egg/Pet models."
end)

-- Recreate local display models after character respawn/round reset in the same session.
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    if not visualFolder or not visualFolder.Parent then
        visualFolder = Instance.new("Folder")
        visualFolder.Name = "__NhatKhanhStealEgg"
        visualFolder.Parent = Workspace
    end
    local saved = table.clone(displayedSpecs)
    heldModel = nil
    holdButton.Text = "HOLD / RELEASE LAST MODEL"
    for _, existing in ipairs(visualFolder:GetChildren()) do
        modelStates[existing] = nil
        existing:Destroy()
    end
    for _, spec in ipairs(saved) do
        showModel(spec.kind, spec.name, spec.scale, false)
        task.wait(0.1)
    end
end)
