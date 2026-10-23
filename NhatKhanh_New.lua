-- NhatKhanh.lua - fresh standalone local display GUI
-- Local-only visual models. This does not create server-owned inventory items.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
if not player then
    warn("[NhatKhanh] LocalPlayer not found. Run this as a client LocalScript.")
    return
end

local playerGui = player:WaitForChild("PlayerGui")
local oldGui = playerGui:FindFirstChild("NhatKhanh_Display_V2")
if oldGui then oldGui:Destroy() end

local oldModels = Workspace:FindFirstChild("NhatKhanh_LocalModels")
if oldModels then oldModels:Destroy() end
local modelFolder = Instance.new("Folder")
modelFolder.Name = "NhatKhanh_LocalModels"
modelFolder.Parent = Workspace

local function safeRequire(obj)
    if not obj then return nil end
    local ok, value = pcall(require, obj)
    if ok then return value end
    return nil
end

-- Resolve common asset directory locations without blocking GUI creation.
local assetDirectory = {}
local data = ReplicatedStorage:FindFirstChild("Data")
local assetsModule = data and data:FindFirstChild("Assets")
local assetsData = safeRequire(assetsModule)
if type(assetsData) == "table" then
    assetDirectory = assetsData.Directory or assetsData
end

local function rarityOf(entry)
    if type(entry) ~= "table" then return "" end
    local rarity = entry.Rarity
    if type(rarity) == "table" then
        return tostring(rarity.DisplayName or rarity._id or "")
    end
    return tostring(rarity or "")
end

local function getNames(rarity, kind)
    local result = {}
    for name, entry in pairs(assetDirectory) do
        if type(name) == "string" and type(entry) == "table"
            and rarityOf(entry):lower() == rarity:lower() then
            table.insert(result, name)
        end
    end
    table.sort(result)
    return result
end

local gui = Instance.new("ScreenGui")
gui.Name = "NhatKhanh_Display_V2"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local theme = {
    bg = Color3.fromRGB(35, 25, 24),
    panel = Color3.fromRGB(54, 38, 32),
    inset = Color3.fromRGB(72, 50, 41),
    red = Color3.fromRGB(150, 48, 38),
    green = Color3.fromRGB(65, 125, 85),
    gold = Color3.fromRGB(224, 184, 101),
    text = Color3.fromRGB(250, 235, 207),
    muted = Color3.fromRGB(205, 186, 157),
}

local frame = Instance.new("Frame")
frame.Name = "Main"
frame.Size = UDim2.fromOffset(330, 455)
frame.Position = UDim2.new(0.5, -165, 0.5, -227)
frame.BackgroundColor3 = theme.bg
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local frameStroke = Instance.new("UIStroke")
frameStroke.Color = theme.gold
frameStroke.Thickness = 1.5
frameStroke.Parent = frame

local header = Instance.new("TextButton")
header.Name = "DragHeader"
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = theme.red
header.BorderSizePixel = 0
header.Text = "NHAT KHANH | HIỂN THỊ CỤC BỘ"
header.TextColor3 = theme.text
header.TextSize = 13
header.Font = Enum.Font.GothamBold
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local function makeLabel(text, position, size, parent, fontSize, color)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Text = text
    label.TextColor3 = color or theme.text
    label.TextSize = fontSize or 12
    label.Font = Enum.Font.GothamSemibold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function makeButton(text, position, size, parent, color)
    local button = Instance.new("TextButton")
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = color or theme.inset
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = theme.text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = parent
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 7)
    return button
end

makeLabel("Loại mô hình", UDim2.fromOffset(14, 50), UDim2.fromOffset(120, 20), frame, 12, theme.muted)
local eggButton = makeButton("TRỨNG", UDim2.fromOffset(14, 73), UDim2.fromOffset(146, 32), frame, theme.green)
local petButton = makeButton("PET", UDim2.fromOffset(170, 73), UDim2.fromOffset(146, 32), frame)

