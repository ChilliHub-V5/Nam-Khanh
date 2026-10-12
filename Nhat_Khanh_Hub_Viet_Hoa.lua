-- Nhat Khanh Hub - Viet hoa giao dien SenaHub / Steal An Egg
-- Loader nay nap source cong khai, sau do dich cac chuoi UI hien thi trong PlayerGui.
-- Luu y: dich bang lop giao dien luc chay; mot so chuoi moi/chuoi bi ma hoa co the can bo sung.

repeat task.wait(0.25) until game:IsLoaded()

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/SenaHub_Steal_An_Egg%21.lua"

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(source) ~= "string" or #source < 1000 then
    warn("[Nhat Khanh Hub] Khong tai duoc source SenaHub.")
    return
end

local compile, compileErr = loadstring(source)
if not compile then
    warn("[Nhat Khanh Hub] Khong bien dich duoc source goc: " .. tostring(compileErr))
    return
end

local runOk, runErr = pcall(compile)
if not runOk then
    warn("[Nhat Khanh Hub] Loi khi chay source goc: " .. tostring(runErr))
end

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local exact = {
    ["Sena BETA | Steal An Egg"] = "Nhat Khanh Hub | Steal An Egg",
    ["SenaHub"] = "Nhat Khanh Hub",
    ["Sena Hub"] = "Nhat Khanh Hub",
    ["Sena V4"] = "Nhat Khanh Hub",
    ["SENA V4"] = "NHAT KHANH HUB",
    ["Main"] = "Trang chủ",
    ["Home"] = "Trang chủ",
    ["Auto"] = "Tự động",
    ["Private Server"] = "Máy chủ riêng",
    ["Pets"] = "Thú cưng",
    ["Admin Abuse"] = "Sự kiện Admin",
    ["Low Speed Multiplier"] = "Hệ số tốc độ thấp",
    ["Egg Filter"] = "Lọc trứng",
    ["Egg ESP"] = "Hiển thị trứng",
    ["Steal Webhook"] = "Thông báo trộm trứng",
    ["Search"] = "Tìm kiếm",
    ["Welcome"] = "Chào mừng",
    ["Free"] = "Miễn phí",
    ["Events"] = "Sự kiện",
    ["Settings"] = "Cài đặt",
    ["General"] = "Chung",
    ["Enabled"] = "Đã bật",
    ["Disabled"] = "Đã tắt",
    ["Close"] = "Đóng",
    ["Open"] = "Mở",
    ["Save"] = "Lưu",
    ["Cancel"] = "Hủy",
    ["Apply"] = "Áp dụng",
    ["Refresh"] = "Làm mới",
    ["Teleport"] = "Dịch chuyển",
    ["Server"] = "Máy chủ",
    ["Join"] = "Tham gia",
    ["Copy"] = "Sao chép",
    ["Copied!"] = "Đã sao chép!",
    ["Loading..."] = "Đang tải...",
    ["Enabled!"] = "Đã bật!",
    ["Disabled!"] = "Đã tắt!",
    ["Auto Sell Pet"] = "Tự động bán Pet",
    ["Auto Sell Egg"] = "Tự động bán trứng",
    ["Sell Pet Now"] = "Bán Pet ngay",
    ["Sell Eggs Now"] = "Bán trứng ngay",
    ["Unfavorite Everything"] = "Bỏ yêu thích toàn bộ Pet",
    ["Auto Favorite"] = "Tự động yêu thích",
    ["Auto Fuse"] = "Tự động hợp nhất Pet",
    ["Pet Name Filter"] = "Lọc tên Pet",
    ["Pet Rarity Filter"] = "Lọc độ hiếm Pet",
    ["Egg Rarity Filter"] = "Lọc độ hiếm trứng",
    ["Favorite Rule"] = "Quy tắc yêu thích",
    ["Fusion Rule"] = "Quy tắc hợp nhất",
    ["Rarities to Keep"] = "Độ hiếm cần giữ",
    ["Species to Keep"] = "Loài Pet cần giữ",
    ["Rarities to Fuse"] = "Độ hiếm để hợp nhất",
    ["Sell By Value (max money/s)"] = "Bán theo giá trị (tiền/giây tối đa)",
    ["FPS"] = "Khung hình/giây",
    ["Anti AFK"] = "Chống AFK",
    ["Low Speed User. Higher = faster grab, lower = safer. Lower it if steals keep failing."] = "Dành cho người chơi tốc độ thấp. Giá trị cao giúp nhặt nhanh hơn nhưng kém an toàn hơn. Giảm giá trị nếu trộm liên tục thất bại.",
    ["Sells unplaced eggs of the rarities below."] = "Bán trứng chưa đặt theo độ hiếm bên dưới.",
    ["Egg rarities to sell. Pick All for every rarity."] = "Chọn độ hiếm trứng cần bán. Chọn Tất cả để áp dụng cho mọi loại.",
    ["Pick All"] = "Chọn tất cả",
    ["Select All"] = "Chọn tất cả",
    ["All"] = "Tất cả",
    ["None"] = "Không có",
    ["On"] = "Bật",
    ["Off"] = "Tắt",
    ["Status"] = "Trạng thái",
    ["Current Server"] = "Máy chủ hiện tại",
    ["Server Hop"] = "Chuyển máy chủ",
    ["Hop Server"] = "Chuyển máy chủ",
    ["Rejoin"] = "Vào lại",
    ["Discord"] = "Discord",
    ["Webhook"] = "Webhook",
    ["Notification"] = "Thông báo",
    ["Notifications"] = "Thông báo",
    ["Egg"] = "Trứng",
    ["Pet"] = "Pet",
    ["Rarity"] = "Độ hiếm",
    ["Species"] = "Loài",
    ["Filter"] = "Bộ lọc",
    ["Select"] = "Chọn",
    ["Confirm"] = "Xác nhận",
    ["Are you sure?"] = "Bạn có chắc không?",
}

