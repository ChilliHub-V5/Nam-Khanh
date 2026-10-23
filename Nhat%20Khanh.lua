-- Nhat Khanh | Steal An Egg - Visual Display Only
-- This script clones local models and provides a local-only inventory list.
-- It does NOT edit Save data, real inventory, equipped assets, cash, or server state.
-- Scale input is restricted to 1x-30x per the requested game limit.
-- Weight and earnings use the game's own utility functions when available.
-- Names are dynamically filtered from Data.Assets.Directory to Eternal/Divine only.
-- Visual model size uses the source GUI mapping, not gameplay Scale directly.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
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

local AssetsData = safeRequire(ReplicatedStorage:WaitForChild("Data"):WaitForChild("Assets"))
local Directory = AssetsData and (AssetsData.Directory or AssetsData) or {}

local ALLOWED_RARITIES = { Eternal = true, Divine = true }

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
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
frame.Size = UDim2.fromOffset(300, 330)
frame.Position = UDim2.new(0.5, -310, 0.5, -165)
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
mini.Text = "🍉"
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
local subtitle = label("玉 · JADE COURT", UDim2.fromOffset(14, 33), UDim2.new(1, -50, 0, 15), 8, C.ivory)
subtitle.TextTransparency = 0.12

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(28, 26)
close.Position = UDim2.new(1, -36, 0, 8)
close.BackgroundColor3 = C.vermilion
close.Text = "—"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 13
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)
close.MouseButton1Click:Connect(function()
 frame.Visible = false
 mini.Visible = true
end)

label("Loại vật thể", UDim2.fromOffset(14, 43), UDim2.fromOffset(100, 20), 12, C.muted)

local kindButton = Instance.new("TextButton")
kindButton.Position = UDim2.fromOffset(14, 65)
kindButton.Size = UDim2.fromOffset(132, 32)
kindButton.BackgroundColor3 = C.inset
kindButton.TextColor3 = C.ivory
kindButton.Font = Enum.Font.GothamBold
kindButton.TextSize = 12
kindButton.Text = "Egg"
kindButton.Parent = frame
Instance.new("UICorner", kindButton).CornerRadius = UDim.new(0, 6)

label("Tên (chỉ Eternal / Divine)", UDim2.fromOffset(14, 105), UDim2.new(1, -28, 0, 20), 11, C.muted)

local prevButton = Instance.new("TextButton")
prevButton.Position = UDim2.fromOffset(14, 127)
prevButton.Size = UDim2.fromOffset(38, 32)
prevButton.BackgroundColor3 = C.inset
prevButton.TextColor3 = C.ivory
prevButton.Text = "<"
prevButton.Font = Enum.Font.GothamBold
prevButton.TextSize = 14
prevButton.Parent = frame
Instance.new("UICorner", prevButton).CornerRadius = UDim.new(0, 6)

local nameButton = Instance.new("TextButton")
nameButton.Position = UDim2.fromOffset(58, 127)
nameButton.Size = UDim2.fromOffset(188, 32)
nameButton.BackgroundColor3 = C.inset
nameButton.TextColor3 = C.ivory
nameButton.Text = "Đang tải danh sách..."
nameButton.Font = Enum.Font.GothamSemibold
nameButton.TextSize = 11
nameButton.TextTruncate = Enum.TextTruncate.AtEnd
nameButton.Parent = frame
Instance.new("UICorner", nameButton).CornerRadius = UDim.new(0, 6)

local nextButton = Instance.new("TextButton")
nextButton.Position = UDim2.fromOffset(252, 127)
nextButton.Size = UDim2.fromOffset(38, 32)
nextButton.BackgroundColor3 = C.inset
nextButton.TextColor3 = C.ivory
nextButton.Text = ">"
nextButton.Font = Enum.Font.GothamBold
nextButton.TextSize = 14
nextButton.Parent = frame
Instance.new("UICorner", nextButton).CornerRadius = UDim.new(0, 6)

label("Scale game (1x–30x; khác Kg)", UDim2.fromOffset(14, 165), UDim2.new(1, -28, 0, 20), 11, C.muted)
local scaleBox = Instance.new("TextBox")
scaleBox.Position = UDim2.fromOffset(14, 187)
scaleBox.Size = UDim2.fromOffset(132, 32)
scaleBox.BackgroundColor3 = C.inset
scaleBox.TextColor3 = C.ivory
scaleBox.Text = "1"
scaleBox.ClearTextOnFocus = false
scaleBox.Font = Enum.Font.Gotham
scaleBox.TextSize = 12
scaleBox.Parent = frame
Instance.new("UICorner", scaleBox).CornerRadius = UDim.new(0, 6)

