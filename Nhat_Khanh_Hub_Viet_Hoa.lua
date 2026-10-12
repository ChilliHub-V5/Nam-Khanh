-- Nhat Khanh Hub - bo nap Viet hoa giao dien SenaHub (Steal An Egg)
-- Tai source cong khai, chi thay cac gia tri Title/Content/Placeholder/Name da khai bao,
-- roi chay source da chinh sua trong bo nho. Khong sua cac gia tri dieu khien logic.

repeat task.wait(0.25) until game:IsLoaded()

local SOURCE_URL = "https://raw.githubusercontent.com/LSSOPS/OpenSource/refs/heads/main/SenaHub_Steal_An_Egg%21.lua"

local ok, source = pcall(function()
    return game:HttpGet(SOURCE_URL)
end)

if not ok or type(source) ~= "string" or #source < 1000 then
    warn("[Nhat Khanh Hub] Khong tai duoc source SenaHub.")
    return
end

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

-- Chi thay cac truong giao dien, tranh thay cac chuoi logic nhu "All", "Rarity", "Species".
local replacements = {
    {'Title = "Unfavorite Everything"', 'Title = "Bỏ yêu thích toàn bộ Pet"'},
    {'Content = "Clears the favorite flag on every pet you own."', 'Content = "Bỏ đánh dấu yêu thích của toàn bộ Pet bạn sở hữu."'},
    {'Title = "Pet Favorite"', 'Title = "Yêu thích Pet"'},
    {'Title = "Auto Sell Pet"', 'Title = "Tự động bán Pet"'},
    {'Content = "Sells pets that match a filter below. Favorite, placed and equipped pets are kept."', 'Content = "Tự động bán Pet theo bộ lọc bên dưới. Pet yêu thích, đã đặt và đang trang bị sẽ được giữ lại."'},
    {'Title = "Pet Name Filter"', 'Title = "Lọc tên Pet"'},
    {'Content = "Pets to sell by name. Pick All for every name."', 'Content = "Chọn tên Pet cần bán. Chọn tất cả để áp dụng cho mọi tên."'},
    {'Title = "Pet Rarity Filter"', 'Title = "Lọc độ hiếm Pet"'},
    {'Content = "Pets to sell by rarity. Pick All for every rarity."', 'Content = "Chọn độ hiếm Pet cần bán. Chọn tất cả để áp dụng cho mọi loại."'},
    {'Title = "Sell By Value (max money/s)"', 'Title = "Bán theo giá trị (tiền/giây tối đa)"'},
    {'Content = "Only sell pets whose money per second is this or lower. Blank = no value limit. Supports k, m, b."', 'Content = "Chỉ bán Pet có tiền mỗi giây bằng hoặc thấp hơn mức này. Để trống = không giới hạn. Hỗ trợ k, m, b."'},
    {'Title = "Auto Sell Egg"', 'Title = "Tự động bán trứng"'},
    {'Content = "Sells unplaced eggs of the rarities below."', 'Content = "Bán trứng chưa đặt theo độ hiếm bên dưới."'},
    {'Title = "Egg Rarity Filter"', 'Title = "Lọc độ hiếm trứng"'},
    {'Content = "Egg rarities to sell. Pick All for every rarity."', 'Content = "Chọn độ hiếm trứng cần bán. Chọn tất cả để áp dụng cho mọi loại."'},
    {'Content = "Only sell eggs whose money per second is this or lower. Blank = no value limit. Supports k, m, b."', 'Content = "Chỉ bán trứng có tiền mỗi giây bằng hoặc thấp hơn mức này. Để trống = không giới hạn. Hỗ trợ k, m, b."'},
    {'Title = "Auto Favorite"', 'Title = "Tự động yêu thích"'},
    {'Content = "Marks every pet that matches the rule below as a favorite, so Auto Sell and Auto Fuse leave it alone."', 'Content = "Đánh dấu yêu thích Pet khớp quy tắc bên dưới để Tự động bán và Tự động hợp nhất bỏ qua."'},
    {'Title = "Favorite Rule"', 'Title = "Quy tắc yêu thích"'},
    {'Content = "Match pets by rarity or by species."', 'Content = "Lọc Pet theo độ hiếm hoặc theo loài."'},
    {'Title = "Rarities to Keep"', 'Title = "Độ hiếm cần giữ"'},
    {'Content = "Pets of these rarities get favorited."', 'Content = "Pet thuộc các độ hiếm này sẽ được đánh dấu yêu thích."'},
    {'Title = "Species to Keep"', 'Title = "Loài Pet cần giữ"'},
    {'Content = "Pets of these species get favorited."', 'Content = "Pet thuộc các loài này sẽ được đánh dấu yêu thích."'},
    {'Title = "Auto Fuse"', 'Title = "Tự động hợp nhất Pet"'},
    {'Content = "Feeds three matching pets into the Fusion machine over and over. Favorited and equipped pets are never used."', 'Content = "Liên tục đưa ba Pet phù hợp vào máy hợp nhất. Pet yêu thích và Pet đang trang bị sẽ không bị sử dụng."'},
    {'Title = "Fusion Rule"', 'Title = "Quy tắc hợp nhất"'},
    {'Content = "Fuse anything that passes the rarity filter, or only the species you pick below."', 'Content = "Hợp nhất Pet vượt qua bộ lọc độ hiếm hoặc chỉ các loài bạn chọn bên dưới."'},
    {'Title = "Rarities to Fuse"', 'Title = "Độ hiếm để hợp nhất"'},
    {'Content = "Only fuse pets of these rarities. Leave empty for any rarity."', 'Content = "Chỉ hợp nhất Pet có độ hiếm đã chọn. Để trống để áp dụng mọi độ hiếm."'},
    {'Title = "Sell Eggs Now"', 'Title = "Bán trứng ngay"'},
    {'Content = "Runs one pass of Auto Sell Egg using the filters above."', 'Content = "Chạy một lượt bán trứng theo bộ lọc bên trên."'},
    {'Content = "Runs one pass of Auto Sell Pet using the filters above."', 'Content = "Chạy một lượt bán Pet theo bộ lọc bên trên."'},
    {'Name = "Events"', 'Name = "Sự kiện"'},
    {'Text = "discord.gg/senahub"', 'Text = "Nhat Khanh Hub"'},
}

local changed = 0
for _, pair in ipairs(replacements) do
    local before = source
    source = replacePlain(source, pair[1], pair[2])
    if source ~= before then
        changed += 1
    end
end

-- Doi ten chi o cac chuoi tieu de ro rang, khong doi ten bien/hàm noi bo.
source = replacePlain(source, 'Title = "Sena V4"', 'Title = "Nhat Khanh Hub"')
source = replacePlain(source, 'Title = "SENA V4"', 'Title = "NHAT KHANH HUB"')

local compile, compileErr = loadstring(source)
if not compile then
    warn("[Nhat Khanh Hub] Loi bien dich sau khi Viet hoa: " .. tostring(compileErr))
    return
end

print("[Nhat Khanh Hub] Da ap dung " .. tostring(changed) .. " thay doi giao dien.")
local runOk, runErr = pcall(compile)
if not runOk then
    warn("[Nhat Khanh Hub] Loi khoi dong: " .. tostring(runErr))
end