makeLabel("Độ hiếm (lọc danh sách tên)", UDim2.fromOffset(14, 113), UDim2.fromOffset(240, 20), frame, 12, theme.muted)
local divineButton = makeButton("DIVINE", UDim2.fromOffset(14, 136), UDim2.fromOffset(146, 32), frame, theme.red)
local eternalButton = makeButton("ETERNAL", UDim2.fromOffset(170, 136), UDim2.fromOffset(146, 32), frame)

makeLabel("Danh sách tên (cuộn để xem)", UDim2.fromOffset(14, 176), UDim2.fromOffset(260, 20), frame, 12, theme.muted)
local list = Instance.new("ScrollingFrame")
list.Name = "NameList"
list.Position = UDim2.fromOffset(14, 199)
list.Size = UDim2.fromOffset(302, 115)
list.BackgroundColor3 = theme.panel
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollingDirection = Enum.ScrollingDirection.Y
list.Parent = frame
Instance.new("UICorner", list).CornerRadius = UDim.new(0, 7)
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 4)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list
local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 5)
listPadding.PaddingBottom = UDim.new(0, 5)
listPadding.PaddingLeft = UDim.new(0, 5)
listPadding.PaddingRight = UDim.new(0, 5)
listPadding.Parent = list

makeLabel("Scale (1x–30x)", UDim2.fromOffset(14, 322), UDim2.fromOffset(120, 20), frame, 12, theme.muted)
local scaleBox = Instance.new("TextBox")
scaleBox.Position = UDim2.fromOffset(14, 344)
scaleBox.Size = UDim2.fromOffset(85, 31)
scaleBox.BackgroundColor3 = theme.inset
scaleBox.BorderSizePixel = 0
scaleBox.Text = "1"
scaleBox.TextColor3 = theme.text
scaleBox.TextSize = 13
scaleBox.Font = Enum.Font.Gotham
scaleBox.ClearTextOnFocus = false
scaleBox.Parent = frame
Instance.new("UICorner", scaleBox).CornerRadius = UDim.new(0, 7)

local showButton = makeButton("HIỂN THỊ PHÍA TRƯỚC", UDim2.fromOffset(108, 344), UDim2.fromOffset(208, 31), frame, theme.green)
local holdButton = makeButton("CẦM MÔ HÌNH TRÊN TAY", UDim2.fromOffset(14, 383), UDim2.fromOffset(302, 30), frame)
local clearButton = makeButton("XÓA TẤT CẢ MÔ HÌNH", UDim2.fromOffset(14, 420), UDim2.fromOffset(302, 26), frame, theme.red)
local status = makeLabel("Sẵn sàng. Mô hình chỉ hiển thị cục bộ.", UDim2.fromOffset(14, 447), UDim2.fromOffset(302, 18), frame, 9, theme.muted)

local kind = "Egg"
local rarity = "Divine"
local selectedName = nil
local displayed = {}
local heldModel = nil
local heldWeld = nil
local petMotion = {}

local function setStatus(message)
    status.Text = message
end

