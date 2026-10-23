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
frame.Size = UDim2.fromOffset(258, 326)
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
    miniButton.Visible = true
end)
miniButton.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniButton.Visible = false
end)

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
local holdButton = makeButton("CẦM MÔ HÌNH TRÊN TAY", UDim2.fromOffset(8, 260), UDim2.fromOffset(242, 23), frame)
local clearButton = makeButton("XÓA TẤT CẢ MÔ HÌNH", UDim2.fromOffset(8, 288), UDim2.fromOffset(242, 22), frame, theme.red)
local status = makeLabel("Sẵn sàng. Mô hình chỉ hiển thị cục bộ.", UDim2.fromOffset(8, 311), UDim2.fromOffset(242, 12), frame, 9, theme.muted)

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

    -- Keep the original egg material/colors; only draw a subtle rainbow outline.
    local highlight = Instance.new("Highlight")
    highlight.Name = "NhatKhanh_RainbowOutline"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0.18
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = model

    task.spawn(function()
        local hue = 0
        while highlight.Parent and model.Parent do
            hue = (hue + 0.008) % 1
            highlight.OutlineColor = Color3.fromHSV(hue, 0.82, 1)
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
    emitter.Rate = 15
    emitter.Lifetime = NumberRange.new(0.45, 0.9)
    emitter.Speed = NumberRange.new(0.25, 1.0)
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
        NumberSequenceKeypoint.new(0, 0.12),
        NumberSequenceKeypoint.new(0.45, 0.2),
        NumberSequenceKeypoint.new(1, 0)
    })
    emitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.05),
        NumberSequenceKeypoint.new(0.7, 0.2),
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

    -- A restrained halo glow, without tinting the egg itself.
    local light = Instance.new("PointLight")
    light.Name = "NhatKhanh_EggHalo"
    light.Color = Color3.fromRGB(190, 130, 255)
    light.Brightness = 0.7
    light.Range = math.max(6, math.max(boxSize.X, boxSize.Y, boxSize.Z) * 1.8)
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
    local target
    if kind == "Egg" then
        -- Raycast down at a point a short distance in front of the character.
        -- Place the bottom of the egg on the ground, not its pivot.
        local forwardPoint = (root.CFrame * CFrame.new(0, 0, -5)).Position
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {player.Character, modelFolder}
        rayParams.IgnoreWater = false

        local rayOrigin = forwardPoint + Vector3.new(0, 60, 0)
        local rayDirection = Vector3.new(0, -180, 0)
        local hit = Workspace:Raycast(rayOrigin, rayDirection, rayParams)
        if not hit then
            model:Destroy()
            setStatus("Không tìm thấy mặt đất phía trước. Hãy đứng gần mặt đất rồi thử lại.")
            return
        end

        target = CFrame.new(forwardPoint.X, hit.Position.Y, forwardPoint.Z)
        modelPivotTo(model, target)
        local boxCFrame, boxSize = model:GetBoundingBox()
        local bottomY = boxCFrame.Position.Y - boxSize.Y / 2
        local lift = hit.Position.Y - bottomY
        modelPivotTo(model, model:GetPivot() + Vector3.new(0, lift + 0.03, 0))
    else
        target = root.CFrame * CFrame.new(0, 2.2, -5)
        modelPivotTo(model, target)
        local boxCFrame = model:GetBoundingBox()
        local correctedPivot = model:GetPivot() + (target.Position - boxCFrame.Position)
        modelPivotTo(model, correctedPivot)
    end

    sparkle(model, kind)
    table.insert(displayed, {model = model, kind = kind, name = selectedName})
    if kind == "Pet" then
        petMotion[model] = {start = os.clock()}
    end
    setStatus(kind == "Egg" and ("Đặt trứng trên mặt đất: " .. selectedName) or ("Pet hiển thị phía trước: " .. selectedName))
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
            local base = root.CFrame * CFrame.new(0, 2.2 + math.sin(t * 3) * 0.18, -5)
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