local function translateText(text)
    if type(text) ~= "string" or text == "" then
        return text
    end
    local translated = exact[text]
    if translated then
        return translated
    end

    -- Dich tieu de khi chuoi co them ten game/trang thai.
    translated = text
    translated = translated:gsub("Sena BETA", "Nhat Khanh Hub")
    translated = translated:gsub("SenaHub", "Nhat Khanh Hub")
    translated = translated:gsub("Sena Hub", "Nhat Khanh Hub")
    translated = translated:gsub("Private Server", "Máy chủ riêng")
    translated = translated:gsub("Low Speed Multiplier", "Hệ số tốc độ thấp")
    translated = translated:gsub("Egg Filter", "Lọc trứng")
    translated = translated:gsub("Egg ESP", "Hiển thị trứng")
    translated = translated:gsub("Steal Webhook", "Thông báo trộm trứng")
    translated = translated:gsub("Admin Abuse", "Sự kiện Admin")
    translated = translated:gsub("Search", "Tìm kiếm")
    translated = translated:gsub("Welcome", "Chào mừng")
    translated = translated:gsub("Main", "Trang chủ")
    return translated
end

local function translateObject(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return
    end
    pcall(function()
        local newText = translateText(obj.Text)
        if newText ~= obj.Text then
            obj.Text = newText
        end
        if obj:IsA("TextBox") then
            local newPlaceholder = translateText(obj.PlaceholderText)
            if newPlaceholder ~= obj.PlaceholderText then
                obj.PlaceholderText = newPlaceholder
            end
        end
    end)
end

local function translateTree(root)
    for _, obj in ipairs(root:GetDescendants()) do
        translateObject(obj)
    end
    translateObject(root)
end

-- Quet lap lai de dich ca menu con duoc tao sau khi bam nut.
task.spawn(function()
    while task.wait(0.35) do
        pcall(function()
            translateTree(playerGui)
        end)
    end
end)

-- Theo doi UI moi duoc them vao de dich nhanh hon.
playerGui.DescendantAdded:Connect(function(obj)
    task.defer(function()
        task.wait(0.05)
        translateObject(obj)
    end)
end)

task.wait(0.5)
translateTree(playerGui)
print("[Nhat Khanh Hub] Da bat lop Viet hoa giao dien.")
