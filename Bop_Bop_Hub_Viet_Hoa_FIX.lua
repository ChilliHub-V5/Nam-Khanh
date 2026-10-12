-- BOP BOP HUB | Steal An Egg | Safe Vietnamese UI overlay
-- Khong sua chuoi trong source goc truoc khi bien dich de tranh lam hong code.
-- Anh: https://raw.githubusercontent.com/khanhdep41-tech/Nam-Khanh/refs/heads/main/IMG_8231.jpeg

repeat task.wait(0.25) until game:IsLoaded()

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/SenaHub_Steal_An_Egg%21.lua"
local PHOTO_URL = "https://raw.githubusercontent.com/khanhdep41-tech/Nam-Khanh/refs/heads/main/IMG_8231.jpeg"
local PHOTO_FILE = "bopbop_hub_background.jpeg"

local function report(msg)
    warn("[BOP BOP HUB] " .. tostring(msg))
end

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)
if not ok or type(source) ~= "string" or #source < 1000 then
    report("Khong tai duoc source SenaHub. Kiem tra mang hoac link source.")
    return
end

local chunk, compileErr = loadstring(source)
if not chunk then
    report("Source goc loi bien dich: " .. tostring(compileErr))
    return
end

local ran, runErr = pcall(chunk)
if not ran then
    report("Source goc loi khi khoi dong: " .. tostring(runErr))
    return
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui", 15)
if not playerGui then
    report("Khong tim thay PlayerGui.")
    return
end

local translations = {
    ["Sena BETA | Steal An Egg"] = "BỐP BỐP HUB | Steal An Egg",
    ["Sena BETA"] = "BỐP BỐP HUB",
    ["SenaHub"] = "BỐP BỐP HUB",
    ["Sena Hub"] = "BỐP BỐP HUB",
    ["Sena V4"] = "BỐP BỐP HUB",
    ["SENA V4"] = "BỐP BỐP HUB",
    ["Main"] = "Trang chủ", ["Home"] = "Trang chủ",
    ["Auto"] = "Tự động", ["Private Server"] = "Máy chủ riêng",
    ["Pets"] = "Thú cưng", ["Admin Abuse"] = "Sự kiện Admin",
    ["Low Speed Multiplier"] = "Hệ số tốc độ thấp",
    ["Egg Filter"] = "Lọc trứng", ["Egg ESP"] = "Hiển thị trứng",
    ["Steal Webhook"] = "Thông báo trộm trứng", ["Search"] = "Tìm kiếm",
    ["Welcome"] = "Chào mừng", ["Free"] = "Miễn phí",
    ["Events"] = "Sự kiện", ["Settings"] = "Cài đặt",
    ["General"] = "Chung", ["Enabled"] = "Đã bật",
    ["Disabled"] = "Đã tắt", ["Close"] = "Đóng", ["Open"] = "Mở",
    ["Save"] = "Lưu", ["Cancel"] = "Hủy", ["Apply"] = "Áp dụng",
    ["Refresh"] = "Làm mới", ["Teleport"] = "Dịch chuyển",
    ["Server"] = "Máy chủ", ["Join"] = "Tham gia",
    ["Copy"] = "Sao chép", ["Copied!"] = "Đã sao chép!",
    ["Loading..."] = "Đang tải...", ["Auto Sell Pet"] = "Tự động bán Pet",
    ["Auto Sell Egg"] = "Tự động bán trứng", ["Sell Pet Now"] = "Bán Pet ngay",
    ["Sell Eggs Now"] = "Bán trứng ngay",
    ["Unfavorite Everything"] = "Bỏ yêu thích toàn bộ Pet",
    ["Auto Favorite"] = "Tự động yêu thích",
    ["Auto Fuse"] = "Tự động hợp nhất Pet",
    ["Pet Name Filter"] = "Lọc tên Pet", ["Pet Rarity Filter"] = "Lọc độ hiếm Pet",
    ["Egg Rarity Filter"] = "Lọc độ hiếm trứng",
    ["Favorite Rule"] = "Quy tắc yêu thích", ["Fusion Rule"] = "Quy tắc hợp nhất",
    ["Rarities to Keep"] = "Độ hiếm cần giữ", ["Species to Keep"] = "Loài Pet cần giữ",
    ["Rarities to Fuse"] = "Độ hiếm để hợp nhất",
    ["All"] = "Tất cả", ["Pick All"] = "Chọn tất cả",
    ["Select All"] = "Chọn tất cả", ["None"] = "Không có",
    ["On"] = "Bật", ["Off"] = "Tắt", ["Status"] = "Trạng thái",
    ["Current Server"] = "Máy chủ hiện tại", ["Server Hop"] = "Chuyển máy chủ",
    ["Hop Server"] = "Chuyển máy chủ", ["Rejoin"] = "Vào lại",
    ["Notification"] = "Thông báo", ["Notifications"] = "Thông báo",
    ["Egg"] = "Trứng", ["Pet"] = "Pet", ["Rarity"] = "Độ hiếm",
    ["Species"] = "Loài", ["Filter"] = "Bộ lọc", ["Select"] = "Chọn",
    ["Confirm"] = "Xác nhận", ["Are you sure?"] = "Bạn có chắc không?",
}