local spawn = Instance.new("TextButton")
spawn.Position = UDim2.fromOffset(14, 229)
spawn.Size = UDim2.fromOffset(132, 32)
spawn.BackgroundColor3 = C.jade
spawn.TextColor3 = Color3.new(1,1,1)
spawn.Text = "HIỂN THỊ GIẢ"
spawn.Font = Enum.Font.GothamBold
spawn.TextSize = 12
spawn.Parent = frame
Instance.new("UICorner", spawn).CornerRadius = UDim.new(0, 6)

local clear = Instance.new("TextButton")
clear.Position = UDim2.fromOffset(154, 229)
clear.Size = UDim2.fromOffset(132, 32)
clear.BackgroundColor3 = C.vermilion
clear.TextColor3 = Color3.new(1,1,1)
clear.Text = "XÓA HIỂN THỊ"
clear.Font = Enum.Font.GothamBold
clear.TextSize = 12
clear.Parent = frame
Instance.new("UICorner", clear).CornerRadius = UDim.new(0, 6)

local addToBag = Instance.new("TextButton")
addToBag.Position = UDim2.fromOffset(14, 267)
addToBag.Size = UDim2.fromOffset(272, 30)
addToBag.BackgroundColor3 = C.gold
addToBag.TextColor3 = C.lacquer
addToBag.Text = "THÊM VÀO TÚI ĐỒ GIẢ"
addToBag.Font = Enum.Font.GothamBold
addToBag.TextSize = 12
addToBag.Parent = frame
Instance.new("UICorner", addToBag).CornerRadius = UDim.new(0, 6)

local status = label("Chỉ hiển thị mô hình cục bộ.", UDim2.fromOffset(14, 302), UDim2.new(1, -28, 0, 24), 10, C.muted)
status.TextWrapped = true

-- inventory UI: local visual list only; does not edit game Save/server inventory.
local bagFrame = Instance.new("Frame")
bagFrame.Name = "Inventory"
bagFrame.Size = UDim2.fromOffset(220, 330)
bagFrame.Position = UDim2.new(0.5, 5, 0.5, -165)
bagFrame.BackgroundColor3 = C.lacquer
bagFrame.BorderSizePixel = 0
bagFrame.Parent = gui
Instance.new("UICorner", bagFrame).CornerRadius = UDim.new(0, 12)
local bagStroke = Instance.new("UIStroke")
bagStroke.Color = C.gold
bagStroke.Thickness = 1.5
bagStroke.Parent = bagFrame

local bagTitle = Instance.new("TextLabel")
bagTitle.BackgroundTransparency = 1
bagTitle.Position = UDim2.fromOffset(12, 8)
bagTitle.Size = UDim2.new(1, -24, 0, 25)
bagTitle.Font = Enum.Font.GothamBold
bagTitle.TextSize = 13
bagTitle.TextColor3 = C.gold
bagTitle.Text = "TÚI ĐỒ GIẢ · LOCAL"
bagTitle.TextXAlignment = Enum.TextXAlignment.Left
bagTitle.Parent = bagFrame

local bagNote = Instance.new("TextLabel")
bagNote.BackgroundTransparency = 1
bagNote.Position = UDim2.fromOffset(12, 32)
bagNote.Size = UDim2.new(1, -24, 0, 28)
bagNote.Font = Enum.Font.Gotham
bagNote.TextSize = 9
bagNote.TextWrapped = true
bagNote.TextColor3 = C.muted
bagNote.Text = "Chỉ là danh sách giả trên máy bạn."
bagNote.TextXAlignment = Enum.TextXAlignment.Left
bagNote.Parent = bagFrame

local bagList = Instance.new("ScrollingFrame")
bagList.Name = "Items"
bagList.Position = UDim2.fromOffset(10, 64)
bagList.Size = UDim2.new(1, -20, 1, -112)
bagList.BackgroundColor3 = C.panel
bagList.BorderSizePixel = 0
bagList.ScrollBarThickness = 5
bagList.CanvasSize = UDim2.fromOffset(0, 0)
bagList.AutomaticCanvasSize = Enum.AutomaticSize.Y
bagList.Parent = bagFrame
Instance.new("UICorner", bagList).CornerRadius = UDim.new(0, 7)
local bagLayout = Instance.new("UIListLayout")
bagLayout.Padding = UDim.new(0, 5)
bagLayout.SortOrder = Enum.SortOrder.LayoutOrder
bagLayout.Parent = bagList
local bagPadding = Instance.new("UIPadding")
bagPadding.PaddingTop = UDim.new(0, 6)
bagPadding.PaddingBottom = UDim.new(0, 6)
bagPadding.PaddingLeft = UDim.new(0, 6)
bagPadding.PaddingRight = UDim.new(0, 6)
bagPadding.Parent = bagList