local function clearNameButtons()
    for _, child in ipairs(list:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
end

local function refreshList()
    clearNameButtons()
    selectedName = nil
    local names = getNames(rarity, kind)
    for i, name in ipairs(names) do
        local b = makeButton(name, UDim2.new(), UDim2.new(1, -4, 0, 27), list)
        b.LayoutOrder = i
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextTruncate = Enum.TextTruncate.AtEnd
        b.MouseButton1Click:Connect(function()
            selectedName = name
            for _, child in ipairs(list:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = child == b and theme.green or theme.inset
                end
            end
            setStatus("Đã chọn: " .. name)
        end)
    end
    if #names == 0 then
        local empty = Instance.new("TextLabel")
        empty.BackgroundTransparency = 1
        empty.Size = UDim2.new(1, -8, 0, 36)
        empty.Text = assetsData and "Không có tên phù hợp với độ hiếm này." or "Không đọc được danh mục game; GUI vẫn hoạt động."
        empty.TextColor3 = theme.muted
        empty.TextSize = 11
        empty.Font = Enum.Font.Gotham
        empty.Parent = list
    end
    setStatus("Danh sách " .. rarity:upper() .. " · " .. kind:upper() .. ": " .. #names .. " mục")
end

local function updateButtons()
    eggButton.BackgroundColor3 = kind == "Egg" and theme.green or theme.inset
    petButton.BackgroundColor3 = kind == "Pet" and theme.green or theme.inset
    divineButton.BackgroundColor3 = rarity == "Divine" and theme.red or theme.inset
    eternalButton.BackgroundColor3 = rarity == "Eternal" and theme.red or theme.inset
end

eggButton.MouseButton1Click:Connect(function()
    kind = "Egg"
    updateButtons()
    refreshList()
end)
petButton.MouseButton1Click:Connect(function()
    kind = "Pet"
    updateButtons()
    refreshList()
end)
divineButton.MouseButton1Click:Connect(function()
    rarity = "Divine"
    updateButtons()
    refreshList()
end)
eternalButton.MouseButton1Click:Connect(function()
    rarity = "Eternal"
    updateButtons()
    refreshList()
end)

local function findSourceModel(name, objectKind)
    local candidates = {}
    if objectKind == "Egg" then
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local models = assets and assets:FindFirstChild("Models")
        table.insert(candidates, models and models:FindFirstChild("Eggs"))
        local assetModels = ReplicatedStorage:FindFirstChild("AssetModels")
        table.insert(candidates, assetModels and assetModels:FindFirstChild("Eggs"))
    else
        table.insert(candidates, ReplicatedStorage:FindFirstChild("AssetModels"))
        local assets = ReplicatedStorage:FindFirstChild("Assets")
        local models = assets and assets:FindFirstChild("Models")
        table.insert(candidates, models and models:FindFirstChild("Pets"))
    end
    for _, folder in ipairs(candidates) do
        if folder then
            local found = folder:FindFirstChild(name, true)
            if found and (found:IsA("Model") or found:IsA("BasePart")) then
                return found
            end
        end
    end
    return nil
end

local function sparkle(model, objectKind)
    if objectKind ~= "Egg" then return end
    local parts = {}
    if model:IsA("BasePart") then
        table.insert(parts, model)
    else
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then table.insert(parts, d) end
        end
    end
    if #parts == 0 then return end
    local primary = parts[1]
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 232, 135)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 220)
    highlight.FillTransparency = 0.82
    highlight.OutlineTransparency = 0.12
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 231, 143)
    light.Brightness = 1.8
    light.Range = 12
    light.Parent = primary

    local attachment = Instance.new("Attachment")
    attachment.Parent = primary
    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "NhatKhanhSparkles"
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Rate = 16
    emitter.Lifetime = NumberRange.new(0.45, 1.1)
    emitter.Speed = NumberRange.new(0.4, 1.8)
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.LightEmission = 1
    emitter.Rotation = NumberRange.new(0, 360)
    emitter.RotSpeed = NumberRange.new(-90, 90)
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.18),
        NumberSequenceKeypoint.new(0.5, 0.11),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Parent = attachment
end

local function anchorModel(model, anchored)
    local parts = {}
    if model:IsA("BasePart") then
        table.insert(parts, model)
    else
        for _, d in ipairs(model:GetDescendants()) do
            if d:IsA("BasePart") then table.insert(parts, d) end
        end
    end
    for _, part in ipairs(parts) do
        part.Anchored = anchored
        part.CanCollide = false
        part.CanTouch = false
        part.CanQuery = false
    end
end

local function primaryPartOf(model)
    if model:IsA("BasePart") then return model end
    if model.PrimaryPart then return model.PrimaryPart end
    local p = model:FindFirstChildWhichIsA("BasePart", true)
    if p then model.PrimaryPart = p end
    return p
end

local function modelPivotTo(model, cf)
    if model:IsA("Model") then
        model:PivotTo(cf)
    else
        model.CFrame = cf
    end
end

local function getPivot(model)
    return model:IsA("Model") and model:GetPivot() or model.CFrame
end

local function scaleModel(model, factor)
    if model:IsA("Model") then
        pcall(function() model:ScaleTo(factor) end)
    else
        model.Size = model.Size * factor
    end
