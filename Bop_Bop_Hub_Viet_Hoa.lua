-- BOP BOP HUB | Steal An Egg | Viet hoa + anh nen
-- Anh GitHub cua ban: IMG_8231.jpeg
-- Luu y: anh nen chi doi duoc neu source GUI co ImageLabel ten Background/Wallpaper/BackImage
-- va executor ho tro request + writefile + getcustomasset.

repeat task.wait(0.25) until game:IsLoaded()

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/SenaHub_Steal_An_Egg%21.lua"
local PHOTO_URL = "https://raw.githubusercontent.com/khanhdep41-tech/Nam-Khanh/refs/heads/main/IMG_8231.jpeg"
local PHOTO_FILE = "bopbop_hub_background.jpeg"

local function replacePlain(text, old, new)
    local out, pos = {}, 1
    while true do
        local first, last = string.find(text, old, pos, true)
        if not first then
            out[#out + 1] = string.sub(text, pos)
            break
        end
        out[#out + 1] = string.sub(text, pos, first - 1)
        out[#out + 1] = new
        pos = last + 1
    end
    return table.concat(out)
end

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)
if not ok or type(source) ~= "string" or #source < 1000 then
    warn("[BỐP BỐP HUB] Không tải được source SenaHub.")
    return
end

-- Doi cac ten/nhan pho bien truoc khi khoi dong.
local sourceReplacements = {
    {"Sena BETA", "BỐP BỐP HUB"},
    {"SenaHub", "BỐP BỐP HUB"},
    {"Sena Hub", "BỐP BỐP HUB"},
    {"Sena V4", "BỐP BỐP HUB"},
    {"SENA V4", "BỐP BỐP HUB"},
    {"Unfavorite Everything", "Bỏ yêu thích toàn bộ Pet"},
    {"Auto Sell Pet", "Tự động bán Pet"},
    {"Auto Sell Egg", "Tự động bán trứng"},
    {"Low Speed Multiplier", "Hệ số tốc độ thấp"},
    {"Egg Filter", "Lọc trứng"},
    {"Egg ESP", "Hiển thị trứng"},
    {"Steal Webhook", "Thông báo trộm trứng"},
    {"Private Server", "Máy chủ riêng"},
    {"Admin Abuse", "Sự kiện Admin"},
    {"Pet Name Filter", "Lọc tên Pet"},
    {"Pet Rarity Filter", "Lọc độ hiếm Pet"},
    {"Egg Rarity Filter", "Lọc độ hiếm trứng"},
    {"Auto Favorite", "Tự động yêu thích"},
    {"Auto Fuse", "Tự động hợp nhất Pet"},
    {"Sell Eggs Now", "Bán trứng ngay"},
    {"Search", "Tìm kiếm"},
    {"Welcome", "Chào mừng"},
    {"Settings", "Cài đặt"},
    {"Events", "Sự kiện"},
    {"Main", "Trang chủ"},
    {"Pets", "Thú cưng"},
    {"General", "Chung"},
}
for _, pair in ipairs(sourceReplacements) do
    source = replacePlain(source, pair[1], pair[2])
end

local chunk, compileErr = loadstring(source)
if not chunk then
    warn("[BỐP BỐP HUB] Lỗi biên dịch source: " .. tostring(compileErr))
    return
end
local runOk, runErr = pcall(chunk)
if not runOk then
    warn("[BỐP BỐP HUB] Lỗi khi chạy source: " .. tostring(runErr))
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local translations = {
    ["Main"] = "Trang chủ", ["Home"] = "Trang chủ", ["Auto"] = "Tự động",
    ["Private Server"] = "Máy chủ riêng", ["Pets"] = "Thú cưng",
    ["Admin Abuse"] = "Sự kiện Admin", ["Low Speed Multiplier"] = "Hệ số tốc độ thấp",
    ["Egg Filter"] = "Lọc trứng", ["Egg ESP"] = "Hiển thị trứng",
    ["Steal Webhook"] = "Thông báo trộm trứng", ["Search"] = "Tìm kiếm",
    ["Welcome"] = "Chào mừng", ["Free"] = "Miễn phí", ["Events"] = "Sự kiện",
    ["Settings"] = "Cài đặt", ["General"] = "Chung", ["Enabled"] = "Đã bật",
    ["Disabled"] = "Đã tắt", ["Close"] = "Đóng", ["Open"] = "Mở",
    ["Save"] = "Lưu", ["Cancel"] = "Hủy", ["Apply"] = "Áp dụng",
    ["Refresh"] = "Làm mới", ["Teleport"] = "Dịch chuyển", ["Server"] = "Máy chủ",
    ["Join"] = "Tham gia", ["Copy"] = "Sao chép", ["Copied!"] = "Đã sao chép!",
    ["Loading..."] = "Đang tải...", ["Auto Sell Pet"] = "Tự động bán Pet",
    ["Auto Sell Egg"] = "Tự động bán trứng", ["Sell Pet Now"] = "Bán Pet ngay",
    ["Sell Eggs Now"] = "Bán trứng ngay", ["Unfavorite Everything"] = "Bỏ yêu thích toàn bộ Pet",
    ["Auto Favorite"] = "Tự động yêu thích", ["Auto Fuse"] = "Tự động hợp nhất Pet",
    ["Pet Name Filter"] = "Lọc tên Pet", ["Pet Rarity Filter"] = "Lọc độ hiếm Pet",
    ["Egg Rarity Filter"] = "Lọc độ hiếm trứng", ["Favorite Rule"] = "Quy tắc yêu thích",
    ["Fusion Rule"] = "Quy tắc hợp nhất", ["Rarities to Keep"] = "Độ hiếm cần giữ",
    ["Species to Keep"] = "Loài Pet cần giữ", ["Rarities to Fuse"] = "Độ hiếm để hợp nhất",
    ["All"] = "Tất cả", ["Pick All"] = "Chọn tất cả", ["Select All"] = "Chọn tất cả",
    ["None"] = "Không có", ["On"] = "Bật", ["Off"] = "Tắt",
    ["Status"] = "Trạng thái", ["Current Server"] = "Máy chủ hiện tại",
    ["Server Hop"] = "Chuyển máy chủ", ["Hop Server"] = "Chuyển máy chủ",
    ["Rejoin"] = "Vào lại", ["Notification"] = "Thông báo", ["Notifications"] = "Thông báo",
    ["Egg"] = "Trứng", ["Pet"] = "Pet", ["Rarity"] = "Độ hiếm",
    ["Species"] = "Loài", ["Filter"] = "Bộ lọc", ["Select"] = "Chọn",
    ["Confirm"] = "Xác nhận", ["Are you sure?"] = "Bạn có chắc không?",
}
local function translateText(value)
    if type(value) ~= "string" or value == "" then return value end
    if translations[value] then return translations[value] end
    local text = value
    text = text:gsub("Sena BETA", "BỐP BỐP HUB")
    text = text:gsub("SenaHub", "BỐP BỐP HUB")
    text = text:gsub("Sena Hub", "BỐP BỐP HUB")
    text = text:gsub("Sena V4", "BỐP BỐP HUB")
    text = text:gsub("SENA V4", "BỐP BỐP HUB")
    text = text:gsub("Low Speed Multiplier", "Hệ số tốc độ thấp")
    text = text:gsub("Private Server", "Máy chủ riêng")
    text = text:gsub("Steal Webhook", "Thông báo trộm trứng")
    text = text:gsub("Egg Filter", "Lọc trứng")
    text = text:gsub("Egg ESP", "Hiển thị trứng")
    text = text:gsub("Admin Abuse", "Sự kiện Admin")
    text = text:gsub("Search", "Tìm kiếm")
    text = text:gsub("Welcome", "Chào mừng")
    return text
end
local function updateText(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function()
            obj.Text = translateText(obj.Text)
            if obj:IsA("TextBox") then obj.PlaceholderText = translateText(obj.PlaceholderText) end
        end)
    end
end
local function scan(root)
    for _, obj in ipairs(root:GetDescendants()) do updateText(obj) end
    updateText(root)
end

-- Tai anh vao bo nho executor neu cac API nay duoc ho tro.
local localPhotoAsset
pcall(function()
    if type(readfile) == "function" and type(writefile) == "function" and type(getcustomasset) == "function" then
        if not (type(isfile) == "function" and isfile(PHOTO_FILE)) then
            local imageBytes = game:HttpGet(PHOTO_URL)
            writefile(PHOTO_FILE, imageBytes)
        end
        localPhotoAsset = getcustomasset(PHOTO_FILE)
    end
end)

local function tryApplyPhoto(obj)
    if not localPhotoAsset or not obj:IsA("ImageLabel") then return end
    local name = string.lower(obj.Name)
    if name == "background" or name == "wallpaper" or name == "backimage"
        or name == "backgroundimage" or name == "bgimage" then
        pcall(function()
            obj.Image = localPhotoAsset
            obj.ImageTransparency = 0.35
            obj.ScaleType = Enum.ScaleType.Crop
        end)
    end
end

local function scanAll()
    scan(playerGui)
    if localPhotoAsset then
        for _, obj in ipairs(playerGui:GetDescendants()) do tryApplyPhoto(obj) end
    end
end

task.spawn(function()
    while task.wait(0.4) do pcall(scanAll) end
end)
playerGui.DescendantAdded:Connect(function(obj)
    task.defer(function()
        task.wait(0.08)
        updateText(obj)
        tryApplyPhoto(obj)
    end)
end)

task.wait(0.5)
scanAll()
if localPhotoAsset then
    print("[BỐP BỐP HUB] Đã tải ảnh nền từ GitHub.")
else
    warn("[BỐP BỐP HUB] Executor không hỗ trợ tải ảnh cục bộ; giao diện vẫn chạy nhưng ảnh nền chưa được đổi.")
end
print("[BỐP BỐP HUB] Đã bật lớp Việt hóa.")