local function translate(value)
    if type(value) ~= "string" then return value end
    if translations[value] then return translations[value] end
    local s = value
    s = s:gsub("Sena BETA", "BỐP BỐP HUB")
    s = s:gsub("SenaHub", "BỐP BỐP HUB")
    s = s:gsub("Sena Hub", "BỐP BỐP HUB")
    s = s:gsub("Sena V4", "BỐP BỐP HUB")
    s = s:gsub("SENA V4", "BỐP BỐP HUB")
    s = s:gsub("Low Speed Multiplier", "Hệ số tốc độ thấp")
    s = s:gsub("Private Server", "Máy chủ riêng")
    s = s:gsub("Steal Webhook", "Thông báo trộm trứng")
    s = s:gsub("Egg Filter", "Lọc trứng")
    s = s:gsub("Egg ESP", "Hiển thị trứng")
    s = s:gsub("Admin Abuse", "Sự kiện Admin")
    s = s:gsub("Search", "Tìm kiếm")
    s = s:gsub("Welcome", "Chào mừng")
    return s
end

local function applyText(obj)
    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        pcall(function()
            obj.Text = translate(obj.Text)
            if obj:IsA("TextBox") then
                obj.PlaceholderText = translate(obj.PlaceholderText)
            end
        end)
    end
end

local photoAsset
pcall(function()
    if type(readfile) == "function" and type(writefile) == "function"
        and type(getcustomasset) == "function" then
        if not (type(isfile) == "function" and isfile(PHOTO_FILE)) then
            local bytes = game:HttpGet(PHOTO_URL)
            writefile(PHOTO_FILE, bytes)
        end
        photoAsset = getcustomasset(PHOTO_FILE)
    end
end)

local function scan()
    for _, obj in ipairs(playerGui:GetDescendants()) do
        applyText(obj)
        if photoAsset and obj:IsA("ImageLabel") then
            local n = string.lower(obj.Name)
            if n == "background" or n == "wallpaper" or n == "backimage"
                or n == "backgroundimage" or n == "bgimage" then
                pcall(function()
                    obj.Image = photoAsset
                    obj.ImageTransparency = 0.35
                    obj.ScaleType = Enum.ScaleType.Crop
                end)
            end
        end
    end
end

playerGui.DescendantAdded:Connect(function(obj)
    task.defer(function()
        task.wait(0.1)
        applyText(obj)
    end)
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(scan)
    end
end)

scan()
if photoAsset then
    print("[BOP BOP HUB] Da tai anh nen vao bo nho executor.")
else
    warn("[BOP BOP HUB] Khong the tai anh nen bang API cua executor; hub van duoc nap.")
end
print("[BOP BOP HUB] Da khoi dong lop Viet hoa.")
