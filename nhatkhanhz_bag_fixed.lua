-- NhatKhanh.lua - fresh standalone local display GUI
-- Local-only visual models. This does not create server-owned inventory items.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
frame.Size = UDim2.fromOffset(258, 398)
frame.Position = UDim2.new(0.5, -129, 0.08, 0)
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
header.Size = UDim2.new(1, 0, 0, 30)
header.BackgroundColor3 = theme.red
header.BorderSizePixel = 0
header.Text = "NHAT KHANH | MENU"
header.TextColor3 = theme.text
header.TextSize = 11
header.Font = Enum.Font.GothamBold
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local closeButton = Instance.new("TextButton")
closeButton.Name = "HideButton"
closeButton.Size = UDim2.fromOffset(25, 23)
closeButton.Position = UDim2.new(1, -28, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(95, 28, 28)
closeButton.BorderSizePixel = 0
closeButton.Text = "—"
closeButton.TextColor3 = theme.text
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.ZIndex = 5
closeButton.Parent = header
Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 6)
-- Mini watermelon button stays visible when the main menu is hidden.
local miniButton = Instance.new("TextButton")
miniButton.Name = "WatermelonMiniButton"
miniButton.Size = UDim2.fromOffset(42, 42)
miniButton.Position = UDim2.new(0, 16, 0.35, 0)
miniButton.BackgroundColor3 = Color3.fromRGB(35, 110, 65)
miniButton.BorderSizePixel = 0
miniButton.Text = "🍉"
miniButton.TextSize = 25
miniButton.Font = Enum.Font.GothamBold
miniButton.Visible = false
miniButton.Parent = gui
Instance.new("UICorner", miniButton).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(255, 120, 150)
miniStroke.Thickness = 2
miniStroke.Parent = miniButton

closeButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    bagFrame.Visible = false
    miniButton.Visible = true
end)
-- The watermelon button can be dragged with mouse or touch; a tap reopens the GUI.
do
    local dragging = false
    local moved = false
    local startInput, startPosition
    local activeInput

    miniButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            moved = false
            startInput = input.Position
            startPosition = miniButton.Position
            activeInput = input
        end
    end)

    miniButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input == activeInput or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startInput
            if math.abs(delta.X) + math.abs(delta.Y) > 7 then moved = true end
            local camera = Workspace.CurrentCamera
            local viewport = camera and camera.ViewportSize
            local x = startPosition.X.Offset + delta.X
            local y = startPosition.Y.Offset + delta.Y
            if viewport then
                x = math.clamp(x, 0, math.max(0, viewport.X - miniButton.AbsoluteSize.X))
                y = math.clamp(y, 0, math.max(0, viewport.Y - miniButton.AbsoluteSize.Y))
            end
            miniButton.Position = UDim2.fromOffset(x, y)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch) then
            dragging = false
            if not moved then
                frame.Visible = true
                miniButton.Visible = false
            end
        end
    end)
end

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

makeLabel("Loại mô hình", UDim2.fromOffset(8, 34), UDim2.fromOffset(120, 15), frame, 12, theme.muted)
local eggButton = makeButton("TRỨNG", UDim2.fromOffset(8, 51), UDim2.fromOffset(116, 24), frame, theme.green)
local petButton = makeButton("PET", UDim2.fromOffset(132, 51), UDim2.fromOffset(118, 24), frame)

makeLabel("Độ hiếm", UDim2.fromOffset(8, 78), UDim2.fromOffset(240, 15), frame, 12, theme.muted)
local divineButton = makeButton("DIVINE", UDim2.fromOffset(8, 95), UDim2.fromOffset(116, 24), frame, theme.red)
local eternalButton = makeButton("ETERNAL", UDim2.fromOffset(132, 95), UDim2.fromOffset(118, 24), frame)

makeLabel("Danh sách tên (cuộn)", UDim2.fromOffset(8, 122), UDim2.fromOffset(240, 15), frame, 12, theme.muted)
local list = Instance.new("ScrollingFrame")
list.Name = "NameList"
list.Position = UDim2.fromOffset(8, 139)
list.Size = UDim2.fromOffset(242, 70)
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