end

local function makeVisible()
    if not selectedName then
        setStatus("Hãy chọn một tên trong danh sách trước.")
        return
    end
    local scale = tonumber(scaleBox.Text)
    if not scale or scale < 1 or scale > 30 then
        setStatus("Scale phải từ 1x đến 30x.")
        return
    end
    local source = findSourceModel(selectedName, kind)
    if not source then
        setStatus("Không tìm thấy model trong thư mục game: " .. selectedName)
        return
    end

    local model = source:Clone()
    model.Name = "Local_" .. kind .. "_" .. selectedName
    model.Parent = modelFolder
    local factor = math.clamp(scale / 4, 0.25, 7.5)
    scaleModel(model, factor)
    anchorModel(model, true)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        model:Destroy()
        setStatus("Không tìm thấy nhân vật. Hãy hồi sinh rồi thử lại.")
        return
    end
    local cf = root.CFrame * CFrame.new(0, 1.5, -6)
    modelPivotTo(model, cf)
    sparkle(model, kind)
    table.insert(displayed, {model = model, kind = kind, name = selectedName})
    if kind == "Pet" then
        petMotion[model] = {start = os.clock(), base = cf}
    end
    setStatus(kind .. " hiển thị phía trước: " .. selectedName)
end

showButton.MouseButton1Click:Connect(makeVisible)

holdButton.MouseButton1Click:Connect(function()
    if heldModel and heldModel.Parent then
        anchorModel(heldModel, true)
        if heldWeld then heldWeld:Destroy() heldWeld = nil end
        heldModel = nil
        setStatus("Đã thả mô hình khỏi tay.")
        holdButton.Text = "CẦM MÔ HÌNH TRÊN TAY"
        return
    end
    local last = displayed[#displayed]
    if not last or not last.model or not last.model.Parent then
        setStatus("Hãy hiển thị một trứng hoặc pet trước.")
        return
    end
    local character = player.Character
    local hand = character and (character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm"))
    if not hand or not hand:IsA("BasePart") then
        setStatus("Không tìm thấy tay nhân vật.")
        return
    end
    local model = last.model
    local primary = primaryPartOf(model)
    if not primary then
        setStatus("Model này không có BasePart để cầm.")
        return
    end
    if heldWeld then heldWeld:Destroy() heldWeld = nil end
    anchorModel(model, false)
    modelPivotTo(model, hand.CFrame * CFrame.new(0, -0.5, -0.8))
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hand
    weld.Part1 = primary
    weld.Parent = primary
    heldWeld = weld
    heldModel = model
    petMotion[model] = nil
    holdButton.Text = "THẢ MÔ HÌNH"
    setStatus("Đang cầm mô hình cục bộ trên tay.")
end)

clearButton.MouseButton1Click:Connect(function()
    if heldWeld then heldWeld:Destroy() heldWeld = nil end
    heldModel = nil
    for _, item in ipairs(displayed) do
        if item.model and item.model.Parent then item.model:Destroy() end
    end
    table.clear(displayed)
    table.clear(petMotion)
    for _, child in ipairs(modelFolder:GetChildren()) do child:Destroy() end
    holdButton.Text = "CẦM MÔ HÌNH TRÊN TAY"
    setStatus("Đã xóa toàn bộ mô hình cục bộ.")
end)

-- Keep models in front of the character, including inside a base; pet models bob and turn.
RunService.RenderStepped:Connect(function()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    for model, motion in pairs(petMotion) do
        if not model or not model.Parent then
            petMotion[model] = nil
        elseif root and not (heldModel == model) then
            local t = os.clock() - motion.start
            local base = root.CFrame * CFrame.new(0, 1.5 + math.sin(t * 3) * 0.25, -6)
            local spin = CFrame.Angles(0, t * 0.8, 0)
            modelPivotTo(model, base * spin)
        end
    end
end)

-- Drag GUI using header
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

updateButtons()
refreshList()
print("[NhatKhanh] GUI started successfully.")