local clearBag = Instance.new("TextButton")
clearBag.Position = UDim2.new(0, 10, 1, -40)
clearBag.Size = UDim2.new(1, -20, 0, 30)
clearBag.BackgroundColor3 = C.vermilion
clearBag.TextColor3 = Color3.new(1, 1, 1)
clearBag.Text = "XÓA TÚI ĐỒ GIẢ"
clearBag.Font = Enum.Font.GothamBold
clearBag.TextSize = 11
clearBag.Parent = bagFrame
Instance.new("UICorner", clearBag).CornerRadius = UDim.new(0, 6)

local BagItems = {}
local function refreshBag()
 for _, child in ipairs(bagList:GetChildren()) do
 if child:IsA("TextLabel") then child:Destroy() end
 end
 for index, item in ipairs(BagItems) do
 local row = Instance.new("TextLabel")
 row.Name = "Item_" .. index
 row.LayoutOrder = index
 row.Size = UDim2.new(1, -2, 0, 34)
 row.BackgroundColor3 = C.inset
 row.BorderSizePixel = 0
 row.Font = Enum.Font.GothamSemibold
 row.TextSize = 10
 row.TextColor3 = C.ivory
 row.TextXAlignment = Enum.TextXAlignment.Left
 row.TextWrapped = true
 row.Text = " " .. item.kind .. " · " .. item.name
 row.Parent = bagList
 Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
 end
 bagTitle.Text = "TÚI ĐỒ GIẢ · " .. tostring(#BagItems)
end

local kind = "Egg"
local selectedIndex = { Egg = 1, Pet = 1 }

local function updateNameButton()
 local names = refreshNames(kind)
 if #names == 0 then
 selectedIndex[kind] = 1
 nameButton.Text = "Không có model Eternal/Divine"
 else
 selectedIndex[kind] = math.clamp(selectedIndex[kind] or 1, 1, #names)
 nameButton.Text = names[selectedIndex[kind]]
 end
end

local function moveSelection(delta)
 local names = refreshNames(kind)
 if #names == 0 then
 updateNameButton()
 return
 end
 selectedIndex[kind] = ((selectedIndex[kind] - 1 + delta) % #names) + 1
 updateNameButton()
end

prevButton.MouseButton1Click:Connect(function() moveSelection(-1) end)
nextButton.MouseButton1Click:Connect(function() moveSelection(1) end)

kindButton.MouseButton1Click:Connect(function()
 kind = kind == "Egg" and "Pet" or "Egg"
 kindButton.Text = kind
 updateNameButton()
end)

updateNameButton()
refreshBag()

addToBag.MouseButton1Click:Connect(function()
 local names = refreshNames(kind)
 local name = names[selectedIndex[kind]]
 if not name then
 status.Text = "Không có vật phẩm hợp lệ để thêm."
 return
 end
 table.insert(BagItems, { kind = kind, name = name })
 refreshBag()
 status.Text = "Đã thêm vào túi đồ giả (chỉ trên máy)."
end)

clearBag.MouseButton1Click:Connect(function()
 table.clear(BagItems)
 refreshBag()
 status.Text = "Đã xóa danh sách túi đồ giả."
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

spawn.MouseButton1Click:Connect(function()
 local names = refreshNames(kind)
 local name = names[selectedIndex[kind]]
 local scale = tonumber(scaleBox.Text)
 if not name then
 status.Text = "Không tìm thấy model Eternal/Divine cho loại này."
 return
 end
 if not scale or scale < 1 or scale > 30 then
 status.Text = "Scale phải nằm trong khoảng 1x–30x." 
 return
 end

 local sourceModel = getModel(kind, name)
 if not sourceModel or not sourceModel:IsA("Model") then
 status.Text = "Không tìm thấy model. Kiểm tra tên và loại Egg/Pet."
 return
 end

 local ok, model = pcall(function() return sourceModel:Clone() end)
 if not ok or not model then
 status.Text = "Không thể clone model này."
 return
 end

 local character = LocalPlayer.Character
 local root = character and character:FindFirstChild("HumanoidRootPart")
 if not root then
 model:Destroy()
 status.Text = "Không tìm thấy nhân vật."
 return
 end

 anchorModel(model)
 model.Name = "_" .. name
 model.Parent = visualFolder
 local target = root.CFrame * CFrame.new(0, 0, -7)
 pcall(function()
 if model.ScaleTo then model:ScaleTo(math.clamp(1 + scale / 70, 1, 2.4)) end
 model:PivotTo(target)
 end)

 status.Text = "Đã tạo mô hình hiển thị giả."
end)

clear.MouseButton1Click:Connect(function()
 for _, obj in ipairs(visualFolder:GetChildren()) do obj:Destroy() end
 status.Text = "Đã xóa tất cả mô hình hiển thị giả."
end)