makeLabel("Kích thước (1x–30x)", UDim2.fromOffset(8, 213), UDim2.fromOffset(150, 15), frame, 12, theme.muted)
local scaleBox = Instance.new("TextBox")
scaleBox.Position = UDim2.fromOffset(8, 230)
scaleBox.Size = UDim2.fromOffset(62, 24)
scaleBox.BackgroundColor3 = theme.inset
scaleBox.BorderSizePixel = 0
scaleBox.Text = "1"
scaleBox.TextColor3 = theme.text
scaleBox.TextSize = 13
scaleBox.Font = Enum.Font.Gotham
scaleBox.ClearTextOnFocus = false
scaleBox.Parent = frame
Instance.new("UICorner", scaleBox).CornerRadius = UDim.new(0, 7)

local showButton = makeButton("HIỂN THỊ PHÍA TRƯỚC", UDim2.fromOffset(76, 230), UDim2.fromOffset(174, 24), frame, theme.green)
local bagButton = makeButton("THÊM VÀO TÚI ĐỒ", UDim2.fromOffset(8, 260), UDim2.fromOffset(242, 23), frame, theme.gold)
local clearBagButton = makeButton("XÓA DANH SÁCH TÚI GIẢ", UDim2.fromOffset(8, 288), UDim2.fromOffset(242, 22), frame, theme.red)
local clearButton = makeButton("XÓA TẤT CẢ MÔ HÌNH", UDim2.fromOffset(8, 315), UDim2.fromOffset(242, 22), frame, theme.red)
local status = makeLabel("Sẵn sàng. Mô hình chỉ hiển thị cục bộ.", UDim2.fromOffset(8, 395), UDim2.fromOffset(242, 12), frame, 9, theme.muted)

local kind = "Egg"
local rarity = "Divine"
local selectedName = nil
local displayed = {}
local petMotion = {}
-- Local-only fake bag; this does not alter the game's server inventory.
local bagItems = {}

-- Separate local-only bag panel. This mirrors the donor source's visual/fake-item workflow,
-- without modifying server-owned inventory data.
local bagFrame = Instance.new("Frame")
bagFrame.Name = "FakeBagPanel"
bagFrame.Size = UDim2.fromOffset(220, 260)
bagFrame.Position = UDim2.new(0.5, 140, 0.08, 0)
bagFrame.BackgroundColor3 = theme.bg
bagFrame.BorderSizePixel = 0
bagFrame.Visible = false
bagFrame.Parent = gui
Instance.new("UICorner", bagFrame).CornerRadius = UDim.new(0, 10)
local bagStroke = Instance.new("UIStroke")
bagStroke.Color = theme.gold
bagStroke.Thickness = 1.25
bagStroke.Parent = bagFrame

local bagHeader = Instance.new("TextLabel")
bagHeader.Size = UDim2.new(1, -12, 0, 28)
bagHeader.Position = UDim2.fromOffset(6, 4)
bagHeader.BackgroundTransparency = 1
bagHeader.Text = "TÚI PET / EGG GIẢ"
bagHeader.TextColor3 = theme.text
bagHeader.TextSize = 12
bagHeader.Font = Enum.Font.GothamBold
bagHeader.Parent = bagFrame

local bagCount = Instance.new("TextLabel")
bagCount.Name = "BagCount"
bagCount.Size = UDim2.new(1, -12, 0, 18)
bagCount.Position = UDim2.fromOffset(6, 30)
bagCount.BackgroundTransparency = 1
bagCount.Text = "Số mục: 0"
bagCount.TextColor3 = theme.muted
bagCount.TextSize = 10
bagCount.Font = Enum.Font.Gotham
bagCount.TextXAlignment = Enum.TextXAlignment.Left
bagCount.Parent = bagFrame

local bagList = Instance.new("ScrollingFrame")
bagList.Name = "BagList"
bagList.Position = UDim2.fromOffset(6, 52)
bagList.Size = UDim2.new(1, -12, 1, -60)
bagList.BackgroundColor3 = theme.panel
bagList.BorderSizePixel = 0
bagList.ScrollBarThickness = 5
bagList.CanvasSize = UDim2.new()
bagList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bagList.ScrollingDirection = Enum.ScrollingDirection.Y
bagList.Parent = bagFrame
Instance.new("UICorner", bagList).CornerRadius = UDim.new(0, 7)
local bagLayout = Instance.new("UIListLayout")
bagLayout.Padding = UDim.new(0, 4)
bagLayout.SortOrder = Enum.SortOrder.LayoutOrder
bagLayout.Parent = bagList
local bagPadding = Instance.new("UIPadding")
bagPadding.PaddingTop = UDim.new(0, 5)
bagPadding.PaddingBottom = UDim.new(0, 5)
bagPadding.PaddingLeft = UDim.new(0, 5)
bagPadding.PaddingRight = UDim.new(0, 5)
bagPadding.Parent = bagList

local bagToggleButton = makeButton("MỞ TÚI PET / EGG", UDim2.fromOffset(8, 370), UDim2.fromOffset(242, 22), frame, theme.gold)

local function refreshBagList()
    for _, child in ipairs(bagList:GetChildren()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
    bagCount.Text = "Số mục: " .. tostring(#bagItems)
    for i, item in ipairs(bagItems) do
        local row = Instance.new("TextLabel")
        row.Name = "BagItem_" .. i
        row.Size = UDim2.new(1, -4, 0, 28)
        row.BackgroundColor3 = theme.inset
        row.BorderSizePixel = 0
        row.Text = string.format("%d. [%s] %s · %dx", i, item.kind, item.name, item.scale)
        row.TextColor3 = theme.text
        row.TextSize = 10
        row.Font = Enum.Font.Gotham
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.TextTruncate = Enum.TextTruncate.AtEnd
        row.LayoutOrder = i
        row.Parent = bagList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
    end
end

bagToggleButton.MouseButton1Click:Connect(function()
    bagFrame.Visible = not bagFrame.Visible
    refreshBagList()
end)

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

    -- Keep the original egg material/colors; only draw a subtle rainbow outline.
    local highlight = Instance.new("Highlight")
    highlight.Name = "NhatKhanh_RainbowOutline"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.02
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    task.spawn(function()
        local hue = 0
        while highlight.Parent and model.Parent do
            hue = (hue + 0.008) % 1
            highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
            task.wait(0.05)
        end
    end)

    -- Put a soft, multicolor sparkle emitter at the egg's bounding-box center.
    -- The particle effect stays outside the egg and does not recolor its mesh.
    local boxCFrame, boxSize = model:GetBoundingBox()
    local carrier = Instance.new("Part")
    carrier.Name = "NhatKhanh_EggSparkleCarrier"
    carrier.Size = Vector3.new(0.15, 0.15, 0.15)
    carrier.Transparency = 1
    carrier.Anchored = true
    carrier.CanCollide = false
    carrier.CanTouch = false
    carrier.CanQuery = false
    carrier.CFrame = boxCFrame
    carrier.Parent = model

    local attachment = Instance.new("Attachment")
    attachment.Name = "RainbowSparkleAttachment"
    attachment.Parent = carrier

    local emitter = Instance.new("ParticleEmitter")
    emitter.Name = "RainbowOuterSparkles"
    emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    emitter.Enabled = true
    emitter.Rate = 75
    emitter.Lifetime = NumberRange.new(0.7, 1.25)
    emitter.Speed = NumberRange.new(0.45, 1.35)
    emitter.Drag = 2
    emitter.LightEmission = 1
    emitter.LightInfluence = 0
    emitter.SpreadAngle = Vector2.new(180, 180)
    emitter.EmissionDirection = Enum.NormalId.Top
    emitter.Shape = Enum.ParticleEmitterShape.Sphere
    emitter.ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface
    emitter.ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward
    emitter.ShapePartial = 1
    emitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.24),
        NumberSequenceKeypoint.new(0.45, 0.36),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0.08),
        NumberSequenceKeypoint.new(1, 1)
    })
    emitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 70, 100)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 170, 65)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(255, 245, 100)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(80, 255, 150)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(75, 190, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(170, 100, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 80, 190))
    })
    -- Sphere surface size tracks egg size so the sparkles appear around its exterior.
    emitter.ShapeSize = Vector3.new(
        math.max(boxSize.X * 0.62, 0.5),
        math.max(boxSize.Y * 0.62, 0.5),
        math.max(boxSize.Z * 0.62, 0.5)
    )
    emitter.Parent = attachment

    -- Always-on rainbow halo glow while the egg exists, without tinting the egg mesh.
    local light = Instance.new("PointLight")
    light.Name = "NhatKhanh_EggHalo"
    light.Color = Color3.fromRGB(190, 130, 255)
    light.Brightness = 3.5
    light.Range = math.max(12, math.max(boxSize.X, boxSize.Y, boxSize.Z) * 4.2)
    light.Shadows = false
    light.Parent = carrier

    task.spawn(function()
        local hue = 0
        while carrier.Parent and model.Parent do
            hue = (hue + 0.01) % 1
            light.Color = Color3.fromHSV(hue, 0.65, 1)
            task.wait(0.06)
        end
    end)
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

local function scaleModel(model, requestedScale)
    -- User-facing scale mapping: 1x = original, 20x = 10x model size, 30x = 20x.
    local factor
    if requestedScale <= 20 then
        factor = 1 + ((requestedScale - 1) * 9 / 19)
    else
        factor = 10 + (requestedScale - 20)
    end
    factor = math.clamp(factor, 1, 20)

    if model:IsA("Model") then
        local ok = pcall(function() model:ScaleTo(factor) end)
        if not ok then
            warn("[NhatKhanh] Model:ScaleTo failed for " .. model.Name)
        end
    else
        model.Size = model.Size * factor
    end
    return factor
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
    local factor = scaleModel(model, scale)
    anchorModel(model, true)
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not root then
        model:Destroy()
        setStatus("Không tìm thấy nhân vật. Hãy hồi sinh rồi thử lại.")
        return
    end
    -- Place both eggs and pets on the ground in front of the character.
    local forwardPoint = (root.CFrame * CFrame.new(0, 0, -5)).Position
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    rayParams.FilterDescendantsInstances = {player.Character, modelFolder}
    rayParams.IgnoreWater = false

    local rayOrigin = forwardPoint + Vector3.new(0, 80, 0)
    local rayDirection = Vector3.new(0, -240, 0)
    local hit = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
    if not hit then
        model:Destroy()
        setStatus("Không tìm thấy mặt đất phía trước. Hãy đứng gần mặt đất rồi thử lại.")
        return
    end

    local target = CFrame.new(forwardPoint.X, hit.Position.Y, forwardPoint.Z)
    modelPivotTo(model, target)
    local boxCFrame, boxSize = model:GetBoundingBox()
    local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
    local lift = hit.Position.Y - bottomY
    modelPivotTo(model, model:GetPivot() + Vector3.new(0, lift + 0.03, 0))
    sparkle(model, kind)
    table.insert(displayed, {model = model, kind = kind, name = selectedName})
    petMotion[model] = nil
    setStatus(kind == "Egg" and ("Đặt trứng trên mặt đất: " .. selectedName) or ("Đặt pet đứng yên trên mặt đất: " .. selectedName))
end

showButton.MouseButton1Click:Connect(makeVisible)

bagButton.MouseButton1Click:Connect(function()
    if not selectedName then
        setStatus("Hãy chọn một tên trứng hoặc pet trước.")
        return
    end

    local scale = tonumber(scaleBox.Text) or 1
    scale = math.clamp(math.floor(scale), 1, 30)
    table.insert(bagItems, {
        kind = kind,
        name = selectedName,
        scale = scale,
        addedAt = os.time(),
    })
    refreshBagList()
    bagFrame.Visible = true
    setStatus(string.format("Đã thêm %s vào túi giả · Tổng: %d", selectedName, #bagItems))
end)

clearBagButton.MouseButton1Click:Connect(function()
    local removed = #bagItems
    table.clear(bagItems)
    refreshBagList()
    setStatus(string.format("Đã xóa danh sách túi giả (%d mục).", removed))
end)

clearButton.MouseButton1Click:Connect(function()
    for _, item in ipairs(displayed) do
        if item.model and item.model.Parent then item.model:Destroy() end
    end
    table.clear(displayed)
    table.clear(petMotion)
    for _, child in ipairs(modelFolder:GetChildren()) do child:Destroy() end
    setStatus("Đã xóa toàn bộ mô hình cục bộ. Túi giả vẫn giữ danh sách.")
end)

-- Models remain anchored at their placement point; no bobbing or spinning.

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
