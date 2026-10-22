repeat task.wait() until game:IsLoaded()

do local prev = _G.TestBypassFarm; if prev and type(prev.dead)=='boolean' then prev.dead = true end end
local HUB = { conns = {}, dead = false, travelAbort = false, Scramble = nil, ESP = nil, ClearFPSConns = nil, HideDescendants = nil, RestoreCache = nil, ApplyHideAllPets = nil, ApplyFPSBoost = nil, SetAntiAFK = nil, ClearMapReduceConns = nil, IsProtectedFromReduce = nil, ReduceOne = nil, ApplyReduceMap = nil }
_G.TestBypassFarm = HUB
local function track(conn) table.insert(HUB.conns, conn); return conn end
local Notify   -- forward declare (dipakai blok FPS/Optimizer/HUD di atas definisinya)

local Airflow, Window

HUB.Unload = function()
    HUB.dead = true
    for _, c in ipairs(HUB.conns) do pcall(function() c:Disconnect() end) end
    if HUB.ESP then pcall(HUB.ESP.AllOff) end
    if HUB._antiAfkConn then pcall(function() HUB._antiAfkConn:Disconnect() end) end
    pcall(function()
        if Airflow and Airflow.Windows and Airflow.Windows[1] then
            Airflow.Windows[1]:Destroy()
        end
    end)
    _G.TestBypassFarm = nil
    print("[Nhat Khanh Hub] Đã tắt!")
end

local Players           = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local RunService        = game:GetService('RunService')
local UserInputService  = game:GetService('UserInputService')
local Workspace         = game:GetService('Workspace')
local Lighting          = game:GetService('Lighting')
local RS                = ReplicatedStorage
local LP                = Players.LocalPlayer

-- ============================================================
-- ==============================================================================
-- CLIENT AC NEUTRALIZER & UGI CONSTANT WIPER (Layer 1 + Layer 2)
-- ==============================================================================
local function bypassClientDetections()
    if typeof(filtergc) ~= "function" or typeof(debug) ~= "table" or typeof(debug.getupvalues) ~= "function" then
        return false, "no filtergc"
    end
    local ok, fn = pcall(function()
        return filtergc("function", {
            Constants = { "gmatch", "GetFullName" },
        }, true)
    end)
    if not ok or type(fn) ~= "function" then
        return false, "filter miss"
    end
    local setMeta = (typeof(setrawmetatable) == "function" and setrawmetatable)
        or (typeof(setmetatable) == "function" and setmetatable)
    if not setMeta then
        return false, "no setmeta"
    end
    local blocked = 0
    local okUv, ups = pcall(debug.getupvalues, fn)
    if not okUv or type(ups) ~= "table" then
        return false, "no upvalues"
    end
    for _, tbl in pairs(ups) do
        if typeof(tbl) == "table" then
            local okSet = pcall(setMeta, tbl, {
                __newindex = function() end,
            })
            if okSet then
                blocked = blocked + 1
            end
        end
    end
    return blocked > 0, blocked
end

pcall(bypassClientDetections)

-- Runtime AC Detection Table Freezer (Neutralizes violation storage)
pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local setmeta = setrawmetatable or setmetatable
    local getmeta = getrawmetatable or getmetatable

    if getgc and setmeta then
        for _, obj in ipairs(getgc(true)) do
            if typeof(obj) == "table" and not (getmeta and getmeta(obj)) then
                local mainrun = false
                for _, v in pairs(obj) do
                    if v == obj then
                        mainrun = true
                        break
                    end
                end
                if mainrun then
                    for _, v in pairs(obj) do
                        if typeof(v) == "number" and v >= 1 and v <= 3 and obj[v] == nil then
                            pcall(setmeta, obj, { __newindex = function() end })
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- UGI Constant Wiper (neutralizes ReplicatedFirst.UGI watchdog)
pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local setconstant = setconstant or (debug and debug.setconstant)
    local islclosure = islclosure or function(Function)
        return not pcall(setfenv, getfenv(Function))
    end

    if getgc and getconstants and setconstant then
        for _, Function in ipairs(getgc(true)) do
            if typeof(Function) == "function" and islclosure(Function) then
                local ok, Source = pcall(debug.info, Function, "s")
                if ok and type(Source) == "string" and Source:find("ReplicatedFirst", 1, true) and Source:find("UGI", 1, true) then
                    local okC, Constants = pcall(getconstants, Function)
                    if okC and type(Constants) == "table" then
                        for Index, Constant in next, Constants do
                            if type(Constant) == "string" and Constant == "Humanoid" then
                                pcall(setconstant, Function, Index, "")
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Secondary Layer: X-14 Stack Scrubber & Token Neutralizer
pcall(function()
    local getconstants = getconstants or (debug and debug.getconstants)
    local islclosure = islclosure or function(fn) return not pcall(setfenv, getfenv(fn)) end
    local HookFn = hookfunction or replaceclosure or hookfunc
    if getgc and getconstants and HookFn and debug and debug.getstack and debug.setstack then
        for _, fn in ipairs(getgc(true)) do
            if typeof(fn) == "function" and islclosure(fn) then
                local ok, consts = pcall(getconstants, fn)
                if ok and type(consts) == "table" and table.find(consts, "X-14") then
                    local cb = nil
                    cb = HookFn(fn, function(...)
                        local stack = debug.getstack(1)
                        if type(stack) == "table" then
                            for idx, val in pairs(stack) do
                                if val == "X-14" then
                                    pcall(debug.setstack, 1, idx, nil)
                                end
                            end
                        end
                        if cb then return cb(...) end
                    end)
                end
            end
        end
    end
end)

-- Layer 3: Anti-Tamper State Table Sanitizer (19-upvalue detection neutralization)
pcall(function()
    local getgc = getgc or (debug and debug.getgc)
    local islclosure = islclosure or function(v) return not pcall(setfenv, getfenv(v)) end
    local getupvalues = getupvalues or (debug and debug.getupvalues)
    local getupvalue = getupvalue or (debug and debug.getupvalue)
    local setupvalue = setupvalue or (debug and debug.setupvalue)
    local clonefunction = clonefunction or function(f) return function(...) return f(...) end end

    if getgc and getupvalues and getupvalue and setupvalue then
        for _, v in ipairs(getgc(true)) do
            if typeof(v) == "function" and islclosure(v) then
                local ok, upvs = pcall(getupvalues, v)
                if ok and upvs and #upvs == 19 then
                    local ok2, u2 = pcall(getupvalue, v, 2)
                    if ok2 and typeof(u2) == "function" then
                        local old = clonefunction(u2)
                        pcall(setupvalue, v, 2, function(a, b)
                            if b and typeof(b) == "table" then
                                pcall(setmetatable, b, {})
                            end
                            return old(a, b)
                        end)
                    end
                end
            end
        end
    end
end)

-- ==============================================================================
-- CHARACTER & MOVEMENT HELPERS
-- ==============================================================================
local function findChar() return LP.Character end
local function findHum()
    local ch = LP.Character
    return ch and ch:FindFirstChildOfClass("Humanoid")
end
local function findHRP()
    local ch = LP.Character
    return ch and (ch:FindFirstChild("HumanoidRootPart") or ch.PrimaryPart or ch:FindFirstChildWhichIsA("BasePart"))
end

local GetCharacter = findChar
local GetHumanoid  = findHum
local GetHRP       = findHRP


-- ==============================================================================
-- BAC TELEMETRY PACKET SPOOFER
-- ==============================================================================
local bxor = bit32.bxor
local unpack = table.unpack

local function setupBacSpoofer()
    local function isGuid(n)
        return #n==36 and n:sub(9,9)=="-" and n:sub(14,14)=="-" and n:sub(19,19)=="-" and n:sub(24,24)=="-" and n:gsub("-",""):match("^%x+$")~=nil
    end

    local remoteSet, anyRemote = {}, nil

    local function scanRemotes()
        for _, s in ipairs(game:GetChildren()) do
            local ok, list = pcall(s.GetDescendants, s)
            if ok and list then
                for _, o in ipairs(list) do
                    if o:IsA("RemoteEvent") and isGuid(o.Name) then
                        remoteSet[o] = true
                        anyRemote = anyRemote or o
                    end
                end
            end
        end
    end

    scanRemotes()

    local function parseCounter(v)
        if type(v) ~= "string" then return end
        local n = v:match("^X%-(%d+)$")
        return n and tonumber(n)
    end

    local function looksLikeState(t, r)
        if type(t) ~= "table" then return false end
        local hR, hM = false, false
        local ok = pcall(function()
            for _, v in pairs(t) do
                if v == r then hR = true
                elseif type(v) == "string" and v:match("^X%-%d+$") then hM = true end
            end
        end)
        return ok and hR and hM
    end

    local function findState(r)
        for l=2,24 do
            local _, fn = pcall(debug.info, l, "f")
            if type(fn) == "function" then
                local _, ups = pcall(debug.getupvalues, fn)
                if type(ups) == "table" then
                    for _, v in pairs(ups) do
                        if looksLikeState(v, r) then return v end
                        if type(v) == "table" then
                            local nested
                            pcall(function()
                                for _, x in pairs(v) do
                                    if looksLikeState(x, r) then nested = x; return end
                                end
                            end)
                            if nested then return nested end
                        end
                    end
                end
            end
        end
    end

    local function mapState(st, a1, a2)
        local m = {}
        for k, v in pairs(st) do
            if type(v) == "string" then
                if v:match("^X%-%d+$") then m.marker = m.marker or k
                elseif a1 and v == a1 then m.arg1 = m.arg1 or k
                elseif a2 and v == a2 then m.arg2 = m.arg2 or k end
            end
        end
        return m
    end

    local model = nil

    local function digits(n)
        n = n % 1000
        return math.floor(n/100), math.floor(n/10)%10, n%10
    end

    local function encode(m, c)
        local d1, d2, d3 = digits(c)
        return m.prefix .. string.char(bxor(d1, m.k1), bxor(d2, m.k2), bxor(d3, m.k3))
    end

    local function learn(r, a1, a2)
        local st = findState(r)
        if not st then return end
        local map = mapState(st, a1, a2)
        if not map.marker then return end
        local c = parseCounter(rawget(st, map.marker))
        if not c then return end
        local d1, d2, d3 = digits(c)
        local m = {
            state = st, map = map, remote = r,
            prefix = a1:sub(1, 9),
            k1 = bxor(a1:byte(10), d1),
            k2 = bxor(a1:byte(11), d2),
            k3 = bxor(a1:byte(12), d3),
            offset = c - os.time(),
            arg2 = a2
        }
        if encode(m, c) == a1 then return m end
    end

    local function liveCounter(m)
        if m.state and m.map.marker then
            local _, raw = pcall(rawget, m.state, m.map.marker)
            local c = parseCounter(raw)
            if c and math.abs((c - os.time()) - m.offset) <= 5 then
                return c
            end
        end
        return os.time() + m.offset
    end

    local function refreshArg2(m)
        if m.state and m.map.arg2 then
            local _, v = pcall(rawget, m.state, m.map.arg2)
            if type(v) == "string" then m.arg2 = v end
        end
        return m.arg2
    end

    local HookFn = hookfunction or replaceclosure or hookfunc or detour_function

    if anyRemote and HookFn then
        local oldFire
        oldFire = HookFn(anyRemote.FireServer, function(self, ...)
            local args = table.pack(...)
            if not remoteSet[self] then
                return oldFire(self, unpack(args, 1, args.n))
            end

            local a1 = args[1]

            if type(a1) == "string" and #a1 == 12 then
                if not model then
                    model = learn(self, a1, args[2])
                else
                    local c = parseCounter(rawget(model.state, model.map.marker))
                    if c and encode(model, c) ~= a1 then
                        local m = learn(self, a1, args[2])
                        if m then m.spoofed = model.spoofed; model = m end
                    end
                end
                return oldFire(self, unpack(args, 1, args.n))
            end

            if model and type(a1) == "string" and #a1 == 4 then
                local c = liveCounter(model)
                args[1] = encode(model, c)
                args[2] = refreshArg2(model)
                model.spoofed = (model.spoofed or 0) + 1
                return oldFire(self, unpack(args, 1, math.max(args.n, 2)))
            end

            return oldFire(self, unpack(args, 1, args.n))
        end)
    end

    task.spawn(function()
        while not HUB.dead do
            task.wait(10)
            local alive = false
            for r in pairs(remoteSet) do
                if r:IsDescendantOf(game) then alive = true; break end
            end
            if not alive then
                table.clear(remoteSet)
                anyRemote = nil
                model = nil
                scanRemotes()
            end
        end
    end)

    -- Real-time Memory Evidence Scrubber for Character Integrity
    task.spawn(function()
        if not getgc then return end
        local st = nil

        local function findIntegrityTable()
            local ok, objs = pcall(getgc, true)
            if ok and objs then
                for _, o in pairs(objs) do
                    if type(o) == "table" then
                        local hit = false
                        pcall(function()
                            hit = (rawget(o, "ValidationLocked") ~= nil and rawget(o, "Evidence") ~= nil)
                                or (rawget(o, "ThreatLevel") ~= nil and rawget(o, "LastObservedSample") ~= nil)
                        end)
                        if hit then return o end
                    end
                end
            end
            return nil
        end

        track(LP.CharacterAdded:Connect(function()
            task.wait(1)
            st = findIntegrityTable()
        end))

        while not HUB.dead do
            if not st then
                st = findIntegrityTable()
            end

            if st then
                pcall(function()
                    local ev = rawget(st, "Evidence")
                    if type(ev) == "table" then
                        if (tonumber(ev.Speed)    or 0) > 0 then rawset(ev, "Speed", 0) end
                        if (tonumber(ev.Teleport) or 0) > 0 then rawset(ev, "Teleport", 0) end
                        if (tonumber(ev.Flight)   or 0) > 0 then rawset(ev, "Flight", 0) end
                    end
                    if rawget(st, "ThreatLevel") ~= "Trusted" then rawset(st, "ThreatLevel", "Trusted") end
                    if rawget(st, "ValidationLocked") == true then rawset(st, "ValidationLocked", false) end
                    if rawget(st, "FirstSuspiciousAt") ~= nil then rawset(st, "FirstSuspiciousAt", nil) end
                    if rawget(st, "KickQueued") == true then rawset(st, "KickQueued", false) end
                    if rawget(st, "TamperScore") ~= nil then rawset(st, "TamperScore", 0) end
                    if rawget(st, "InvalidHeartbeatCount") ~= nil then rawset(st, "InvalidHeartbeatCount", 0) end

                    local los = rawget(st, "LastObservedSample")
                    if los ~= nil then
                        if rawget(st, "LastGameplayTrustedSample") == nil then rawset(st, "LastGameplayTrustedSample", los) end
                        if rawget(st, "LastValidatedSample") == nil then rawset(st, "LastValidatedSample", los) end
                        if rawget(st, "LastValidatedGroundedSample") == nil then rawset(st, "LastValidatedGroundedSample", los) end
                        if rawget(st, "LastConfirmedGroundSample") == nil then rawset(st, "LastConfirmedGroundSample", los) end
                        if rawget(st, "LastGoodSample") == nil then rawset(st, "LastGoodSample", los) end
                    end
                end)
            end
            task.wait(0.2)
        end
    end)
end



-- ============================================================
-- STATE (fitur non-farm)
-- ============================================================
local TRAVEL_SPEED = 250          -- kecepatan glide (Auto Place / Go To Area)
local NeutralizeTraps             -- dipakai ApplyAntiTrap (anti-trap)
local MoveToPoint                 -- locomotion (Auto Place, Go To Area)
local farmEnabled    = false
local farmDelay      = 1.5
local farmSpeed      = 750
local moveMethod     = "Tween Glide"
local targetRarities = {}
local targetAreas    = {}
local targetMutations = {}
local ignoredEggs    = {}
local lingerActive   = false
-- === STEAL FILTER v2  ===
local stealPriority     = "Highest Value"  -- Best Rarity|Biggest Weight|Best Mutation|Highest Value|Lowest Value
local minRarityScore    = 0                -- 0 = off (rarity ini ke atas)
local minStealValue     = 0                -- 0 = off (income/s)
local targetSpecificEggs = {}              -- set AssetCategory (kosong = semua)
local SPECIFIC_EGG_LIST = {}               -- daftar label utk UI
-- === DROP RECOVERY STATE (egg jatuh -> ambil di tempat) ===
local dropRecovery   = true    -- toggle: pulihkan egg jatuh di lapangan
local dropMaxTries   = 3       -- berapa kali coba ambil ulang

-- ============================================================
-- FORCE TARGET EGG (anti "new cycle")
-- ============================================================
-- Masalah: kalau egg target hilang/berubah, farm memulai SIKLUS BARU
-- (balik ke safe zone -> cari egg lain). Yang diinginkan: PAKSA terus
-- mengejar egg yang sama sampai dapat, baru pindah.
-- forceTargetEgg = record egg yang sedang dikejar (UID + posisi).
local forceTargetEgg   = nil   -- { uid=, pos=, areaId=, nestId=, tries=, at= }
local forceMaxTries    = 12    -- batas supaya tidak nyangkut selamanya
local forceEggEnabled  = true  -- toggle UI
local SAFE_WAYPOINT_POS   = Vector3.new(516.4, 70.6, -367.3)
local MAIN_ROAD_Z         = -364.5
local SAFE_BOUNDARY_X     = 580
local SAFE_ZONE_SPEED     = 245

local isBigEgg           -- forward declaration (definisi di section EXTRA FUNCTIONS)
local isMutationAllowed  -- forward declaration (definisi di section EXTRA FUNCTIONS)
-- FIX: NeutralizeTraps dipakai di TravelFlyDirect (L1576) tapi baru
-- didefinisikan di section ANTI-TRAP (L2774) -> nil saat dipanggil.
local NeutralizeTraps
-- FIX: navTo dipakai di PlantAllCarriedEggsInPen (L1317) tapi baru
-- didefinisikan di section DROP RECOVERY (L1800) -> nil saat dipanggil.
local navTo
-- FIX: forceStandUp dipakai di FlyToPoint (L1718) tapi didefinisikan
-- setelahnya (L1909) -> nil saat dipanggil. Forward-declare di sini.
local forceStandUp

-- ============================================================
local S = {
    autoFavoritePets = false,
    autoFusePets = false,
    favRarities = {},
    favNames = {},
    fuseSelectedOnly = false,
    fuseNames = {},
    fuseRarities = {},
    jumpPowerEnabled = false,
    jumpPowerValue = 50,
    infiniteJumpEnabled = false,
    stealBigEggsOnly = false,
    autoHatchEnabled = false,
    autoPlantEnabled = false,
    autoUpgradeBase = false,
    autoUpgradeTreadmill = false,
    autoEquipBestPets = false,
    autoClaimRewards = false,
    autoSellPets = false,
    autoSellEggs = false,
    batAuraEnabled = false,
    batAuraRadius = 20,
    batAuraDelay = 0.2,
    flyEnabled = false,
    flySpeed = 60,
    walkSpeedEnabled = false,
    walkSpeedVal = 24,
    avoidTrapsEnabled = false,
    chaseDropped = true,
    fpsBoost = false,
    reduceMap = false,
    hideAllPets = false,
    hideAllEggs = false,
    hidePlotVisuals = false,
    selectedSellPetRarities = {},
    selectedSellEggRarities = {},
    placeRarities = {},
}



-- MODULE LOADER
-- ============================================================
local EggState, PlotState, AreaEggSlotIdentity
local EggRecordsMod
local EggToolDisplay   -- forward declare (dipakai di isPlayerCarryingEgg)
track(task.spawn(function() pcall(setupBacSpoofer) end))
local function loadModules()
    pcall(function() EggState = require(ReplicatedStorage.Client.EggState) end)
    pcall(function() EggRecordsMod = require(ReplicatedStorage.Shared.Util.EggRecords) end)
    pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)
    pcall(function() PlotState = require(ReplicatedStorage.Client.PlotState) end)
    pcall(function()
        AreaEggSlotIdentity = require(ReplicatedStorage.Shared.Util.AreaEggSlotIdentity)
    end)
    return EggState ~= nil
end
pcall(loadModules)


local function GetNetRemote(name)
    local net = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    return net and net:FindFirstChild(name)
end


-- ============================================================

-- MISSING VARIABLES & HELPERS
-- ============================================================
local SaveModule = nil
pcall(function() SaveModule = require(ReplicatedStorage.Shared.Save) end)

local DEFAULT_LOW_TIER_SELL = {
    ["Common"] = true, ["Uncommon"] = true, ["Rare"] = true,
    ["Epic"] = true, ["Legendary"] = true, ["Mythic"] = true,
}
local SELL_REQUEST_DELAY = 0.1
local function getSellRarityFilter(selected)
    if not selected or not next(selected) then return DEFAULT_LOW_TIER_SELL end
    return selected
end

-- forward-declare: loop ESP lama nyari GLOBAL yang isinya nil karena fungsi
-- ini baru didefinisiin sebagai local di bawah — egg ESP gagal total diem-diem
local GetEggRarityInfo

-- FIX: AssetsData dulu TIDAK pernah dideklarasikan & TIDAK pernah di-assign.
-- Akibatnya getAssetData() selalu balikin {} -> Rarity = "Unknown" terus.
-- Dideklarasikan local di sini, di-require lazy di getAssetData()/ESP.
local AssetsData
local scaleFactor, mutMultiplier   -- forward declare (ESP pakai sebelum definisi)

-- ============================================================
-- ESP  (port library: rich tags + rarity gradient + guards + players + lost parts)
-- ============================================================
-- Ganti ESP lama (1 baris teks + Highlight polos) dengan versi library:
--   • Tag multi-baris: Icon, Name, Rarity, Mutation, Value, Info
--   • Gradient teks mengikuti warna rarity ASLI (RarityGradients)
--   • Guard ESP: Sleeping / Waking Up / Chasing You / Chasing <nama>
--   • Player ESP: Name / Username / Avatar / Tool
--   • Lost Parts ESP: Mechanical Gear / Wiring Harness
--   • Highlight mode: Off / Rare Only / All Shown
HUB.ESP = (function()
    local E = {}
    local W = Workspace

    -- ---------- runtime helpers ----------
    local function uid_name()
        return "c" .. tostring(math.random(100000, 999999))
    end
    local function seq(list)
        local out = {}
        for i, kp in ipairs(list) do out[i] = ColorSequenceKeypoint.new(kp[1], kp[2]) end
        return ColorSequence.new(out)
    end
    local function paletteFromColor(color)
        local W_ = Color3.new(1, 1, 1)
        local B_ = Color3.new(0, 0, 0)
        return {
            Text = seq({ {0, color:Lerp(W_, 0.5)}, {0.4, color:Lerp(W_, 0.1)}, {1, color:Lerp(B_, 0.25)} }),
            Stroke = seq({ {0, color:Lerp(B_, 0.55)}, {0.55, color:Lerp(B_, 0.75)}, {1, color:Lerp(B_, 0.92)} }),
            Outline = color:Lerp(W_, 0.25),
        }
    end

    local P = {}
    P.Sheen  = { Text = seq({{0, Color3.fromRGB(255,255,255)}, {0.5, Color3.fromRGB(222,238,255)}, {1, Color3.fromRGB(255,255,255)}}),
                 Stroke = seq({{0, Color3.fromRGB(8,8,8)}, {1, Color3.fromRGB(8,8,8)}}), Outline = Color3.fromRGB(255,255,255) }
    P.Gold     = paletteFromColor(Color3.fromRGB(255,196,66))
    P.Silver   = paletteFromColor(Color3.fromRGB(214,222,232))
    P.Sakura   = paletteFromColor(Color3.fromRGB(255,158,216))
    P.GreatBloom = paletteFromColor(Color3.fromRGB(124,255,196))
    P.Boss     = paletteFromColor(Color3.fromRGB(255,122,122))
    P.Monstrous = paletteFromColor(Color3.fromRGB(192,139,255))
    P.Accent   = paletteFromColor(Color3.fromRGB(77,255,122))
    P.Red      = paletteFromColor(Color3.fromRGB(255,60,60))
    P.Orange   = paletteFromColor(Color3.fromRGB(255,150,40))
    P.Rainbow  = { Text = seq({{0, Color3.fromRGB(255,107,107)}, {0.2, Color3.fromRGB(255,179,107)},
                               {0.4, Color3.fromRGB(255,240,107)}, {0.6, Color3.fromRGB(107,255,138)},
                               {0.8, Color3.fromRGB(107,200,255)}, {1, Color3.fromRGB(185,107,255)}}),
                   Stroke = seq({{0, Color3.fromRGB(20,20,30)}, {1, Color3.fromRGB(8,8,12)}}),
                   Outline = Color3.fromRGB(255,255,255), Rotation = 0 }
    P.Secret   = { Text = seq({{0, Color3.fromRGB(255,255,255)}, {0.2, Color3.fromRGB(206,212,224)},
                               {0.42, Color3.fromRGB(74,80,94)}, {0.58, Color3.fromRGB(42,46,56)},
                               {0.78, Color3.fromRGB(158,166,182)}, {1, Color3.fromRGB(250,252,255)}}),
                   Stroke = seq({{0, Color3.fromRGB(8,8,8)}, {1, Color3.fromRGB(8,8,8)}}),
                   Outline = Color3.fromRGB(255,255,255), Rotation = 90 }
    local MUT_PALETTE = { Golden = P.Gold, Gold = P.Gold, Silver = P.Silver, Sakura = P.Sakura,
                          GreatBloom = P.GreatBloom, Boss = P.Boss, Monstrous = P.Monstrous, Rainbow = P.Rainbow }

    local fontMain, fontStatus
    pcall(function()
        fontMain = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    end)
    pcall(function()
        fontStatus = Font.new("rbxassetid://12187365977", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    end)
    if not fontStatus then
        pcall(function()
            fontStatus = Font.new("rbxasset://fonts/families/FredokaOne.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        end)
    end

    function E.RowHeight(scale)
        local vp = W.CurrentCamera and W.CurrentCamera.ViewportSize.Y or 1080
        local base = math.clamp(vp * 0.014, 13, 19)
        return math.max(6, math.floor(base * (scale or E.SizeScale or 1)))
    end
    function E.ScaledWidth(w, scale)
        return math.max(30, math.floor(w * (scale or E.SizeScale or 1)))
    end

    local runtime
    function E.CreateRuntime()
        if runtime and runtime.Parent then return runtime end
        local g = Instance.new("ScreenGui")
        g.Name = uid_name()
        g.Archivable = false
        g.ResetOnSpawn = false
        g.IgnoreGuiInset = true
        g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        g.DisplayOrder = 48
        g.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        runtime = g
        return g
    end
    function E.DestroyRuntime()
        if runtime then pcall(function() runtime:Destroy() end); runtime = nil end
    end

    function E.CreateTag(parent, maxDist)
        local bb = Instance.new("BillboardGui")
        bb.Name = uid_name()
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.Adornee = nil
        bb.MaxDistance = (maxDist == math.huge) and 10000 or maxDist
        local frame = Instance.new("Frame")
        frame.Name = uid_name()
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromScale(1, 1)
        frame.Parent = bb
        local lay = Instance.new("UIListLayout")
        lay.FillDirection = Enum.FillDirection.Vertical
        lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
        lay.VerticalAlignment = Enum.VerticalAlignment.Center
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        lay.Parent = frame
        bb.Parent = parent
        return bb, frame
    end

    function E.CreateTextRow(parent, font, order, hScale)
        local frame = Instance.new("Frame")
        frame.Name = uid_name()
        frame.BackgroundTransparency = 1
        frame.BorderSizePixel = 0
        frame.Size = UDim2.fromScale(1, hScale)
        frame.LayoutOrder = order
        frame.Parent = parent

        local function mk(z)
            local l = Instance.new("TextLabel")
            l.Name = uid_name()
            l.BackgroundTransparency = 1
            l.Size = UDim2.fromScale(1, 1)
            l.Text = ""
            l.TextScaled = true
            l.TextStrokeTransparency = 1
            l.TextXAlignment = Enum.TextXAlignment.Center
            l.TextYAlignment = Enum.TextYAlignment.Center
            l.ZIndex = z
            if font then l.FontFace = font else l.Font = Enum.Font.GothamBold end
            l.Parent = frame
            return l
        end
        local shadow = mk(2)
        shadow.Position = UDim2.fromOffset(1, 1)
        shadow.TextColor3 = Color3.new(0, 0, 0)
        shadow.TextTransparency = 0.1
        local label = mk(3)
        label.TextColor3 = Color3.new(1, 1, 1)

        local stroke = Instance.new("UIStroke")
        stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
        stroke.LineJoinMode = Enum.LineJoinMode.Round
        stroke.Color = Color3.new(1, 1, 1)
        stroke.Transparency = 0.05
        stroke.Thickness = 1.2
        pcall(function() stroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize; stroke.Thickness = 0.05 end)
        stroke.Parent = label
        local sg = Instance.new("UIGradient"); sg.Rotation = 90; sg.Parent = stroke
        local tg = Instance.new("UIGradient"); tg.Rotation = 90; tg.Parent = label
        return { Holder = frame, Shadow = shadow, Label = label, StrokeGradient = sg, TextGradient = tg, Palette = nil }
    end

    function E.SetRow(row, text, palette)
        if row.Label.Text ~= text then row.Label.Text = text; row.Shadow.Text = text end
        if palette and row.Palette ~= palette then
            row.Palette = palette
            row.TextGradient.Color = palette.Text
            row.TextGradient.Rotation = palette.Rotation or 90
            row.StrokeGradient.Color = palette.Stroke
        end
    end

    -- ---------- rarity style cache ----------
    local rarityCache = {}
    local function rarityStyle(cat)
        if rarityCache[cat] then return rarityCache[cat] end
        local style = { Name = "?", Number = 0, Color = Color3.fromRGB(255,255,255), Palette = P.Sheen, Icon = nil, Rate = 0, Display = tostring(cat) }
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            local d = AssetsData and (AssetsData.Directory or AssetsData)[cat]
            if type(d) ~= "table" then return end
            local r = d.Rarity
            local rname = "?"
            local rnum = 0
            local rcolor = Color3.fromRGB(255,255,255)
            if type(r) == "table" then
                rname = tostring(r.DisplayName or r._id or "?")
                rnum = tonumber(r.RarityNumber or r.Rank) or 0
                if typeof(r.Color) == "Color3" then rcolor = r.Color end
            elseif type(r) == "string" then
                rname = r
            end
            style.Name = rname
            style.Number = rnum
            style.Color = rcolor
            style.Display = tostring(d.DisplayName or cat)
            style.Rate = tonumber(d.EarningRate) or 0
            -- gradient asli
            local grad
            pcall(function()
                local rg = ReplicatedStorage.Assets.UI.RarityGradients
                local node = rg and rg:FindFirstChild(tostring(r._id or r.DisplayName or rname))
                grad = node and node:FindFirstChild("RarityGradient")
            end)
            if string.upper(rname) == "SECRET" then
                style.Palette = P.Secret
            elseif grad and grad:IsA("UIGradient") then
                style.Palette = { Text = grad.Color, Stroke = paletteFromColor(rcolor).Stroke,
                                  Outline = rcolor:Lerp(Color3.new(1,1,1), 0.25), Rotation = grad.Rotation }
            else
                style.Palette = paletteFromColor(rcolor)
            end
            -- icon
            local icon = d.Icon or d.ImageId or d.Thumbnail or d.AssetId
            if type(icon) == "number" then icon = "rbxassetid://" .. tostring(icon) end
            if type(icon) == "string" and icon ~= "" then style.Icon = icon end
        end)
        rarityCache[cat] = style
        return style
    end
    E.RarityStyle = rarityStyle

    -- ---------- value ----------
    function E.EggValue(rec, style)
        local sc = tonumber(rec.AssetScale) or 1
        local rate = (style and style.Rate) or 0
        return rate * scaleFactor(sc) * mutMultiplier(rec.Mutations)
    end

    -- ---------- number fmt ----------
    local SUF = { "", "K", "M", "B", "T", "Qa", "Qi" }
    local function fmt(n)
        n = tonumber(n) or 0
        local i = 1
        while n >= 1000 and i < #SUF do n = n / 1000; i = i + 1 end
        if i == 1 then return string.format("%.0f", n) end
        return string.format("%.2f%s", n, SUF[i])
    end
    E.Fmt = fmt

    -- ---------- palettes for guard state ----------
    local GUARD_PAL = { Sleeping = P.Accent, Waking = P.Gold, Chasing = P.Red }

    -- ============================================================
    -- GUARD ESP
    -- ============================================================
    local guards, guardConns, guardOn = {}, {}, false
    function E.GuardAreas()
        local w = W:FindFirstChild("World") or W:FindFirstChild("__OBJECTS")
        w = w and w:FindFirstChild("Areas")
        return w and w:FindFirstChild("GuardAreas")
    end
    local function guardRoot(g)
        local h = g:FindFirstChild("HumanoidRootPart")
        if h and h:IsA("BasePart") then return h end
        return g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart", true)
    end
    local function guardStateText(g)
        local st = g:GetAttribute("GuardState")
        local target = g:GetAttribute("TargetPlayer")
        if st == "Sleeping" then return "Sleeping", GUARD_PAL.Sleeping end
        if st == "Waking" or st == "WakingUp" then return "Waking Up", GUARD_PAL.Waking end
        if st == "Chasing" or st == "Awake" then
            if target == LP.UserId then return "Chasing You", GUARD_PAL.Chasing end
            local plr = Players:GetPlayerByUserId(tonumber(target) or -1)
            if plr then return "Chasing " .. plr.DisplayName, GUARD_PAL.Chasing end
            return "Chasing", GUARD_PAL.Chasing
        end
        return "Awake", GUARD_PAL.Waking
    end
    local function guardRemove(g)
        local t = guards[g]
        if not t then return end
        guards[g] = nil
        pcall(function() t.Highlight:Destroy() end)
        pcall(function() t.Tag:Destroy() end)
        for _, c in ipairs(t.Conns) do pcall(function() c:Disconnect() end) end
    end
    local function guardAdd(areaName, g)
        if guards[g] then return end
        local root = guardRoot(g)
        if not root then return end
        local hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.76
        hl.OutlineTransparency = 0.02
        hl.Adornee = g
        hl.Parent = E.CreateRuntime()

        local bb, frame = E.CreateTag(E.CreateRuntime(), math.huge)
        bb.Adornee = root
        local off = 6
        pcall(function()
            local cf, size = g:GetBoundingBox()
            off = cf.Position.Y + size.Y * 0.5 - root.Position.Y + 1
        end)
        bb.StudsOffsetWorldSpace = Vector3.new(0, off, 0)

        local nameRow = E.CreateTextRow(frame, fontStatus, 1, 0.45)
        local stateRow = E.CreateTextRow(frame, fontStatus, 2, 0.55)
        E.SetRow(nameRow, tostring(areaName) .. " Guard", P.Sheen)
        local t = { Highlight = hl, Tag = bb, StateRow = stateRow, Conns = {} }
        guards[g] = t
        local function refresh()
            local txt, pal = guardStateText(g)
            E.SetRow(stateRow, txt, pal)
            hl.FillColor = pal.Outline
            hl.OutlineColor = pal.Outline
            t.Tag.Size = UDim2.fromOffset(E.ScaledWidth(115, E.GuardSize or 0.75),
                math.floor(E.RowHeight(E.GuardSize or 0.75) * 1.6))
        end
        refresh()
        table.insert(t.Conns, g:GetAttributeChangedSignal("GuardState"):Connect(refresh))
        table.insert(t.Conns, g:GetAttributeChangedSignal("TargetPlayer"):Connect(refresh))
        table.insert(t.Conns, g.AncestryChanged:Connect(function()
            if not g:IsDescendantOf(W) then guardRemove(g) end
        end))
    end
    function E.GuardsOn()
        if guardOn then return end
        guardOn = true
        local areas = E.GuardAreas()
        if not areas then return end
        local function watch(area)
            local g = area:FindFirstChild("Guard")
            if g and g:IsA("Model") then guardAdd(area.Name, g) end
            table.insert(guardConns, area.ChildAdded:Connect(function(c)
                if c.Name == "Guard" and c:IsA("Model") then guardAdd(area.Name, c) end
            end))
        end
        for _, a in ipairs(areas:GetChildren()) do watch(a) end
        table.insert(guardConns, areas.ChildAdded:Connect(watch))
    end
    function E.GuardsOff()
        guardOn = false
        for _, c in ipairs(guardConns) do pcall(function() c:Disconnect() end) end
        table.clear(guardConns)
        for g in pairs(guards) do guardRemove(g) end
    end

    -- ============================================================
    -- LOST PARTS ESP
    -- ============================================================
    local lostParts, lostOn = {}, false
    local LOST = { { Id = "LostPart1", Label = "Mechanical Gear" }, { Id = "LostPart2", Label = "Wiring Harness" } }
    local lostPal = paletteFromColor(Color3.fromRGB(255, 216, 61))
    local function lostRemove(id)
        local t = lostParts[id]
        if not t then return end
        lostParts[id] = nil
        pcall(function() t.Highlight:Destroy() end)
        pcall(function() t.Tag:Destroy() end)
    end
    local function lostScan()
        local ev = W:FindFirstChild("DrScrambleEvent")
        for _, def in ipairs(LOST) do
            local m = ev and ev:FindFirstChild(def.Id)
            local hitbox = m and (m:FindFirstChild("Hitbox", true) or m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true))
            local t = lostParts[def.Id]
            if t and (t.Model ~= m or not hitbox) then lostRemove(def.Id); t = nil end
            if hitbox and not t then
                local hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.7
                hl.OutlineTransparency = 0.02
                hl.Adornee = m
                hl.Parent = E.CreateRuntime()
                local bb, frame = E.CreateTag(E.CreateRuntime(), 25000)
                bb.Adornee = hitbox
                bb.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
                local row = E.CreateTextRow(frame, fontMain, 1, 0.4)
                local info = E.CreateTextRow(frame, fontMain, 2, 0.6)
                E.SetRow(row, def.Label, lostPal)
                bb.Size = UDim2.fromOffset(E.ScaledWidth(160, 0.75), math.floor(E.RowHeight(0.75) * 1.8))
                lostParts[def.Id] = { Model = m, Highlight = hl, Tag = bb, Info = info, Hitbox = hitbox }
            end
            local cur = lostParts[def.Id]
            if cur then
                local hp = findHRP()
                local dist = hp and (hp.Position - cur.Hitbox.Position).Magnitude or 0
                E.SetRow(cur.Info, string.format("%d studs", math.floor(dist)), P.Sheen)
            end
        end
    end
    function E.LostOn()
        if lostOn then return end
        lostOn = true
        track(task.spawn(function()
            while not HUB.dead and lostOn do
                task.wait(0.3)
                pcall(lostScan)
            end
        end))
    end
    function E.LostOff()
        lostOn = false
        for id in pairs(lostParts) do lostRemove(id) end
    end

    -- ============================================================
    -- PLAYER ESP
    -- ============================================================
    local players, playerOn = {}, false
    local playerPal = paletteFromColor(Color3.fromRGB(125, 225, 255))
    local function playerRemove(plr)
        local t = players[plr]
        if not t then return end
        players[plr] = nil
        pcall(function() t.Highlight:Destroy() end)
        pcall(function() t.Tag:Destroy() end)
        for _, c in ipairs(t.Conns) do pcall(function() c:Disconnect() end) end
    end
    local function toolIcon(char)
        local tool = char:FindFirstChildWhichIsA("Tool")
        if not tool then return nil end
        local id = tool.TextureId
        if type(id) == "string" and id ~= "" then return id end
        return nil
    end
    local function playerAdd(plr)
        if players[plr] or plr == LP then return end
        local char = plr.Character
        if not char then return end
        local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
        if not head then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local hl = Instance.new("Highlight")
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillColor = Color3.fromRGB(0, 67, 148)
        hl.FillTransparency = 0.76
        hl.OutlineColor = Color3.fromRGB(72, 207, 255)
        hl.OutlineTransparency = 0.02
        hl.Adornee = char
        hl.Parent = E.CreateRuntime()

        local bb, frame = E.CreateTag(E.CreateRuntime(), math.huge)
        bb.Adornee = root
        bb.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
        local row = E.CreateTextRow(frame, fontMain, 1, 0.5)
        local sub = E.CreateTextRow(frame, fontMain, 2, 0.4)
        E.SetRow(row, plr.DisplayName, playerPal)
        local t = { Highlight = hl, Tag = bb, Row = row, Sub = sub, Conns = {} }
        players[plr] = t
        bb.Size = UDim2.fromOffset(E.ScaledWidth(150, 0.75), math.floor(E.RowHeight(0.75) * 2))

        local function refresh()
            local hp = findHRP()
            local d = hp and root and (root.Position - hp.Position).Magnitude or 0
            local parts = { string.format("%dm", math.floor(d)) }
            if E.PlayerInfo and E.PlayerInfo.Username then table.insert(parts, "@" .. plr.Name) end
            if E.PlayerInfo and E.PlayerInfo.Tool then
                local ti = toolIcon(plr.Character or char)
                if ti then table.insert(parts, "has tool") end
            end
            if E.PlayerInfo and E.PlayerInfo.Avatar then
                pcall(function()
                    local ok, img = pcall(function()
                        return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
                    end)
                    if ok and img then E.SetRow(t.Sub, "avatar", playerPal) end
                end)
            else
                E.SetRow(t.Sub, table.concat(parts, "  "), P.Sheen)
            end
        end
        refresh()
        table.insert(t.Conns, char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then refresh() end
        end))
        table.insert(t.Conns, char.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then refresh() end
        end))
        table.insert(t.Conns, char.AncestryChanged:Connect(function()
            if not char:IsDescendantOf(W) then playerRemove(plr) end
        end))
    end
    function E.PlayersOn()
        if playerOn then return end
        playerOn = true
        for _, p in ipairs(Players:GetPlayers()) do task.spawn(playerAdd, p) end
        table.insert(guardConns, Players.PlayerAdded:Connect(function(p) task.spawn(playerAdd, p) end))
        table.insert(guardConns, Players.PlayerRemoving:Connect(playerRemove))
        track(task.spawn(function()
            while not HUB.dead and playerOn do
                task.wait(1)
                for plr, t in pairs(players) do
                    if not plr.Character or not plr.Character:IsDescendantOf(W) then playerRemove(plr) end
                end
            end
        end))
    end
    function E.PlayersOff()
        playerOn = false
        for plr in pairs(players) do playerRemove(plr) end
    end

    -- ============================================================
    -- EGG ESP (rich)
    -- ============================================================
    local eggTags, eggOn = {}, false
    local WEIGHTS = { Icon = 3.2, Name = 1.35, Rarity = 1.2, Mutation = 1, Value = 1.1, Info = 1 }
    E.Info = { Icon = true, Name = true, Rarity = true, Mutation = true, Value = true }
    E.Highlight = "Off"
    E.HighlightMin = 6
    E.MinRarity = 0
    E.MinValue = 0
    E.OwnBase = true
    E.SizeScale = 0.75
    E.FixedSize = false
    E.MaxDistance = math.huge

    local function layout(tag)
        local rows = {
            { tag.IconHolder, WEIGHTS.Icon, tag.ShowIcon },
            { tag.NameRow.Holder, WEIGHTS.Name, tag.ShowName },
            { tag.RarityRow.Holder, WEIGHTS.Rarity, tag.ShowRarity },
            { tag.MutationRow.Holder, WEIGHTS.Mutation, tag.ShowMutation },
            { tag.ValueRow.Holder, WEIGHTS.Value, tag.ShowValue },
            { tag.ExtraRow.Holder, WEIGHTS.Info, tag.ShowExtra },
        }
        local tot = 0
        for _, r in ipairs(rows) do if r[3] then tot = tot + r[2] end end
        local norm = math.max(tot, 1)
        for _, r in ipairs(rows) do
            r[1].Visible = r[3]
            r[1].Size = UDim2.fromScale(1, r[3] and (r[2] / norm) or 0)
        end
        local w = E.ScaledWidth(120, E.SizeScale)
        local h = math.max(1, math.floor(E.RowHeight(E.SizeScale) * norm))
        tag.Billboard.Size = UDim2.fromOffset(w, h)
        tag.Billboard.MaxDistance = E.MaxDistance
    end

    local function makeTag()
        local bb, frame = E.CreateTag(E.CreateRuntime(), E.MaxDistance)
        local iconHolder = Instance.new("Frame")
        iconHolder.BackgroundTransparency = 1
        iconHolder.BorderSizePixel = 0
        iconHolder.Parent = frame
        local img = Instance.new("ImageLabel")
        img.AnchorPoint = Vector2.new(0.5, 1)
        img.Position = UDim2.fromScale(0.5, 1)
        img.Size = UDim2.fromScale(1, 1)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = iconHolder
        local asp = Instance.new("UIAspectRatioConstraint")
        asp.AspectRatio = 1
        asp.DominantAxis = Enum.DominantAxis.Height
        asp.Parent = img
        return {
            Billboard = bb, IconHolder = iconHolder, Icon = img,
            NameRow = E.CreateTextRow(frame, fontMain, 1, 0.4),
            RarityRow = E.CreateTextRow(frame, fontStatus, 2, 0.2),
            MutationRow = E.CreateTextRow(frame, fontMain, 3, 0.2),
            ValueRow = E.CreateTextRow(frame, fontMain, 4, 0.2),
            ExtraRow = E.CreateTextRow(frame, fontMain, 5, 0.2),
            Highlight = nil, ShowIcon = false, ShowName = true,
            ShowRarity = false, ShowMutation = false, ShowValue = false, ShowExtra = false,
            Anchor = nil, AnchorCF = nil,
        }
    end

    -- cari model egg di workspace (AreaEggSlotsClient dulu, lalu rekursif)
    local function findEggModel(uid)
        uid = tostring(uid or "")
        if uid == "" then return nil end
        local slots = W:FindFirstChild("AreaEggSlotsClient")
        local m = slots and slots:FindFirstChild(uid)
        if m then return m end
        local ok, m2 = pcall(function() return W:FindFirstChild(uid, true) end)
        return ok and m2 or nil
    end

    -- ★ PENTING: BillboardGui TANPA Adornee tidak akan tampil sama sekali.
    --   Itu sebabnya ESP versi lama tidak muncul. Di sini kita pasang:
    --     • kalau model egg ketemu  -> Adornee = model
    --     • kalau tidak            -> Adornee = Terrain + StudsOffsetWorldSpace
    local function anchorTag(tag, rec)
        local model = rec.Model or findEggModel(rec.Uid)
        if model then
            if tag.Billboard.Adornee ~= model then
                tag.Billboard.Adornee = model
                tag.Billboard.StudsOffsetWorldSpace = Vector3.new(0, 4, 0)
            end
            tag.Anchor = model
            return
        end
        local cf = rec.BottomCFrame
        if typeof(cf) == "CFrame" then
            local terrain = W.Terrain
            if tag.Anchor ~= terrain or tag.AnchorCF ~= cf then
                tag.Anchor = terrain
                tag.AnchorCF = cf
                tag.Billboard.Adornee = terrain
                tag.Billboard.StudsOffsetWorldSpace =
                    cf.Position - terrain.Position + Vector3.new(0, 3.5, 0)
            end
        end
    end

    local function paint(tag, rec, style)
        local info = E.Info
        local hp = findHRP()
        local sc = tonumber(rec.AssetScale) or 1

        -- ★ pasang posisi tag (WAJIB, kalau tidak -> tidak tampil)
        anchorTag(tag, rec)
        local muts = type(rec.Mutations) == "table" and rec.Mutations or {}
        local baseMut = rec.BaseMutation or muts[1]

        local showIcon = info.Icon == true and style.Icon ~= nil
        if showIcon and tag.Icon.Image ~= tostring(style.Icon) then tag.Icon.Image = tostring(style.Icon) end
        local showName = info.Name == true
        if showName then E.SetRow(tag.NameRow, style.Display, P.Sheen) end
        local showRar = info.Rarity == true and style.Name ~= "?"
        if showRar then E.SetRow(tag.RarityRow, string.upper(style.Name), style.Palette) end
        local showMut = info.Mutation == true and type(baseMut) == "string" and baseMut ~= ""
        if showMut then
            E.SetRow(tag.MutationRow, string.upper(tostring(baseMut)), MUT_PALETTE[baseMut] or P.Sheen)
        end
        local showVal = info.Value == true
        if showVal then E.SetRow(tag.ValueRow, "$" .. fmt(E.EggValue(rec, style)) .. "/s", P.Accent) end

        -- extra line
        local parts = {}
        if info.Weight and EggRecordsMod and EggRecordsMod.WeightKgForScale then
            local ok, w = pcall(EggRecordsMod.WeightKgForScale, rec.AssetCategory, sc)
            if ok and tonumber(w) then table.insert(parts, fmt(w) .. " kg") end
        end
        if info.Size then table.insert(parts, string.format("x%.2f", sc)) end
        if info["Sell Price"] and EggRecordsMod and EggRecordsMod.SellPrice then
            local ok, sp = pcall(EggRecordsMod.SellPrice, rec)
            if ok and tonumber(sp) then table.insert(parts, "$" .. fmt(sp)) end
        end
        if info.Distance and hp and rec.BoundsCFrame then
            table.insert(parts, string.format("%dm", math.floor((hp.Position - rec.BoundsCFrame.Position).Magnitude + 0.5)))
        end
        if info.Area and rec.AreaId then table.insert(parts, tostring(rec.AreaId)) end
        if info.State and rec.State and rec.State ~= "Slot" then table.insert(parts, tostring(rec.State)) end
        local showExtra = #parts > 0
        if showExtra then E.SetRow(tag.ExtraRow, table.concat(parts, "  |  "), P.Sheen) end

        if tag.ShowIcon ~= showIcon or tag.ShowName ~= showName or tag.ShowRarity ~= showRar
           or tag.ShowMutation ~= showMut or tag.ShowValue ~= showVal or tag.ShowExtra ~= showExtra then
            tag.ShowIcon, tag.ShowName, tag.ShowRarity = showIcon, showName, showRar
            tag.ShowMutation, tag.ShowValue, tag.ShowExtra = showMut, showVal, showExtra
            layout(tag)
        end

        -- highlight
        local wantHl = (E.Highlight == "All Shown") or (E.Highlight == "Rare Only" and style.Number >= E.HighlightMin)
        if wantHl and rec.Model then
            if not tag.Highlight then
                local hl = Instance.new("Highlight")
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillTransparency = 0.82
                hl.OutlineTransparency = 0.05
                hl.FillColor = style.Color
                hl.OutlineColor = style.Palette.Outline
                hl.Parent = E.CreateRuntime()
                tag.Highlight = hl
            end
            if tag.Highlight.Adornee ~= rec.Model then tag.Highlight.Adornee = rec.Model end
        elseif tag.Highlight then
            tag.Highlight:Destroy(); tag.Highlight = nil
        end
    end

    local function passFilter(rec, style)
        if rec.State == "Claimed" then return false end
        if E.MinRarity > 0 and style.Number < E.MinRarity then return false end
        if E.MinValue > 0 and E.EggValue(rec, style) < E.MinValue then return false end
        return true
    end

    local function ownBaseEggs()
        local out = {}
        local renders = W:FindFirstChild("PlacedEggRenders")
        if not renders or not EggState or not EggState.ReadOwnerEggs then return out end
        local ok, owned = pcall(EggState.ReadOwnerEggs, LP.UserId)
        if not ok or type(owned) ~= "table" then return out end
        local uid = tostring(LP.UserId)
        local models = {}
        for _, c in ipairs(renders:GetChildren()) do
            if string.find(c.Name, uid, 1, true) then table.insert(models, c) end
        end
        for k, v in pairs(owned) do
            if type(v) == "table" and v.Placement ~= nil and type(v.AssetCategory) == "string" then
                local key = tostring(k)
                local m
                for _, c in ipairs(models) do
                    if c.Name == key or string.find(c.Name, key, 1, true) or c:GetAttribute("Uid") == key then m = c; break end
                end
                if m then
                    local cf
                    pcall(function() cf = m:IsA("Model") and m:GetPivot() or m.CFrame end)
                    table.insert(out, { Uid = "base:" .. key, AssetCategory = v.AssetCategory, AssetScale = v.AssetScale,
                        Mutations = type(v.Mutations) == "table" and v.Mutations or {},
                        BaseMutation = v.BaseMutation, State = "Base", AreaId = "Your Base",
                        BottomCFrame = cf, Model = m })
                end
            end
        end
        return out
    end

    local function render()
        if not eggOn then return end
        local keep = {}
        local records = {}
        if EggState and EggState.ReadFieldEggs then
            local ok, snap = pcall(EggState.ReadFieldEggs)
            if ok and snap and snap.Records then records = snap.Records end
        end
        local all = {}
        for _, r in ipairs(records) do table.insert(all, r) end
        if E.OwnBase then
            for _, r in ipairs(ownBaseEggs()) do table.insert(all, r) end
        end
        for _, rec in ipairs(all) do
            if type(rec.Uid) == "string" and type(rec.AssetCategory) == "string" then
                local style = rarityStyle(rec.AssetCategory)
                if passFilter(rec, style) then
                    keep[rec.Uid] = true
                    local tag = eggTags[rec.Uid]
                    if not tag then tag = makeTag(); eggTags[rec.Uid] = tag end
                    paint(tag, rec, style)
                end
            end
        end
        for uid, tag in pairs(eggTags) do
            if not keep[uid] then
                if tag.Highlight then pcall(function() tag.Highlight:Destroy() end) end
                pcall(function() tag.Billboard:Destroy() end)
                eggTags[uid] = nil
            end
        end
    end

    function E.EggsOn()
        if eggOn then return end
        eggOn = true
        track(task.spawn(function()
            while not HUB.dead and eggOn do
                pcall(render)
                task.wait(0.4)
            end
        end))
    end
    function E.EggsOff()
        eggOn = false
        for uid, tag in pairs(eggTags) do
            if tag.Highlight then pcall(function() tag.Highlight:Destroy() end) end
            pcall(function() tag.Billboard:Destroy() end)
        end
        table.clear(eggTags)
    end
    function E.Relayout()
        for _, tag in pairs(eggTags) do tag.ShowIcon = nil; layout(tag) end
    end

    function E.SetSizeScale(pct)
        E.SizeScale = math.clamp((tonumber(pct) or 75) / 100, 0.5, 2)
        E.Relayout()
    end
    function E.SetGuardSize(pct)
        E.GuardSize = math.clamp((tonumber(pct) or 75) / 100, 0.5, 2)
    end

    function E.AllOff()
        E.EggsOff(); E.GuardsOff(); E.PlayersOff(); E.LostOff()
    end

    return E
end)()

-- RARITY & AREA DICTIONARIES
-- ============================================================
local RARITY_SCORE_MAP = {
    ["Light & Dark"]=2200, ["LightDark"]=2200, ["Light &Dark"]=2200,
    Exclusive=2100, Admin=2100,
    Mythical=2000, ["Squishy God"]=2000, BrainrotGod=2000,
    Brainrot=1900,
    Eternal=1800, Rainbow=1700, Prismatic=1600, Transcendent=1500,
    Celestial=1400, Cosmic=1300,
    Titan=1200, Superior=1200,
    Secret=1100, Divine=1000,
    Limited=900, Exotic=800, SuperRare=700,
    Mythic=600, Legendary=500, Epic=400, Rare=300,
    Uncommon=200, Common=100,
}
local RARITY_NAMES = {
    "Light & Dark","Exclusive","Admin","Mythical","Squishy God","BrainrotGod","Brainrot",
    "Eternal","Rainbow","Prismatic","Transcendent","Celestial","Cosmic",
    "Titan","Superior","Secret","Divine","Limited","Exotic","SuperRare",
    "Mythic","Legendary","Epic","Rare","Uncommon","Common"
}
local AREA_NAMES = {
    "Forest","Lake","Desert","Jungle","Snow","Volcano",
    "Abyss Ocean","Prehistoric","Cosmic","Cherry Blossom","Titan Temple",
    "Light Dark",
}

local AREA_COORDINATES = {
    ["Base / Plot"]    = Vector3.new(491.7, 70.4, -364.4),
    ["Forest"]         = Vector3.new(596.0, 68.0, -328.0),
    ["Lake"]           = Vector3.new(744.0, 68.5, -408.0),
    ["Desert"]         = Vector3.new(948.0, 69.5, -323.0),
    ["Jungle"]         = Vector3.new(1188.0, 68.5, -408.0),
    ["Snow"]           = Vector3.new(1492.0, 69.0, -315.0),
    ["Volcano"]        = Vector3.new(1882.0, 68.0, -398.0),
    ["Abyss Ocean"]    = Vector3.new(2280.0, 68.0, -326.0),
    ["Prehistoric"]    = Vector3.new(2812.0, 69.0, -398.0),
    ["Cosmic"]         = Vector3.new(3390.0, 68.0, -324.0),
    ["Cherry Blossom"] = Vector3.new(4028.0, 68.5, -396.0),
    ["Titan Temple"]   = Vector3.new(4796.0, 69.5, -328.0),
    ["Light Dark"]     = Vector3.new(5660.0, 70.0, -331.0),
}

-- ============================================================
-- EGG HELPERS
-- ============================================================
local _assetCache = {}
local function getAssetData(record)
    if not record then return {} end
    local item = type(record.ItemData) == "table" and record.ItemData or record
    local cat = item.AssetCategory or item.Category or record.AssetCategory or record.Category
    -- FIX: AssetsData dulu tidak pernah di-assign -> Rarity selalu "Unknown".
    -- Lazy-require di sini (sekali) biar getRarityName bisa baca Rarity._id.
    if not AssetsData then
        pcall(function() AssetsData = require(ReplicatedStorage.Data.Assets) end)
    end
    if AssetsData and cat then
        local cached = _assetCache[cat]
        if cached then return cached end
        local ok, d = pcall(function()
            return (AssetsData.Directory or AssetsData)[cat] or {}
        end)
        if ok and d and next(d) then
            _assetCache[cat] = d
            return d
        end
    end
    return {
        EarningRate = record.EarningRate,
        ModelWeight = record.ModelWeight,
        DropWeight  = record.DropWeight,
        DisplayName = cat or record.DisplayName,
        Rarity      = record.Rarity,
        _id         = cat,
    }
end



local _rarityKeyMap = nil
local function buildRarityKeyMap()
    _rarityKeyMap = {}
    for canon, _ in pairs(RARITY_SCORE_MAP) do
        _rarityKeyMap[canon:lower():gsub("[^%a%d]", "")] = canon
    end
    _rarityKeyMap.lightdark = "Light & Dark"
    _rarityKeyMap.mythical  = "Mythical"
    _rarityKeyMap.brainrotgod = "BrainrotGod"
    _rarityKeyMap.brainrot  = "Brainrot"
    _rarityKeyMap.squishygod = "Squishy God"
    _rarityKeyMap.superrare = "SuperRare"
end

local function normalizeRarityName(name)
    if not name then return nil end
    local s = tostring(name)
    if RARITY_SCORE_MAP[s] then return s end
    if not _rarityKeyMap then buildRarityKeyMap() end
    local key = s:lower():gsub("[^%a%d]", "")
    return _rarityKeyMap[key] or s
end

-- getRarityName: read record.Rarity._id directly (most reliable)
local function getRarityName(record)
    local item = (record and type(record.ItemData) == "table") and record.ItemData or record
    if item then
        local r = item.Rarity or item.RarityTier or item.Tier
        if r then
            if type(r) == "table" and r._id then return normalizeRarityName(r._id) end
            if type(r) == "string" then return normalizeRarityName(r) end
        end
    end
    local d = getAssetData(record)
    return normalizeRarityName((d.Rarity and d.Rarity._id) or d.Rarity) or "Unknown"
end

-- assigned ke forward-declare di atas (deket blok ESP) biar loop ESP kebaca
GetEggRarityInfo = function(egg)
    if not egg then return "Common", 100 end
    local name = getRarityName(egg)
    -- FIX: kalau rarity tak dikenal, coba baca langsung dari AssetDirectory
    if (not name or name == "Unknown") then
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            local cat = egg.AssetCategory or (egg.ItemData and egg.ItemData.AssetCategory)
            local d = cat and ((AssetsData.Directory or AssetsData)[cat])
            local r = d and (d.Rarity or d.RarityTier or d.Tier)
            if type(r) == "table" then r = r._id or r.DisplayName or r.Name end
            if r then name = normalizeRarityName(tostring(r)) or name end
        end)
    end
    if not name or name == "" then name = "Unknown" end
    local score = RARITY_SCORE_MAP[name] or 100
    return name, score
end

local function isRarityAllowed(name, filter)
    local f = filter or targetRarities
    if not f or not next(f) then return true end
    -- FIX: dulu "Unknown" selalu lolos walau filter diset -> farm ambil egg sembarangan.
    -- Sekarang: Unknown ditolak kalau filter aktif (biar egg terbaik yang diambil).
    if not name or name == "" then return true end
    if name == "Unknown" then return false end
    -- Direct match
    if f[name] == true then return true end
    -- Case-insensitive match
    local nameLower = string.lower(tostring(name))
    for k, v in pairs(f) do
        if v == true and type(k) == "string" and string.lower(k) == nameLower then
            return true
        end
    end
    return false
end

-- ============================================================
-- VALUE MODEL (EarningRate * curve * mutation)
-- ============================================================
local _mutMod = nil
mutMultiplier = function(muts)
    if _mutMod == nil then
        _mutMod = false
        pcall(function() _mutMod = require(ReplicatedStorage.Shared.Modules.Mutations) end)
    end
    if _mutMod and _mutMod.EarningsFor then
        local ok, r = pcall(_mutMod.EarningsFor, muts)
        if ok and tonumber(r) then return tonumber(r) end
    end
    return 1
end

scaleFactor = function(s)
    s = tonumber(s) or 0
    if s <= 0 then return 0 end
    if s > 5 then return (s / 5) ^ 1.2 * 19.637875755794113 end
    return s ^ 1.85
end

-- ============================================================
-- EGG TOOL DISPLAY (dibutuhkan isPlayerCarryingEgg / hasEggToolAnywhere)
-- ============================================================
pcall(function() EggToolDisplay = require(RS.Shared.Eggs.EggToolDisplay) end)

local function SetNoKnockback(enabled)
    if enabled then
        pcall(function()
            local rigSync = GetNetRemote("RE/RigSync/Refresh")
            if rigSync and getconnections then
                for _, conn in ipairs(getconnections(rigSync.OnClientEvent)) do
                    pcall(function() conn:Disconnect() end)
                end
            end
        end)
    end
end
pcall(function() SetNoKnockback(true) end)


local function DeleteOwnPetRenders()
    local count = 0
    local function sweep(container)
        if not container then return end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") or child:IsA("BasePart") then
                pcall(function() child:Destroy(); count = count + 1 end)
            end
        end
    end
    sweep(Workspace:FindFirstChild("Pets"))
    sweep(Workspace:FindFirstChild("RenderedPets"))
    return count
end

-- ============================================================
-- AUTO PLACE EGGS
-- ============================================================
local function placeRarityOk(rec)
    if not next(S.placeRarities) then return true end
    local rName = GetEggRarityInfo(rec)
    return isRarityAllowed(rName, S.placeRarities)
end

local function PlantAllCarriedEggsInPen()
    -- ============================================================
    -- VERSI REMOTE — paling akurat
    -- ============================================================
    -- Referensi (referensi) membuktikan remote ASLI:
    --   RF/EggWorld/AskWearTool :InvokeServer(uid)              -> string
    --   RF/EggWorld/AskPlaceEgg :InvokeServer({Uid=, LocalCFrame=})
    --
    -- Ini BEDA dari EggState.PlantEgg (yang dipakai Ref 1) — dan
    -- EggState.PlantEgg tidak selalu jalan karena butuh state internal
    -- yang tidak selalu tersinkron. Remote langsung = jalur resmi client.
    --
    -- Bentuk LocalCFrame (persis):
    --   CFrame.new(-11.57, -0.50011444091796875, 14.009, -1,0,0, 0,1,0, 0,0,-1)
    --   -> Y selalu -0.50011444091796875 (ketinggian tanam)
    --   -> rotasi menghadap +Z lokal (matrix -1,0,0, 0,1,0, 0,0,-1)
    -- ============================================================
    if not LP.Character then return 0 end
    if not PlotState then return 0 end

    local myPlot = nil
    pcall(function() myPlot = PlotState.ResolvePlot() end)
    if not myPlot or not myPlot.CenterPoint or not myPlot.PetArea then return 0 end

    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local placeRemote = net and net:FindFirstChild("RF/EggWorld/AskPlaceEgg")
    local wearRemote  = net and net:FindFirstChild("RF/EggWorld/AskWearTool")
    if not placeRemote then
        print("[PLACE] remote AskPlaceEgg tidak ketemu")
        return 0
    end

    local petArea   = myPlot.PetArea
    local centerCF  = myPlot.CenterPoint.CFrame
    local basePetPos = petArea.Position

    -- ============================================================
    -- FIX #3: SLOT EGG — biar TIDAK MENUMPUK di satu titik.
    -- ============================================================
    -- Masalah lama: offset dihitung dari `basePetPos` (tengah PetArea)
    -- dengan grid mulai dari 0 SETIAP run, jadi egg selalu mendarat di
    -- posisi yang sama -> terlihat seperti "cuma 1 telur".
    --
    -- Sekarang:
    --   1. Offset acak DI DALAM footprint PetArea (bukan grid tetap).
    --   2. Cek jarak ke egg yang sudah ada di pen (dari record
    --      Placement.LocalCFrame) -> kalau < MIN_GAP, cari titik lain.
    --   3. Y & ROTASI tetap persis seperti referensi.
    local PLANT_Y   = -0.50011444091796875
    local PLANT_R00, PLANT_R01, PLANT_R02 = -1, 0, 0
    local PLANT_R10, PLANT_R11, PLANT_R12 =  0, 1, 0
    local PLANT_R20, PLANT_R21, PLANT_R22 =  0, 0, -1

    -- (usedSlots + nextLocalCFrame DIPINDAH ke bawah, setelah `owned` diisi —
    --  dulu dipakai di sini padahal `owned` belum di-assign => selalu kosong
    --  => egg bisa menumpuk. Lihat blok FIX A di bawah.)

    -- ============================================================
    -- FIX #1: KARAKTER HARUS DI PLOT DULU
    -- ============================================================
    -- Server menolak AskPlaceEgg kalau karakter jauh dari plot
    -- ("Get closer to your area to place an egg!"). Dulu tidak ada
    -- langkah ini -> place gagal / hanya 1 yang masuk.
    local plotPos = myPlot.CenterPoint.Position
    local hrpNow  = findHRP()
    if hrpNow and (hrpNow.Position - plotPos).Magnitude > 12 then
        print("[PLACE] pindah ke plot dulu...")
        MoveToPoint(plotPos, 300)
        task.wait(0.35)
        hrpNow = findHRP()
        if hrpNow and (hrpNow.Position - plotPos).Magnitude > 25 then
            -- masih jauh -> snap langsung (plot = zona aman, tidak ada AC di sini)
            hrpNow.CFrame = CFrame.new(plotPos + Vector3.new(0, 3, 0))
            hrpNow.AssemblyLinearVelocity  = Vector3.zero
            hrpNow.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.4)
        end
    end

    -- Sinkronkan daftar egg dulu (kalau tersedia).
    -- CEPAT: dulu selalu task.wait(0.35). Sekarang hanya tunggu kalau
    -- data lokal masih kosong.
    local hadData = false
    pcall(function()
        if EggState then
            local rd = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
            if rd then
                local ok, snap = pcall(rd, LP.UserId)
                if ok and type(snap) == "table" and next(snap.Records or snap) then hadData = true end
            end
        end
    end)
    pcall(function() if EggState and EggState.SyncOwnedEggs then EggState.SyncOwnedEggs() end end)
    task.wait(hadData and 0.08 or 0.3)

    -- Ambil daftar egg yang dimiliki
    local owned = nil
    pcall(function()
        if EggState then
            local reader = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
            if reader then owned = reader(LP.UserId) end
        end
    end)
    if type(owned) == "table" and owned.Records then owned = owned.Records end

    if type(owned) ~= "table" then
        -- Fallback: scan Tool egg di Character/Backpack
        owned = {}
        local function addEggTools(container)
            if not container then return end
            for _, t in ipairs(container:GetChildren()) do
                if t:IsA("Tool") then
                    local itype = t:GetAttribute("ItemType")
                    if itype == "AssetEgg" or itype == "PetEgg" then
                        local uid = t:GetAttribute("Uid") or t:GetAttribute("UID")
                        if not uid and EggToolDisplay and EggToolDisplay.GetToolUid then
                            pcall(function() uid = EggToolDisplay.GetToolUid(t) end)
                        end
                        if uid then owned[uid] = { Uid = uid } end
                    end
                end
            end
        end
        pcall(function() addEggTools(LP.Character) end)
        pcall(function() addEggTools(LP:FindFirstChild("Backpack")) end)
    end

    -- ============================================================
    -- FIX A + PERLUAS AREA PLACE + PERCEPAT
    -- ============================================================
    -- BUG yang diperbaiki: blok ini dulu ada DI ATAS (sebelum `owned` diisi),
    -- jadi `type(owned) == "table"` selalu false -> usedSlots KOSONG ->
    -- posisi egg tidak dicek -> bisa menumpuk.
    --
    -- PERLUAS: margin tepi 3 -> 1.2 stud, MIN_GAP 3.2 -> 2.3 stud, dan
    -- ada mode "extend" yang mencoba cincin kedua di luar PetArea kalau
    -- bagian dalam sudah penuh.
    -- ★ FIX "auto place cuma bisa sekali": server MENOLAK AskPlaceEgg kalau
    --   titik yang diminta sama dengan egg yang sudah ada. Dulu `usedSlots`
    --   di-reset SETIAP panggilan -> run ke-2 memilih titik yang sama lagi
    --   -> ditolak semua. Sekarang simpan slot di HUB (persist antar run).
    HUB._placeSlots = HUB._placeSlots or {}
    local usedSlots = HUB._placeSlots
    if type(owned) == "table" then
        for _, r2 in pairs(owned) do
            if type(r2) == "table" and r2.Placement ~= nil then
                local lc = nil
                if type(r2.Placement) == "table" then
                    lc = r2.Placement.LocalCFrame
                    -- bentuk lain: Placement.CFrame / Placement.Position
                    if not lc and typeof(r2.Placement.CFrame) == "CFrame" then lc = r2.Placement.CFrame end
                elseif typeof(r2.Placement) == "CFrame" then
                    lc = r2.Placement
                end
                if typeof(lc) == "CFrame" then
                    usedSlots[#usedSlots + 1] = { x = lc.X, z = lc.Z }
                end
            end
        end
    end
    -- batasi memori (kalau egg sudah di-hatch/dijual, slot lama tak berguna)
    if #usedSlots > 400 then
        local trimmed = {}
        for i = #usedSlots - 199, #usedSlots do trimmed[#trimmed + 1] = usedSlots[i] end
        HUB._placeSlots = trimmed
        usedSlots = trimmed
    end

    local MIN_GAP   = 2.3            -- lebih rapat -> lebih banyak muat
    local EDGE      = 1.2            -- margin tepi lebih kecil -> area lebih luas
    local halfX     = math.max(1, petArea.Size.X * 0.5 - EDGE)
    local halfZ     = math.max(1, petArea.Size.Z * 0.5 - EDGE)
    -- cincin cadangan (kalau dalam pen sudah padat)
    local extX      = halfX + math.min(6, petArea.Size.X * 0.25)
    local extZ      = halfZ + math.min(6, petArea.Size.Z * 0.25)

    local function slotFree(ox, oz, gap)
        for _, u in ipairs(usedSlots) do
            local dx, dz = ox - u.x, oz - u.z
            if (dx * dx + dz * dz) < (gap * gap) then return false end
        end
        return true
    end



    -- ★ FIX: LocalCFrame harus titik LOKAL terhadap CenterPoint.
    --   library (yang terbukti jalan) pakai:
    --       localPos = centerCF:PointToObjectSpace(basePetPos + offset)
    --       return CFrame.new(localPos) * rot
    --   Ascend dulu pakai offset mentah -> posisi meleset/overlap -> server tolak.
    local function makeLocal(ox, oz)
        local world = basePetPos + Vector3.new(ox, 0, oz)
        local lp = centerCF:PointToObjectSpace(world)
        return CFrame.new(lp.X, PLANT_Y, lp.Z) * CFrame.fromMatrix(
            Vector3.zero,
            Vector3.new(0, 0, -1),
            Vector3.new(0, 1, 0),
            Vector3.new(1, 0, 0)
        )
    end

    local function nextLocalCFrame()
        -- 1. coba di dalam PetArea dulu (paling aman)
        for _ = 1, 25 do
            local ox = (math.random() * 2 - 1) * halfX
            local oz = (math.random() * 2 - 1) * halfZ
            if slotFree(ox, oz, MIN_GAP) then
                usedSlots[#usedSlots + 1] = { x = ox, z = oz }
                return makeLocal(ox, oz)
            end
        end
        -- 2. area diperluas (masih dalam plot, sedikit di luar PetArea)
        for _ = 1, 25 do
            local ox = (math.random() * 2 - 1) * extX
            local oz = (math.random() * 2 - 1) * extZ
            if slotFree(ox, oz, MIN_GAP) then
                usedSlots[#usedSlots + 1] = { x = ox, z = oz }
                return makeLocal(ox, oz)
            end
        end
        -- 3. benar-benar penuh -> jarak dirapatkan
        for _ = 1, 15 do
            local ox = (math.random() * 2 - 1) * extX
            local oz = (math.random() * 2 - 1) * extZ
            if slotFree(ox, oz, MIN_GAP * 0.7) then
                usedSlots[#usedSlots + 1] = { x = ox, z = oz }
                return makeLocal(ox, oz)
            end
        end
        -- 4. menyerah -> titik acak terakhir
        local ox, oz = (math.random() * 2 - 1) * extX, (math.random() * 2 - 1) * extZ
        usedSlots[#usedSlots + 1] = { x = ox, z = oz }
        return makeLocal(ox, oz)
    end

    -- ============================================================
    -- FIX #2: LOOP — dulu pakai `break` saat uid bukan string, jadi
    -- loop BERHENTI TOTAL dan hanya 0-1 egg yang ke-place.
    -- Sekarang: pakai `continue` (lewati item itu saja), dan hitung
    -- setiap alasan skip biar kelihatan di console.
    -- ============================================================
    local placed, failed = 0, 0
    local skippedPlaced, skippedRarity, skippedBad = 0, 0, 0
    local ignoredPlace = nil
    local total = 0
    for _ in pairs(owned) do total = total + 1 end
    local MAX_PER_RUN = 30

    for uid, rec in pairs(owned) do
        if placed >= MAX_PER_RUN then break end
        if not farmEnabled and not S.autoPlantEnabled then break end

        -- uid bisa jadi key (string) atau field rec.Uid
        if type(uid) ~= "string" then
            if type(rec) == "table" and type(rec.Uid) == "string" then
                uid = rec.Uid
            else
                skippedBad = skippedBad + 1
                continue          -- <- dulu `break` di sini = bug
            end
        end

        -- lewati yang sudah ada di pen
        if type(rec) == "table" and rec.Placement ~= nil then
            skippedPlaced = skippedPlaced + 1
            continue
        end

        -- filter RARITY (bukan area!) — kalau dropdown diisi
        if next(S.placeRarities) and type(rec) == "table" then
            if not placeRarityOk(rec) then
                skippedRarity = skippedRarity + 1
                continue
            end
        end

        -- 1. WEAR egg tool (server butuh ini sebelum place).
        --    ★ library: kalau ada Tool di Backpack, pindah ke Character
        --    dulu; kalau tidak ada, panggil AskWearTool.
        local equipped = false
        local bp = LP:FindFirstChild("Backpack")
        if bp then
            for _, t in ipairs(bp:GetChildren()) do
                if t:IsA("Tool") then
                    local it = t:GetAttribute("ItemType")
                    if it == "AssetEgg" or it == "PetEgg" then
                        pcall(function() t.Parent = LP.Character end)
                        equipped = true
                        task.wait(0.12)
                        break
                    end
                end
            end
        end
        if not equipped and wearRemote then
            pcall(function() wearRemote:InvokeServer(uid) end)
            task.wait(0.15)
        end

        -- 2. PLACE dengan CFrame lokal ke CenterPoint.
        --    CEPAT: 0.12 -> 0.05. Kalau gagal, langsung coba titik lain
        --    (tanpa nunggu) supaya total waktu tetap kecil.
        local localCFrame = nextLocalCFrame()
        local ok3, res = pcall(function()
            return placeRemote:InvokeServer({ Uid = uid, LocalCFrame = localCFrame })
        end)
        if ok3 and res == true then
            placed = placed + 1
            task.wait(0.05)
        else
            -- ★ FIX: kalau titik PERTAMA ditolak, slot itu tetap ditandai
            --   terpakai (makeCF sudah menambahkannya) -> retry pakai titik BARU.
            task.wait(0.03)
            local retryCF = nextLocalCFrame()
            local ok4, res2 = pcall(function()
                return placeRemote:InvokeServer({ Uid = uid, LocalCFrame = retryCF })
            end)
            if ok4 and res2 == true then
                placed = placed + 1
            else
                failed = failed + 1
                -- retry juga gagal -> jangan coba uid ini lagi di run berikutnya
                ignoredPlace = ignoredPlace or {}
                ignoredPlace[uid] = true
            end
            task.wait(0.05)
        end
    end

    print(string.format(
        "[PLACE] berhasil=%d gagal=%d | total=%d skip(sudah-ditaruh=%d rarity=%d invalid=%d)",
        placed, failed, total, skippedPlaced, skippedRarity, skippedBad))
    return placed
end




-- ============================================================
-- ============================================================
-- LOCOMOTION  (dipakai Base "Auto Place Eggs" & Player "Go To Area")
-- ============================================================
MoveToPoint = function(target, speed)
    local hrp = findHRP()
    if not hrp or not target then return false end
    speed = math.clamp(tonumber(speed) or TRAVEL_SPEED, 20, 750)
    local t0 = os.clock()
    while not HUB.dead do
        local dt = RunService.Heartbeat:Wait()
        dt = math.clamp(dt, 0.001, 1 / 30)
        hrp = findHRP()
        if not hrp then break end
        local toTarget = target - hrp.Position
        local remain = toTarget.Magnitude
        if remain < 1.5 then break end
        local step = math.min(speed * dt, remain)
        local nextPos = hrp.Position + toTarget.Unit * step
        hrp.CFrame = CFrame.lookAt(nextPos, nextPos + toTarget.Unit)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if os.clock() - t0 > 20 then break end
    end
    return true
end
pcall(function()
    local pps = game:GetService("ProximityPromptService")
    track(pps.PromptButtonHoldBegan:Connect(function(prompt, player)
        if player == LP and prompt.Name == "CarryAreaEgg" then
            prompt.HoldDuration = 0
        end
    end))
end)


-- ============================================================
-- BASE & AUTOMATION FUNCTIONS (from Update 2)
-- ============================================================
-- FIX: hatch PER TELUR, satu per satu dengan jeda.
-- Versi lama loop semua egg dalam satu panggilan tanpa jeda nyata
-- (task.wait(0.05) di dalam pcall) -> frame drop & server tolak.
-- Sekarang: ambil daftar uid siap-hatch, lalu proses SATU PER SATU,
-- dengan jeda antar telur supaya tidak membebani frame.
local _hatchQueue = {}
local _hatching = false

local function HatchAllReadyEggs()
    -- ============================================================
    -- VERSI REMOTE 
    -- ============================================================
    -- Referensi:
    --   RF/EggWorld/AskHatch :InvokeServer("589eca8c628249b4978a2ff2931a84a2")
    --   -> satu argumen: UID (string)
    --
    -- Alur lengkap (library lain):
    --   AskHatch:InvokeServer(uid)         -- mulai hatch
    --   task.wait(...)
    --   AskFinishHatch:InvokeServer(uid)   -- selesaikan
    --   -> RemoteFunction, return (true, ?, petUid) kalau BERHASIL
    --
    -- Ini BEDA dari EggState.BeginHatch/FinishHatch yang gw pakai dulu —
    -- itu tidak ada / tidak tersinkron, makanya auto hatch tidak jalan.
    --
    -- DIPROSES PER TELUR (permintaan user): satu egg, jeda, baru egg
    -- berikutnya. Kalau semua sekaligus -> frame drop.
    -- ============================================================
    if _hatching then return 0 end
    if not EggState then
        print("[HATCH] EggState tidak ada")
        return 0
    end
    _hatching = true

    local net = RS:FindFirstChild("Packages") and RS.Packages:FindFirstChild("Networking")
    local AskHatch       = net and net:FindFirstChild("RF/EggWorld/AskHatch")
    local AskFinishHatch = net and net:FindFirstChild("RF/EggWorld/AskFinishHatch")
    if not AskHatch and not AskFinishHatch then
        print("[HATCH] remote AskHatch/AskFinishHatch tidak ketemu")
        _hatching = false
        return 0
    end

    -- sinkronkan daftar egg dulu (dulu 0.3 -> 0.12, cukup untuk refresh)
    pcall(function() if EggState.SyncOwnedEggs then EggState.SyncOwnedEggs() end end)
    task.wait(0.12)

    -- baca egg yang dimiliki: {[uid] = record}
    local owned = nil
    pcall(function()
        local reader = EggState.ReadOwnerEggs or EggState.ReadOwnedEggs
        if reader then owned = reader(LP.UserId) end
    end)
    if type(owned) == "table" and owned.Records then owned = owned.Records end
    if type(owned) ~= "table" then
        print("[HATCH] ReadOwnerEggs kosong")
        _hatching = false
        return 0
    end

    -- kumpulkan UID (key string ATAU rec.Uid) — jangan `break` saat aneh
    table.clear(_hatchQueue)
    for uid, rec in pairs(owned) do
        local u = nil
        if type(uid) == "string" then
            u = uid
        elseif type(rec) == "table" and type(rec.Uid) == "string" then
            u = rec.Uid
        end
        if u then _hatchQueue[#_hatchQueue + 1] = u end
    end

    if #_hatchQueue == 0 then
        _hatching = false
        return 0
    end

    -- ============================================================
    -- PERCEPAT: dulu jeda 0.4s x2 = 0.8s per telur (LAMA).
    -- Hub lain (library lain) pakai 0.05s.
    -- Sekarang: 0.08s antar panggilan — masih memberi server waktu
    -- memproses, tapi 5x lebih cepat dari sebelumnya.
    -- ============================================================
    local HATCH_GAP = 0.08

    local hatched = 0
    for i = 1, #_hatchQueue do
        local uid = _hatchQueue[i]
        if not S.autoHatchEnabled then break end

        -- 1. mulai hatch
        if AskHatch then
            pcall(function() AskHatch:InvokeServer(uid) end)
            task.wait(HATCH_GAP)
        end

        -- 2. selesaikan hatch — return true kalau berhasil
        if AskFinishHatch then
            local ok, r1, r2, petUid = pcall(function()
                return AskFinishHatch:InvokeServer(uid)
            end)
            if ok and r1 == true then
                hatched = hatched + 1
            end
        end

        -- jeda antar telur (bukan tiap panggilan) -> tidak nge-frame
        task.wait(HATCH_GAP)
    end

    -- ringkas: 1 baris untuk semua, bukan 1 baris per telur
    if hatched > 0 then
        print("[HATCH] " .. hatched .. "/" .. #_hatchQueue .. " telur berhasil di-hatch")
    end

    _hatching = false
    print("[HATCH] " .. hatched .. "/" .. #_hatchQueue .. " telur berhasil di-hatch")
    return hatched
end

local function UpgradeHomesteadBase()
    local r1 = GetNetRemote("RE/Homestead/AskNearbyPurchase")
    if r1 then pcall(function() r1:FireServer() end) end
    local r2 = GetNetRemote("RE/Homestead/AskBaseTierRaise")
    if r2 then pcall(function() r2:FireServer() end) end
end

local function UpgradeTreadmillTier()
    local rf = GetNetRemote("RF/Treadmill/AskTierRaise")
    if rf then pcall(function() rf:InvokeServer() end) end
end

local function EquipBestPets()
    -- FIX: dulu cuma coba 2 remote dan tidak lapor kalau gagal.
    -- Sekarang: coba SEMUA kandidat remote, dan kembalikan jumlah yang berhasil.
    local CANDIDATES = {
        "RF/Haul/WearBest",
        "RF/PenRoster/ConfirmEquipBestBadge",
        "RF/PenRoster/ConfirmPetsBadge",
        "RF/Haul/FetchWearBestStatus",
    }
    local okCount = 0
    for _, name in ipairs(CANDIDATES) do
        local rf = GetNetRemote(name)
        if rf then
            local ok = pcall(function()
                if rf:IsA("RemoteFunction") then rf:InvokeServer()
                else rf:FireServer() end
            end)
            if ok then okCount = okCount + 1 end
            task.wait(0.15)
        end
    end
    return okCount
end

-- ============================================================
-- AUTO SELL — VERSI SellSelection 
-- ============================================================
-- Bukti dari Referensi:
--   RE/PetSatchel/SellSelection :FireServer({
--       Assets = {},                       -- UID pet
--       Eggs = {"cddeeb20...", "aa867b3a..."}   -- UID egg
--   })
--
-- Referensi juga menjelaskan:
--   "The legacy SellEveryPet path is never used (it ignored filtered IDs
--    in Sept 2 tests)." dan "SellSelection with explicit Assets/Eggs UID
--    arrays, WITHOUT equipping a Tool."
--
-- Artinya: SellPet per-UID TIDAK JALAN. Harus SellSelection + array.
-- JANGAN pakai SellEveryPet (jual semua tanpa filter).
-- AUTO SELL  (dibangun ulang dari library yang TERBUKTI JALAN)
-- ============================================================
-- KUNCI (referensi):
--   1. REMOTE BENAR  : RE/PetSatchel/SellPet :FireServer({ uid })
--      (bukan SellSelection batch, bukan save.Inventory)
--   2. WAJIB WEAR    : RF/EggWorld/AskWearTool:InvokeServer(uid) dulu
--   3. SUMBER DATA   : pet  -> Tool di Backpack (ItemType Asset/Phone)
--                      egg  -> EggState.ReadOwnerEggs(UserId)
-- ============================================================
local function getNet()
    local net = ReplicatedStorage:FindFirstChild("Packages")
        and ReplicatedStorage.Packages:FindFirstChild("Networking")
    return net
end

-- Normalisasi nama rarity dari berbagai bentuk field
local function petRarityNameOf(rec, fallbackName)
    local r = rec and (rec.Rarity or rec.RarityName or rec.Tier or rec.RarityTier)
    if type(r) == "table" then r = r._id or r.DisplayName or r.Name end
    if not r then
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            local d = (AssetsData.Directory or AssetsData)[rec and (rec.Category or rec.AssetCategory) or fallbackName]
            local rr = d and (d.Rarity or d.RarityTier or d.Tier)
            if type(rr) == "table" then rr = rr._id or rr.DisplayName or rr.Name end
            r = rr
        end)
    end
    r = tostring(r or "")
    return normalizeRarityName(r) or r
end

-- ------------------------------------------------------------
-- SELL PET  (Backpack tools + SellPet + AskWearTool)
-- ------------------------------------------------------------
local function SellSelectedPets()
    local net = getNet()
    if not net then print("[SELL] Networking tidak ada"); return 0 end
    local sellRemote = net:FindFirstChild("RE/PetSatchel/SellPet")
    local wearRemote = net:FindFirstChild("RF/EggWorld/AskWearTool")
    if not sellRemote then print("[SELL] remote SellPet tidak ketemu"); return 0 end

    -- kalau mode "semua", pakai SellEveryPet
    if S.sellEveryPet then
        local all = net:FindFirstChild("RE/PetSatchel/SellEveryPet")
        if all then pcall(function() all:FireServer() end); print("[SELL] SellEveryPet fired"); end
        return -1
    end

    local filter = getSellRarityFilter(S.selectedSellPetRarities)
    local bp = LP:FindFirstChild("Backpack")
    if not bp then print("[SELL] Backpack tidak ada"); return 0 end

    local sold, skipped, unknown = 0, 0, 0
    for _, tool in ipairs(bp:GetChildren()) do
        if tool:IsA("Tool") then
            local itype = tool:GetAttribute("ItemType")
            if itype == "Asset" or itype == "Phone" then
                local rar = petRarityNameOf(nil, tool.Name)
                -- fallback: pet rarity map dari nama tool
                if (not rar or rar == "") and PET_RARITY_MAP then rar = PET_RARITY_MAP[tool.Name] end
                if not rar or rar == "" then
                    unknown = unknown + 1
                else
                    local isFav = tool:GetAttribute("IsFavorited") or tool:GetAttribute("Favorited")
                        or tool:GetAttribute("IsFavorite")
                    if isFav then
                        skipped = skipped + 1
                    elseif not isRarityAllowed(rar, filter) then
                        skipped = skipped + 1
                    else
                        local uid = tool:GetAttribute("Uid") or tool:GetAttribute("UID")
                            or tool:GetAttribute("uid")
                        if not uid then
                            skipped = skipped + 1
                        else
                            -- WAJIB: pakai dulu sebelum jual
                            if wearRemote then
                                pcall(function() wearRemote:InvokeServer(uid) end)
                                task.wait(0.15)
                            end
                            pcall(function() sellRemote:FireServer({ uid }) end)
                            sold = sold + 1
                            task.wait(0.08)
                        end
                    end
                end
            end
        end
    end
    print(string.format("[SELL] pet: sold=%d skipped=%d unknown=%d", sold, skipped, unknown))
    return sold
end

-- ------------------------------------------------------------
-- SELL EGG  (EggState.ReadOwnerEggs + SellPet + AskWearTool)
-- ------------------------------------------------------------
local function SellSelectedEggs()
    local net = getNet()
    if not net then print("[SELL] Networking tidak ada"); return 0 end
    local sellRemote = net:FindFirstChild("RE/PetSatchel/SellPet")
    local wearRemote = net:FindFirstChild("RF/EggWorld/AskWearTool")
    if not sellRemote then print("[SELL] remote SellPet tidak ketemu"); return 0 end
    if not EggState then print("[SELL] EggState tidak ada"); return 0 end

    local owned = nil
    pcall(function() owned = EggState.ReadOwnerEggs(LP.UserId) end)
    if type(owned) == "table" and owned.Records then owned = owned.Records end
    if type(owned) ~= "table" then print("[SELL] ReadOwnerEggs kosong"); return 0 end

    local filter = getSellRarityFilter(S.selectedSellEggRarities)
    local sold, skippedPlaced, skippedRarity, skippedBad = 0, 0, 0, 0

    for uid, rec in pairs(owned) do
        local u = nil
        if type(uid) == "string" then u = uid
        elseif type(rec) == "table" and type(rec.Uid) == "string" then u = rec.Uid end
        if not u or type(rec) ~= "table" then
            skippedBad = skippedBad + 1
        else
            -- egg yang masih ditanam / terkunci JANGAN dijual
            local placed = false
            local pl = rec.Placement
            if pl ~= nil then
                if type(pl) == "table" then placed = next(pl) ~= nil or pl.LocalCFrame ~= nil
                else placed = true end
            end
            local locked = rec.Locked == true or rec.IsFavorite == true or rec.Favorited == true
            if placed then
                skippedPlaced = skippedPlaced + 1
            elseif locked then
                skippedRarity = skippedRarity + 1
            else
                local rName = petRarityNameOf(rec, nil)
                if isRarityAllowed(rName, filter) then
                    if wearRemote then
                        pcall(function() wearRemote:InvokeServer(u) end)
                        task.wait(0.15)
                    end
                    pcall(function() sellRemote:FireServer({ u }) end)
                    sold = sold + 1
                    task.wait(0.08)
                else
                    skippedRarity = skippedRarity + 1
                end
            end
        end
    end
    print(string.format("[SELL] egg: sold=%d (ditanam=%d rarity=%d invalid=%d)",
        sold, skippedPlaced, skippedRarity, skippedBad))
    return sold
end

-- ------------------------------------------------------------
-- SELL SELECTION (batch) — jalur alternatif, tetap disimpan
-- ------------------------------------------------------------
local function SellSelection(assets, eggs)
    local re = GetNetRemote("RE/PetSatchel/SellSelection")
    if not re then return false end
    local ok = pcall(function() re:FireServer({ Assets = assets or {}, Eggs = eggs or {} }) end)
    return ok
end

local function ClaimAllAvailableRewards()
    pcall(function()
        local rf1 = GetNetRemote("RF/AwayEarnings/AskCollect")
        if rf1 then rf1:InvokeServer() end
    end)
    pcall(function()
        local rf2 = GetNetRemote("RF/Codex/AskRedeemAll")
        if rf2 then rf2:InvokeServer() end
    end)
    pcall(function()
        local rf3 = GetNetRemote("RF/GroupPerk/RedeemPerk")
        if rf3 then rf3:InvokeServer() end
    end)
end


local AreasData = nil
pcall(function() AreasData = require(RS.Data.Areas) end)
local RarityData = nil
pcall(function() RarityData = require(RS.Data.Rarity) end)



-- ============================================================
local AssetItemsMod = nil
pcall(function() AssetItemsMod = require(RS.Shared.Util.AssetItems) end)

-- ---------- AUTO FAVORITE ----------
local function FavoriteMatchesPet(category)
    if not category then return false end
    if next(S.favRarities) then
        local _, rarName = GetEggRarityInfo({ AssetCategory = category })
        if not S.favRarities[rarName] then return false end
    end
    if next(S.favNames) then
        for k in pairs(S.favNames) do
            if tostring(k):lower() == tostring(category):lower() then return true end
        end
        return false
    end
    return true
end

local function AutoFavoritePets()
    if not SaveModule or not AssetItemsMod then return 0 end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return 0 end
    local favRe = GetNetRemote("RE/PetSatchel/WriteFavourite")
        or GetNetRemote("RF/PetSatchel/WriteFavourite")
    if not favRe then return 0 end
    local count = 0
    for uid, data in pairs(save.Inventory) do
        local ok, decoded = pcall(AssetItemsMod.Decode, data)
        if ok and decoded and not decoded.IsFavorite then
            if FavoriteMatchesPet(decoded.Category) then
                pcall(function()
                    if favRe:IsA("RemoteEvent") then
                        favRe:FireServer(uid, true)
                    else
                        favRe:InvokeServer(uid, true)
                    end
                end)
                count = count + 1
                if count % 10 == 0 then task.wait(0.05) end
            end
        end
    end
    return count
end

-- ---------- AUTO FUSE (whitelist, anti pet-loss) ----------
local function FuseMatchesPet(category, rarName)
    if S.fuseSelectedOnly then
        if not next(S.fuseNames) then return false end
        return S.fuseNames[category] == true
    end
    if next(S.fuseRarities) then
        return S.fuseRarities[rarName] == true
    end
    return false  -- tanpa filter = JANGAN fuse
end

local function AutoFusePets()
    if not SaveModule or not AssetItemsMod then return false, "modules not ready" end
    local save = nil
    pcall(function() save = SaveModule.Get and SaveModule.Get() end)
    if not save or type(save.Inventory) ~= "table" then return false, "no save" end
    if type(save.FusionSlots) ~= "table" then return false, "no FusionSlots" end

    if save.FusionLocked == true then return false, "machine is fusing" end
    if save.FusionEggReward ~= false and save.FusionEggReward ~= nil then
        local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
        if revealNet then pcall(function() revealNet:InvokeServer() end) end
        return false, "claim reward first"
    end

    local equipped = {}
    for _, uid in ipairs(save.EquippedAssets or {}) do equipped[tostring(uid)] = true end

    local groups = {}
    for uid, data in pairs(save.Inventory) do
        if not equipped[tostring(uid)] then
            local ok, decoded = pcall(AssetItemsMod.Decode, data)
            if ok and decoded and not decoded.IsFavorite and not decoded.InFuse then
                local cat = decoded.Category or ""
                local rarName = select(1, GetEggRarityInfo({ AssetCategory = cat }))
                if FuseMatchesPet(cat, rarName) then
                    groups[cat] = groups[cat] or {}
                    table.insert(groups[cat], tostring(uid))
                end
            end
        end
    end

    local cats = {}
    for c, uids in pairs(groups) do
        if #uids >= 3 then table.insert(cats, c) end
    end
    if #cats == 0 then return false, "no 3 pets of same category" end
    table.sort(cats)
    local chosen = groups[cats[1]]
    table.sort(chosen, function(a, b) return tostring(a) < tostring(b) end)

    local fuseNet   = GetNetRemote("RF/Fusery/BeginFuse")
    local insertNet = GetNetRemote("RF/Fusery/LoadPet")
    local revealNet = GetNetRemote("RF/Fusery/FinishReveal")
    local briefNet  = GetNetRemote("RF/Fusery/ConfirmBriefing")
    if not (fuseNet and insertNet and revealNet) then return false, "fuse remotes missing" end

    local price = tonumber(save.FusionPrice) or 0
    if price > 0 and (tonumber(save.Money) or 0) < price then
        return false, "not enough money for fuse"
    end

    local okAll, err = pcall(function()
        if briefNet then briefNet:InvokeServer() end
        for i = 1, 3 do
            local latest = nil
            pcall(function() latest = SaveModule.Get and SaveModule.Get() end)
            if latest and latest.Inventory and latest.Inventory[chosen[i]] then
                insertNet:InvokeServer(chosen[i])
            end
            task.wait(0.05)
        end
        fuseNet:InvokeServer()
        local t0 = os.clock()
        while os.clock() - t0 < 10 do
            local s = nil
            pcall(function() s = SaveModule.Get and SaveModule.Get() end)
            if not s then break end
            if s.FusionEggReward == true then break end
            if s.FusionLocked ~= true and s.FusionEggReward == false then break end
            task.wait(0.25)
        end
        revealNet:InvokeServer()
    end)
    return okAll, (okAll and "fused" or tostring(err))
end

-- ---------- UTILITY ----------
local function SetFullbright(on)
    if on then
        HUB._savedLighting = HUB._savedLighting or {
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient,
            FogEnd = Lighting.FogEnd, GlobalShadows = Lighting.GlobalShadows,
        }
        pcall(function()
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.fromRGB(178, 178, 178)
            Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        end)
    elseif HUB._savedLighting then
        pcall(function()
            local s = HUB._savedLighting
            Lighting.Brightness = s.Brightness; Lighting.ClockTime = s.ClockTime
            Lighting.Ambient = s.Ambient; Lighting.OutdoorAmbient = s.OutdoorAmbient
            Lighting.FogEnd = s.FogEnd; Lighting.GlobalShadows = s.GlobalShadows
        end)
        HUB._savedLighting = nil
    end
end

local function applyMovementTweaks()
    local h = findHum()
    if not h then return end
    if S.jumpPowerEnabled then
        pcall(function() h.UseJumpPower = true; h.JumpPower = S.jumpPowerValue end)
    end
    if S.infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end

-- ============================================================
-- FLY (WASD) / ANTI-TRAP / FPS GOVERNOR / HIDE VISUALS
-- ============================================================
local _flyConns = {}
local _flyBV    = nil
local function stopFly()
    for _, c in ipairs(_flyConns) do pcall(function() c:Disconnect() end) end
    _flyConns = {}
    if _flyBV then pcall(function() _flyBV:Destroy() end); _flyBV = nil end
    local h = findHum()
    if h then pcall(function() h.PlatformStand = false; h:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
end

local function startFly()
    stopFly()
    local hrp = findHRP()
    local h   = findHum()
    if not hrp or not h then return end
    local bv = Instance.new("BodyVelocity")
    bv.Name = "AscendFly"
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    _flyBV = bv
    h.PlatformStand = true
    local cam = Workspace.CurrentCamera
    table.insert(_flyConns, RunService.RenderStepped:Connect(function()
        if not S.flyEnabled then stopFly(); return end
        local hrpNow = findHRP()
        if not hrpNow or not _flyBV or not _flyBV.Parent then return end
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end
        local speed = math.clamp(tonumber(S.flySpeed) or 60, 10, 400)
        _flyBV.Velocity = (dir.Magnitude > 0) and (dir.Unit * speed) or Vector3.zero
    end))
end

-- ---------- ANTI-TRAP ----------
-- ============================================================
-- ANTI-TRAP v2  (non-destructive)
-- ============================================================
-- KUNCI PERBAIKAN (dari Antitrap.txt):
--   1. CARI TRAP: Workspace:QueryDescendants("#PlayerTrap")
--      -> cari SEMUA descendant bernama PlayerTrap, di mana pun
--         (tidak bergantung pada folder __DEBRIS saja)
--   2. HAPUS: TouchInterest  (BUKAN TouchTransmitter)
--      -> TouchInterest = object internal yang bikin part bisa
--         men-trigger Touched. Tanpa ini, trap TIDAK bisa nge-damage.
--
-- Tetap dipertahankan dari versi library:
--   - filter owner (jangan netralkan trap sendiri)
--   - non-destruktif: CanTouch/CanQuery = false, Hitbox dipindah
--   - tidak Destroy part (biar tidak detectable)
local _trapCacheAt = 0

-- hapus TouchInterest (sumber trigger damage)
local function killTouchInterest(t)
    local done = false
    pcall(function()
        local ti = t:FindFirstChild("TouchInterest", true)
        if ti then ti:Destroy(); done = true end
    end)
    -- fallback: nama lain yang dipakai beberapa versi game
    if not done then
        pcall(function()
            local tt = t:FindFirstChildWhichIsA("TouchTransmitter", true)
            if tt then tt:Destroy(); done = true end
        end)
    end
    return done
end

-- Nonaktifkan satu trap TANPA menghapus part-nya.
local function neutralizeOneTrap(d)
    local ok = pcall(function()
        -- 1. hapus TouchInterest di part itu + semua descendant
        killTouchInterest(d)
        for _, c in ipairs(d:GetDescendants()) do
            if c:IsA("BasePart") then killTouchInterest(c) end
        end

        -- 2. matikan collider (non-destruktif)
        if d:IsA("BasePart") then
            d.CanTouch = false
            d.CanQuery = false
        end
        for _, c in ipairs(d:GetDescendants()) do
            if c:IsA("BasePart") then
                c.CanTouch = false
                c.CanQuery = false
                if c.Name == "Hitbox" then
                    c.CFrame = CFrame.new(0, -999, 0)
                end
            end
        end
    end)
    return ok
end

-- cari trap pakai QueryDescendants (cara Antitrap.txt)
local function findTraps()
    local out = {}
    -- cara 1: QueryDescendants selector (paling akurat)
    local ok, list = pcall(function()
        return Workspace:QueryDescendants("#PlayerTrap")
    end)
    if ok and list then
        for _, t in ipairs(list) do out[#out + 1] = t end
    end
    -- cara 2 (fallback): __DEBRIS + scan nama
    if #out == 0 then
        local debris = Workspace:FindFirstChild("__DEBRIS")
        if debris then
            for _, d in ipairs(debris:GetChildren()) do
                if d.Name == "PlayerTrap" then out[#out + 1] = d end
            end
        end
    end
    if #out == 0 then
        for _, v in ipairs(Workspace:GetChildren()) do
            local nm = v.Name:lower()
            if (v:IsA("BasePart") or v:IsA("Model"))
                and (nm:find("playertrap") or nm:find("trap") or nm:find("spike")) then
                out[#out + 1] = v
            end
        end
    end
    return out
end

NeutralizeTraps = function(force)
    if not force and not S.avoidTrapsEnabled then return 0 end
    local now = os.clock()
    if not force and (now - _trapCacheAt) < 1.0 then return 0 end
    _trapCacheAt = now

    local n = 0
    for _, d in ipairs(findTraps()) do
        -- jangan netralkan trap MILIK SENDIRI (biar kita tetap bisa pakai)
        local owner = d:GetAttribute("Owner")
        if owner == nil or tostring(owner) ~= tostring(LP.Name) then
            if neutralizeOneTrap(d) then n = n + 1 end
        end
    end
    return n
end

local function ApplyAntiTrap(on)
    if HUB._trapConn then pcall(function() HUB._trapConn:Disconnect() end); HUB._trapConn = nil end
    if not on then return end
    pcall(NeutralizeTraps, true)
    -- trap baru muncul -> langsung dinetralkan (tanpa Destroy)
    HUB._trapConn = Workspace.DescendantAdded:Connect(function(v)
        if not S.avoidTrapsEnabled then return end
        if v.Name == "PlayerTrap"
           or v.Name:lower():find("trap")
           or v.Name:lower():find("spike") then
            task.defer(function() pcall(neutralizeOneTrap, v) end)
        end
    end)
    -- pembersih berkala
    track(task.spawn(function()
        while not HUB.dead and S.avoidTrapsEnabled do
            task.wait(0.8)
            pcall(NeutralizeTraps)
        end
    end))
    -- LAYER 2: CollectionService "PlacedTrap" 
    if HUB.ApplyAntiTrapTags then pcall(HUB.ApplyAntiTrapTags, true) end
end

-- ============================================================
-- ANTI-TRAP v3 — TAMBAHAN CollectionService "PlacedTrap"  
-- ============================================================
-- v2 cari trap lewat QueryDescendants("#PlayerTrap") + __DEBRIS.
-- Library pakai CollectionService:GetTagged("PlacedTrap") — tag yang SAMA
-- dipakai server untuk menandai trap pemain. Dua jalur = lebih tahan
-- kalau salah satu rename/berubah.
local _trapTags = {}

local function _killTagTrap(inst)
    if not inst then return end
    pcall(function()
        if inst:IsA("BasePart") then
            inst.CanTouch = false
            inst.CanQuery = false
        end
        local ti = inst:FindFirstChild("TouchInterest", true)
        if ti then ti:Destroy() end
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("BasePart") then
                d.CanTouch = false
                d.CanQuery = false
                if d.Name == "Hitbox" then d.CFrame = CFrame.new(0, -999, 0) end
            end
        end
    end)
end

local function _sweepTaggedTraps()
    pcall(function()
        for _, t in ipairs(CollectionService:GetTagged("PlacedTrap")) do
            local owner = t:GetAttribute("Owner")
            if owner == nil or tostring(owner) ~= tostring(LP.Name) then
                _killTagTrap(t)
            end
        end
    end)
end

HUB.ApplyAntiTrapTags = function(on)
    for _, c in ipairs(_trapTags) do pcall(function() c:Disconnect() end) end
    table.clear(_trapTags)
    if not on then return end
    _sweepTaggedTraps()
    pcall(function()
        table.insert(_trapTags, CollectionService:GetInstanceAddedSignal("PlacedTrap"):Connect(function(t)
            if not S.avoidTrapsEnabled then return end
            task.defer(function()
                local owner = t:GetAttribute("Owner")
                if owner == nil or tostring(owner) ~= tostring(LP.Name) then
                    _killTagTrap(t)
                end
            end)
        end))
    end)
    track(task.spawn(function()
        while not HUB.dead and S.avoidTrapsEnabled do
            task.wait(1.2)
            _sweepTaggedTraps()
        end
    end))
end

-- ---------- FPS GOVERNOR / HIDE VISUALS ----------
local _fpsConns = {}
local _savedPets, _savedEggs, _savedPlot = {}, {}, {}

local LOGO_ID = "rbxassetid://95983323492030"
local function setupFpsMap()

-- ============================================================
-- FPS CAP + OPTIMIZER + FPS/PING HUD  (port library: Performance)
-- ============================================================
do
    -- ---------- FPS CAP ----------
    local _fpsWarned = false
    HUB.SetFpsCap = function(v)
        local cap = math.clamp(math.floor(tonumber(v) or 240), 30, 1000)
        if type(setfpscap) == "function" and pcall(setfpscap, cap) then
            _fpsWarned = false
            return true
        end
        if not _fpsWarned then
            _fpsWarned = true
            Notify("FPS Cap Unavailable", "Executor ini tidak support setfpscap.", 4)
        end
        return false
    end

    -- ---------- OPTIMIZER MAXIMUM (super mode for Redfinger) ----------
    local _optOn = false
    local _optSaved = setmetatable({}, { __mode = "k" })
    local _optConns = {}
    local _optThread = nil
    local _optGen = 0

    local function _optSet(inst, prop, val)
        local ok, cur = pcall(function() return inst[prop] end)
        if not ok then return end
        local rec = _optSaved[inst]
        if not rec then rec = {}; _optSaved[inst] = rec end
        if rec[prop] == nil then rec[prop] = cur end
        pcall(function() inst[prop] = val end)
    end

    local function _optOne(inst)
        if not _optOn or not inst or not inst.Parent then return end
        pcall(function()
            -- CORE: disable all performance killers
            if inst:IsA("ParticleEmitter") then
                _optSet(inst, "Enabled", false); _optSet(inst, "Rate", 0); _optSet(inst, "Lifespan", 0)
            elseif inst:IsA("Trail") or inst:IsA("Beam") then
                _optSet(inst, "Enabled", false)
            elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
                _optSet(inst, "Enabled", false); _optSet(inst, "Brightness", 0)
            elseif inst:IsA("Fire") or inst:IsA("Smoke") or inst:IsA("Sparkles") then
                _optSet(inst, "Enabled", false)
            elseif inst:IsA("Explosion") then
                _optSet(inst, "Visible", false)
            elseif inst:IsA("SpecialMesh") then
                _optSet(inst, "TextureId", "")
            elseif inst:IsA("Decal") or inst:IsA("Texture") then
                if not (inst.Name == "face" and inst.Parent and inst.Parent.Name == "Head") then
                    _optSet(inst, "Transparency", 1); _optSet(inst, "TextureId", "")
                end
            elseif inst:IsA("MeshPart") then
                _optSet(inst, "RenderFidelity", Enum.RenderFidelity.Performance)
                _optSet(inst, "TextureID", "")
                _optSet(inst, "CastShadow", false)
                _optSet(inst, "Reflectance", 0)
                _optSet(inst, "Material", Enum.Material.SmoothPlastic)
            elseif inst:IsA("BasePart") then
                _optSet(inst, "CastShadow", false)
                _optSet(inst, "Reflectance", 0)
                _optSet(inst, "Transparency", 0)
                _optSet(inst, "Material", Enum.Material.SmoothPlastic)
                _optSet(inst, "CanCollide", true) -- tetap bisa collision
            elseif inst:IsA("PostEffect") then
                _optSet(inst, "Enabled", false)
                -- Force disable semua post-effect types
                if inst.Name == "FutureExposureEffect" or 
                   inst.Name == "BloomEffect" or 
                   inst.Name == "ColorCorrectionEffect" or
                   inst.Name == "DepthOfFieldEffect" or
                   inst.Name == "FilmGrainEffect" or
                   inst.Name == "LensEffect" or
                   inst.Name == "MotionBlurEffect" or
                   inst.Name == "SunBlursEffect" or
                   inst.Name == "ChromaticAberrationEffect" then
                    pcall(function() inst.Enabled = false end)
                end
            elseif inst:IsA("Clouds") then
                _optSet(inst, "Cover", 0); _optSet(inst, "Density", 0)
            elseif inst:IsA("Atmosphere") then
                _optSet(inst, "Density", 0); _optSet(inst, "Haze", 0); _optSet(inst, "Glare", 0)
            end
        end)
    end

    local function _optRestore()
        for inst, rec in pairs(_optSaved) do
            pcall(function()
                if inst and inst.Parent then
                    for prop, val in pairs(rec) do inst[prop] = val end
                end
            end)
        end
        table.clear(_optSaved)
    end

    HUB.OptimizerStop = function()
        _optOn = false
        _optGen = _optGen + 1
        for _, c in ipairs(_optConns) do pcall(function() c:Disconnect() end) end
        table.clear(_optConns)
        if _optThread then pcall(task.cancel, _optThread); _optThread = nil end
        _optRestore()
        -- balikin setting render
        pcall(function()
            local UGS = UserSettings():GetService("UserGameSettings")
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            pcall(function() UGS.SavedQualityLevel = Enum.SavedQualitySetting.Automatic end)
        end)
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.EnvironmentDiffuseScale = 1
            Lighting.EnvironmentSpecularScale = 1
        end)
        print("[OPT] restored")
    end

    HUB.OptimizerStart = function()
        if _optOn then return end
        _optOn = true
        _optGen = _optGen + 1
        local gen = _optGen
        print("[OPT] start")

        -- setting global (sekali, bukan per-part)
        pcall(function()
            local s = settings()
            s.Rendering.QualityLevel = Enum.QualityLevel.Level01
            pcall(function() s.Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01 end)
            pcall(function() s.Rendering.EditQualityLevel = Enum.QualityLevel.Level01 end)
            local UGS = UserSettings():GetService("UserGameSettings")
            pcall(function() UGS.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
        end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.ShadowSoftness = 0
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
            pcall(function() Lighting.Technology = Enum.Technology.Legacy end)
            pcall(function() Lighting.FogEnd = 9000000000 end)
            pcall(function() Lighting.FogStart = 1 end) -- disable fog draw
            pcall(function() if Lighting Sky then Sky.Enabled = false end end) -- disable sky render
        end)

        -- scan bertahap (biar gak lag 1 frame)
        _optThread = task.spawn(function()
            local buf = {}
            local function flush()
                for _, x in ipairs(buf) do _optOne(x) end
                table.clear(buf)
            end
            for _, x in ipairs(Workspace:GetDescendants()) do
                if not _optOn or gen ~= _optGen then return end
                buf[#buf + 1] = x
                if #buf >= 400 then flush(); task.wait() end
            end
            flush()
            for _, x in ipairs(Lighting:GetDescendants()) do
                if not _optOn or gen ~= _optGen then return end
                _optOne(x)
            end
            _optOne(Lighting)
            if _optOn and gen == _optGen then
                table.insert(_optConns, Workspace.DescendantAdded:Connect(function(v)
                    if _optOn then task.defer(_optOne, v) end
                end))
            end
            print("[OPT] scan selesai")
        end)
    end

    HUB.OptimizerToggle = function(on)
        if on then HUB.OptimizerStart() else HUB.OptimizerStop() end
    end

    -- ---------- FPS + PING HUD (gradient, drag, persist) ----------
    local Stats = game:GetService("Stats")
    local _hudGui, _hudFrame, _hudFps, _hudMs, _hudConn, _hudUIScale = nil, nil, nil, nil, nil, nil
    local _hudSize = 1
    local _hudSmooth, _hudAcc = 0, 0
    local _hudDragStart, _hudDragOrigin = nil, nil
    local _hudPosKey = "AscendFpsPingPos"

    local C_GOOD = Color3.fromRGB(58, 255, 55)
    local C_WARN = Color3.fromRGB(255, 214, 84)
    local C_BAD  = Color3.fromRGB(255, 96, 96)
    local C_MUTED = Color3.fromRGB(150, 150, 158)
    local C_BG   = Color3.fromRGB(24, 24, 28)

    local _hudFont
    pcall(function()
        _hudFont = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    end)

    local function _colFps(v)
        if v >= 100 then return C_GOOD elseif v >= 50 then return C_WARN end
        return C_BAD
    end
    local function _colPing(v)
        if v <= 90 then return C_GOOD elseif v <= 180 then return C_WARN end
        return C_BAD
    end

    -- persist posisi (pakai atribut di gui kalau ada, fallback in-memory)
    local _savedPos = nil
    local function _loadPos()
        local s
        pcall(function() s = readfile and readfile("Ascend_FpsPing.json") end)
        if type(s) == "string" then
            pcall(function()
                local d = game:GetService("HttpService"):JSONDecode(s)
                if type(d) == "table" and d.XScale then
                    _savedPos = UDim2.new(d.XScale, d.XOffset, d.YScale, d.YOffset)
                end
            end)
        end
    end
    local function _savePos(p)
        pcall(function()
            if writefile then
                writefile("Ascend_FpsPing.json", game:GetService("HttpService"):JSONEncode({
                    XScale = p.X.Scale, XOffset = p.X.Offset, YScale = p.Y.Scale, YOffset = p.Y.Offset }))
            end
        end)
    end
    _loadPos()

    HUB.HudStop = function()
        if _hudConn then pcall(function() _hudConn:Disconnect() end); _hudConn = nil end
        if _hudGui then pcall(function() _hudGui:Destroy() end); _hudGui = nil end
        _hudFrame, _hudFps, _hudMs, _hudUIScale = nil, nil, nil, nil
    end

    HUB.HudSetSize = function(percent)
        _hudSize = math.clamp((tonumber(percent) or 100) / 100, 0.5, 2.0)
        if _hudUIScale then _hudUIScale.Scale = _hudSize end
    end

    HUB.HudStart = function()
        if _hudGui then return end
        local gui = Instance.new("ScreenGui")
        gui.Name = "AscendFpsPing"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 58
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = true
        gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        _hudGui = gui

        local frame = Instance.new("Frame")
        frame.Name = "Panel"
        frame.Size = UDim2.fromOffset(186, 46)
        frame.Position = _savedPos or UDim2.new(0, 16, 0, 16)
        frame.BackgroundColor3 = Color3.fromRGB(16, 17, 24)
        frame.BackgroundTransparency = 0.12
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Parent = gui
        _hudFrame = frame

        local crn = Instance.new("UICorner"); crn.CornerRadius = UDim.new(0, 14); crn.Parent = frame
        local stk = Instance.new("UIStroke")
        stk.Color = Color3.fromRGB(70, 78, 100); stk.Thickness = 1; stk.Transparency = 0.55
        stk.Parent = frame
        local bgg = Instance.new("UIGradient")
        bgg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 38, 54)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(16, 17, 24)),
        }
        bgg.Rotation = 115
        bgg.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.55),
            NumberSequenceKeypoint.new(1, 0.92),
        }
        bgg.Parent = frame
        local sc = Instance.new("UIScale"); sc.Scale = _hudSize; sc.Parent = frame
        _hudUIScale = sc

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)
        pad.PaddingTop = UDim.new(0, 6);  pad.PaddingBottom = UDim.new(0, 6)
        pad.Parent = frame

        local row = Instance.new("Frame")
        row.Size = UDim2.fromScale(1, 1)
        row.BackgroundTransparency = 1
        row.Parent = frame
        local rl = Instance.new("UIListLayout")
        rl.FillDirection = Enum.FillDirection.Horizontal
        rl.VerticalAlignment = Enum.VerticalAlignment.Center
        rl.SortOrder = Enum.SortOrder.LayoutOrder
        rl.Parent = row

        -- ★ modern: dua "chip" (FPS & MS) dengan dot indikator + angka besar
        local function chip(order, labelTxt, accent)
            local c = Instance.new("Frame")
            c.Size = UDim2.fromOffset(78, 34)
            c.BackgroundColor3 = Color3.fromRGB(26, 28, 40)
            c.BackgroundTransparency = 0.25
            c.BorderSizePixel = 0
            c.LayoutOrder = order
            c.Parent = row
            local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 10); cc.Parent = c

            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(6, 6)
            dot.Position = UDim2.fromOffset(9, 8)
            dot.BackgroundColor3 = accent
            dot.BorderSizePixel = 0
            dot.Parent = c
            local dc = Instance.new("UICorner"); dc.CornerRadius = UDim.new(1, 0); dc.Parent = dot

            local lt = Instance.new("TextLabel")
            lt.BackgroundTransparency = 1
            lt.Position = UDim2.fromOffset(20, 5)
            lt.Size = UDim2.fromOffset(52, 12)
            if _hudFont then lt.FontFace = _hudFont else lt.Font = Enum.Font.GothamBold end
            lt.TextSize = 10
            lt.TextXAlignment = Enum.TextXAlignment.Left
            lt.TextColor3 = Color3.fromRGB(150, 156, 178)
            lt.Text = labelTxt
            lt.Parent = c

            local val = Instance.new("TextLabel")
            val.BackgroundTransparency = 1
            val.Position = UDim2.fromOffset(9, 15)
            val.Size = UDim2.fromOffset(64, 17)
            if _hudFont then val.FontFace = _hudFont else val.Font = Enum.Font.GothamBlack end
            val.TextSize = 16
            val.TextXAlignment = Enum.TextXAlignment.Left
            val.TextColor3 = accent
            val.Text = "0"
            val.Parent = c
            return val, dot
        end

        local fpsDot
        _hudFps, fpsDot = chip(1, "FPS", C_GOOD)
        local spacer = Instance.new("Frame")
        spacer.Size = UDim2.fromOffset(6, 1)
        spacer.BackgroundTransparency = 1
        spacer.LayoutOrder = 2
        spacer.Parent = row
        local msDot
        _hudMs, msDot = chip(3, "PING", C_GOOD)

        -- drag + persist
        frame.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                _hudDragStart = inp.Position
                _hudDragOrigin = frame.Position
            end
        end)
        frame.InputChanged:Connect(function(inp)
            if _hudDragStart and (inp.UserInputType == Enum.UserInputType.MouseMovement
               or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - _hudDragStart
                frame.Position = UDim2.new(_hudDragOrigin.X.Scale, _hudDragOrigin.X.Offset + d.X,
                                           _hudDragOrigin.Y.Scale, _hudDragOrigin.Y.Offset + d.Y)
            end
        end)
        frame.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                _hudDragStart = nil
                _savePos(frame.Position)
            end
        end)

        _hudConn = track(RunService.RenderStepped:Connect(function(dt)
            if not _hudGui then return end
            local a = math.clamp(dt, 0.001, 1)
            _hudSmooth = _hudSmooth + (1 / a - _hudSmooth) * (1 - math.exp(-a * 8))
            _hudAcc = _hudAcc + dt
            if _hudAcc < 0.2 then return end
            _hudAcc = 0
            local fps = math.floor(_hudSmooth + 0.5)
            if _hudFps then
                _hudFps.Text = tostring(fps)
                local c = _colFps(fps)
                _hudFps.TextColor3 = c
                if fpsDot then fpsDot.BackgroundColor3 = c end
            end
            if _hudMs then
                local ping = 0
                pcall(function() ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
                ping = math.floor((tonumber(ping) or 0) + 0.5)
                _hudMs.Text = tostring(ping)
                local c2 = _colPing(ping)
                _hudMs.TextColor3 = c2
                if msDot then msDot.BackgroundColor3 = c2 end
            end
        end))
    end

    HUB.HudToggle = function(on)
        if on then HUB.HudStart() else HUB.HudStop() end
    end
end

    local function ClearFPSConns()
        for _, c in ipairs(_fpsConns) do pcall(function() c:Disconnect() end) end
        _fpsConns = {}
    end

    local function HideDescendants(obj, cache)
        if not obj then return end
        for _, v in ipairs(obj:GetDescendants()) do
            pcall(function()
                if v:IsA("BasePart") then
                    if cache[v] == nil then
                        cache[v] = { ltm = v.LocalTransparencyModifier, tr = v.Transparency }
                    end
                    v.LocalTransparencyModifier = 1
                    v.Transparency = 1
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    if cache[v] == nil then cache[v] = { tr = v.Transparency } end
                    v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                    or v:IsA("Highlight") or v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
                    if cache[v] == nil then cache[v] = { en = v.Enabled } end
                    v.Enabled = false
                end
            end)
        end
    end

    local function RestoreCache(cache)
        for obj, data in pairs(cache) do
            pcall(function()
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then
                        obj.LocalTransparencyModifier = data.ltm or 0
                        obj.Transparency = data.tr or 0
                    elseif obj:IsA("Decal") or obj:IsA("Texture") then
                        obj.Transparency = data.tr or 0
                    else
                        obj.Enabled = data.en ~= false
                    end
                end
            end)
        end
        table.clear(cache)
    end

    local function ApplyHideAllPets(on)
        for _, v in ipairs(Workspace:GetChildren()) do
            if v.Name == "ClientRenderedAssets" then
                HideDescendants(v, _savedPets)
            end
        end
        if on then
            table.insert(_fpsConns, Workspace.ChildAdded:Connect(function(c)
                if c.Name == "ClientRenderedAssets" and S.hideAllPets then
                    HideDescendants(c, _savedPets)
                end
            end))
        end
    end

    local function ApplyFPSBoost(on)
        ClearFPSConns()
        if not on then
            RestoreCache(_savedPets); RestoreCache(_savedEggs); RestoreCache(_savedPlot)
            pcall(function()
                Lighting.GlobalShadows = true
            end)
            return
        end
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.Brightness = 2
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
        end)
        table.insert(_fpsConns, Workspace.DescendantAdded:Connect(function(v)
            if not S.fpsBoost then return end
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                    or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end)
        end))
        for _, v in ipairs(Workspace:GetDescendants()) do
            pcall(function()
                if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                    or v:IsA("Sparkles") or v:IsA("Fire") or v:IsA("Smoke") then
                    v.Enabled = false
                elseif v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                end
            end)
        end
        if S.hideAllPets then ApplyHideAllPets(true) end
    end

    local function SetAntiAFK(on)
        if on then
            if not HUB._antiAfkConn then
                HUB._antiAfkConn = LP.Idled:Connect(function()
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end)
            end
        else
            if HUB._antiAfkConn then
                pcall(function() HUB._antiAfkConn:Disconnect() end)
                HUB._antiAfkConn = nil
            end
        end
    end

    -- ---------- FPS & PING PANEL (kecil, logo, draggable) ----------
    local _statsPanel = nil
    local _statsConn  = nil


    -- ---------- REDUCE MAP (LIGHTWEIGHT, REVERSIBLE) ----------
    local _mapSaved = {}
    local _mapConns = {}

    local function ClearMapReduceConns()
        for _, c in ipairs(_mapConns) do pcall(function() c:Disconnect() end) end
        _mapConns = {}
    end

    local function IsProtectedFromReduce(v)
        local node = v
        for _ = 1, 6 do
            if not node or node == Workspace then break end
            local nm = node.Name
            if nm and nm ~= "" then
                local low = nm:lower()
                if low:find("guard", 1, true)
                    or low:find("egg", 1, true)
                    or low:find("nest", 1, true) then
                    return true
                end
            end
            node = node.Parent
        end
        return false
    end

    local function ReduceOne(v)
        if not v or not v.Parent then return end
        if IsProtectedFromReduce(v) then return end
        pcall(function()
            if v:IsA("BasePart") then
                if _mapSaved[v] == nil then _mapSaved[v] = { cs = v.CastShadow } end
                if v.CastShadow then v.CastShadow = false end
            elseif v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail")
                or v:IsA("Smoke") or v:IsA("Fire") or v:IsA("Sparkles")
                or v:IsA("SelectionBox") then
                if _mapSaved[v] == nil then _mapSaved[v] = { en = v.Enabled } end
                if v.Enabled then v.Enabled = false end
            elseif v:IsA("PointLight") or v:IsA("SpotLight") or v:IsA("SurfaceLight") then
                -- lampu: shadow-map + fill cost, matiin (dari library)
                if _mapSaved[v] == nil then _mapSaved[v] = { en = v.Enabled } end
                if v.Enabled then v.Enabled = false end
            end
        end)
    end

    local function ApplyReduceMap(on)
        ClearMapReduceConns()
        if not on then
            -- Restore exactly as before
            for obj, data in pairs(_mapSaved) do
                pcall(function()
                    if obj and obj.Parent then
                        if data.cs ~= nil then obj.CastShadow = data.cs end
                        if data.en ~= nil then obj.Enabled = data.en end
                    end
                end)
            end
            table.clear(_mapSaved)
            return
        end
        task.spawn(function()
            local buf = {}
            for _, v in ipairs(Workspace:GetDescendants()) do
                if not S.reduceMap then return end
                buf[#buf + 1] = v
                if #buf >= 400 then
                    for _, x in ipairs(buf) do ReduceOne(x) end
                    table.clear(buf)
                    task.wait()
                end
            end
            for _, x in ipairs(buf) do ReduceOne(x) end
            if S.reduceMap then
                table.insert(_mapConns, Workspace.DescendantAdded:Connect(function(v)
                    if not S.reduceMap then return end
                    ReduceOne(v)
                end))
            end
        end)
    end




    HUB.ClearFPSConns     = ClearFPSConns
    HUB.HideDescendants   = HideDescendants
    HUB.RestoreCache      = RestoreCache
    HUB.ApplyHideAllPets  = ApplyHideAllPets
    HUB.ApplyFPSBoost     = ApplyFPSBoost
    HUB.SetAntiAFK        = SetAntiAFK
    HUB.ClearMapReduceConns = ClearMapReduceConns
    HUB.IsProtectedFromReduce = IsProtectedFromReduce
    HUB.ReduceOne         = ReduceOne
    HUB.ApplyReduceMap    = ApplyReduceMap
end
setupFpsMap()

-- Additional worker loops
task.spawn(function()
    while true do
        task.wait(2.5)
        if S.autoHatchEnabled then pcall(HatchAllReadyEggs) end
        if S.autoPlantEnabled then pcall(PlantAllCarriedEggsInPen) end
        if S.autoUpgradeBase then pcall(UpgradeHomesteadBase) end
        if S.autoUpgradeTreadmill then pcall(UpgradeTreadmillTier) end
        if S.autoEquipBestPets then pcall(EquipBestPets) end
        if S.autoClaimRewards then pcall(ClaimAllAvailableRewards) end
        if S.autoSellPets then pcall(SellSelectedPets) end
        if S.autoSellEggs then pcall(SellSelectedEggs) end
        if S.autoFavoritePets then pcall(AutoFavoritePets) end
        if S.autoFusePets then pcall(AutoFusePets) end
    end
end)

-- Movement tweaks loop (infinite jump / jump power / walkspeed)
track(RunService.Heartbeat:Connect(function()
    if HUB.dead then return end
    if S.walkSpeedEnabled then
        local h = findHum()
        if h then pcall(function() h.WalkSpeed = math.clamp(S.walkSpeedVal or 24, 16, 500) end) end
    end
    if S.jumpPowerEnabled or S.infiniteJumpEnabled then
        pcall(applyMovementTweaks)
    end
end))

-- Bat Aura loop
task.spawn(function()
    local batRe = GetNetRemote("RE/BatSwing/Trigger")
    while true do
        task.wait(S.batAuraDelay)
        if S.batAuraEnabled and batRe then
            local hrp = findHRP()
            if hrp then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character then
                        local oHrp = p.Character:FindFirstChild("HumanoidRootPart")
                        if oHrp and (oHrp.Position - hrp.Position).Magnitude <= S.batAuraRadius then
                            pcall(function() batRe:FireServer() end)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================
-- SERVER HOP v2 — MULTI-PAGE + MODE  
-- ============================================================
-- Versi lama: 1 halaman, sortOrder tetap, hanya "least players".
-- v2: 6 halaman (atau 3 kalau Random), 3 mode (Most/Random/Least),
--     cache hasil 60s, exclude server yang gagal (TeleportInitFailed).
do
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local req = (syn and syn.request) or (http and http.request) or http_request or request

    local _excluded = {}        -- jobId yang gagal di-teleport
    local _cache, _cacheAt = nil, 0
    local _cacheMode = nil
    local _hopMode = "Least Players"

    local function fetchServers(mode)
        if not req then return nil, "executor tidak support request" end
        if _cache and _cacheMode == mode and (os.clock() - _cacheAt) < 60 then
            return _cache
        end
        local sortOrder = (mode == "Most Players") and "Desc" or "Asc"
        local pages = (mode == "Random") and 3 or 6
        local all = {}
        local cursor = nil
        local placeId = game.PlaceId

        for _ = 1, pages do
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&excludeFullGames=true&limit=100",
                placeId, sortOrder)
            if cursor and cursor ~= "" then
                url = url .. "&cursor=" .. HttpService:UrlEncode(cursor)
            end
            local ok, res = pcall(function()
                local r = req({ Url = url, Method = "GET" })
                if r and r.StatusCode == 200 and r.Body then
                    return HttpService:JSONDecode(r.Body)
                end
                return nil
            end)
            if not ok or not res or not res.data then break end
            for _, s in ipairs(res.data) do
                if s.id ~= game.JobId
                   and tonumber(s.playing) < tonumber(s.maxPlayers)
                   and not _excluded[s.id] then
                    table.insert(all, s)
                end
            end
            cursor = res.nextPageCursor
            if not cursor or cursor == "" then break end
            task.wait(0.15)
        end
        _cache, _cacheAt, _cacheMode = all, os.clock(), mode
        return all
    end

    -- hasil: "fetch" | "empty" | "failed" | "denied" | "waiting"
    HUB.ServerHop = function(mode)
        mode = mode or _hopMode
        _hopMode = mode
        if not req then
            Notify("Server Hop", "Executor tidak support request.", 4)
            return "failed"
        end
        local list, err = fetchServers(mode)
        if not list then
            Notify("Server Hop", tostring(err or "gagal fetch"), 4)
            return "failed"
        end
        if #list == 0 then
            _cache = nil
            table.clear(_excluded)
            return "empty"
        end
        local pick
        if mode == "Random" then
            pick = list[math.random(1, #list)]
        elseif mode == "Most Players" then
            table.sort(list, function(a, b) return a.playing > b.playing end)
            pick = list[1]
        else
            table.sort(list, function(a, b) return a.playing < b.playing end)
            pick = list[1]
        end
        if not pick or (tonumber(pick.playing) or 0) < 1 then
            return "empty"
        end
        Notify("Server Hop", string.format("Hop -> %d pemain", tonumber(pick.playing) or 0), 3)
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LP)
        end)
        return ok and "waiting" or "denied"
    end

    HUB.SetHopMode = function(m) _hopMode = tostring(m or "Least Players") end

    -- kalau teleport gagal -> exclude server itu
    track(TeleportService.TeleportInitFailed:Connect(function(_, _, jobId)
        if jobId then _excluded[jobId] = true end
        Notify("Server Hop", "Teleport gagal, server di-skip.", 3)
    end))
end

-- ============================================================
-- PREDICTOR  (Rift + Egg + Fuse Predictor)
-- ============================================================
-- Library lama pakai CreateCanvas. Airflow tidak punya,
-- jadi di sini dipakai Paragraph + RichText yang di-:Set() berkala.
-- Semua isi tetap SAMA: recipe rift, odds banner, rotasi, isi mesin fuse,
-- distribusi ukuran, dan daftar telur (ready/growing/inventory).
HUB.Predictor = (function()
    local P = {}

    -- ---------- helpers ----------
    local function col(hex, txt) return '<font color="' .. hex .. '">' .. txt .. '</font>' end
    local function bold(txt) return "<b>" .. txt .. "</b>" end
    local function esc(s)
        return (tostring(s or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end
    local function rate(n)
        n = tonumber(n) or 0
        if n >= 1e12 then return string.format("%.2fT/s", n/1e12) end
        if n >= 1e9  then return string.format("%.2fB/s", n/1e9) end
        if n >= 1e6  then return string.format("%.2fM/s", n/1e6) end
        if n >= 1e3  then return string.format("%.2fK/s", n/1e3) end
        return string.format("%d/s", math.floor(n))
    end
    local function clockStr(sec)
        sec = math.max(0, math.floor(tonumber(sec) or 0))
        local h = math.floor(sec / 3600)
        local m = math.floor(sec % 3600 / 60)
        local s = sec % 60
        return string.format("%02dh %02dm %02ds", h, m, s)
    end
    local function assetInfo(cat)
        local d
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            d = AssetsData and (AssetsData.Directory or AssetsData)[cat]
        end)
        if type(d) ~= "table" then return { Name = tostring(cat), Rarity = "?" } end
        local r = d.Rarity
        return {
            Name = tostring(d.DisplayName or cat),
            Rarity = tostring((type(r) == "table" and (r.DisplayName or r._id)) or r or "?"),
            Number = tonumber(type(r) == "table" and (r.RarityNumber or r.Rank)) or 0,
            Rate = tonumber(d.EarningRate) or 0,
        }
    end

    local function save()
        local s
        pcall(function()
            s = require(ReplicatedStorage.Shared.Save).Get()
        end)
        return type(s) == "table" and s or {}
    end

    -- ============================================================
    -- RIFT PREDICTOR
    -- ============================================================
    local _riftMod, _riftState, _riftAt = nil, nil, 0
    local function riftMod()
        if _riftMod == nil then
            _riftMod = false
            pcall(function() _riftMod = require(ReplicatedStorage.Data.Rift) end)
        end
        return _riftMod
    end
    local function call(m, name, ...)
        if type(m) ~= "table" or type(m[name]) ~= "function" then return nil end
        local ok, r = pcall(m[name], ...)
        return ok and r or nil
    end
    local function askState()
        if os.clock() - _riftAt < 5 then return _riftState end
        _riftAt = os.clock()
        local rf = GetNetRemote("RF/Rift/AskState")
        if rf then
            local ok, r = pcall(function() return rf:InvokeServer() end)
            if ok and type(r) == "table" then _riftState = r end
        end
        return _riftState
    end

    function P.RiftText()
        local m = riftMod()
        if type(m) ~= "table" then return "Rift data belum tersedia." end
        local lines = {}
        local rot = tonumber(call(m, "RotationSeconds")) or 10800
        local period = math.floor(workspace:GetServerTimeNow() / rot)
        local bid = call(m, "BannerIdForPeriod", period)
        local bname = bid and (call(m, "GetBannerDisplayName", bid) or tostring(bid)) or "?"

        -- header
        local st = askState()
        lines[#lines+1] = bold(col("#7FD8FF", "AKTIF: " .. esc(bname)))
        if st then
            local nxt = rot - (workspace:GetServerTimeNow() % rot)
            lines[#lines+1] = col("#FFC24D", "Ganti dalam " .. clockStr(nxt))
            if st.Unlocked == false then
                lines[#lines+1] = col("#FF7A7A", "Locked di akun ini")
            else
                lines[#lines+1] = string.format("Pity %s/%s   Free reroll %s",
                    tostring(st.PityCount or 0), tostring(st.PityThreshold or 0),
                    tostring(st.FreeRefreshesRemaining or 0))
            end
            if st.PendingReward then lines[#lines+1] = col("#4DFF7A", "Reward siap di-claim!") end
        end

        -- recipe
        if st and type(st.Requirements) == "table" and #st.Requirements > 0 then
            lines[#lines+1] = ""
            lines[#lines+1] = bold(col("#FFFFFF", "RECIPE"))
            local inv = {}
            for _, it in pairs(save().Inventory or {}) do
                local c = it.Category or it.AssetCategory
                if c then inv[c] = (inv[c] or 0) + 1 end
            end
            for _, req in ipairs(st.Requirements) do
                local info = assetInfo(req)
                local have = inv[tostring(req)] or 0
                local okc = have > 0 and "#4DFF7A" or "#FF7A7A"
                lines[#lines+1] = col(okc, "  • " .. esc(info.Name) .. "  x" .. have)
            end
        end

        -- odds
        local banner = call(m, "GetBanner", bid)
        local pets = type(banner) == "table" and banner.Pets or nil
        if type(pets) == "table" then
            local tot, rows = 0, {}
            for _, p in ipairs(pets) do
                local w = tonumber(call(m, "GetPetWeight", bid, p.AssetId)) or 0
                tot = tot + w
                rows[#rows+1] = { id = p.AssetId, w = w }
            end
            if tot > 0 then
                table.sort(rows, function(a, b) return a.w > b.w end)
                lines[#lines+1] = ""
                lines[#lines+1] = bold(col("#FFFFFF", "ODDS BANNER"))
                for i = 1, math.min(6, #rows) do
                    local info = assetInfo(rows[i].id)
                    local pct = rows[i].w / tot * 100
                    local c = pct >= 10 and "#4DFF7A" or (pct >= 1 and "#FFC24D" or "#FF7A7A")
                    lines[#lines+1] = string.format("  %s  %s", esc(info.Name), col(c, string.format("%.2f%%", pct)))
                end
            end
        end

        -- upcoming
        lines[#lines+1] = ""
        lines[#lines+1] = bold(col("#FFFFFF", "RIFT BERIKUTNYA"))
        for i = 1, 4 do
            local p2 = period + i
            local id2 = call(m, "BannerIdForPeriod", p2)
            local nm2 = id2 and (call(m, "GetBannerDisplayName", id2) or tostring(id2)) or "?"
            local tag = (i == 1) and "NEXT" or ("#" .. i)
            lines[#lines+1] = string.format("  %s  %s  %s", tag, col("#7FD8FF", esc(nm2)), clockStr(i * rot))
        end
        return table.concat(lines, "\n")
    end

    -- ============================================================
    -- EGG PREDICTOR
    -- ============================================================
    function P.EggText()
        local eggs
        pcall(function() eggs = EggState and EggState.ReadOwnerEggs(LP.UserId) end)
        if type(eggs) ~= "table" then return "Data telur belum tersedia." end
        local now = workspace:GetServerTimeNow()
        local ready, growing, inv = {}, {}, {}
        for uid, rec in pairs(eggs) do
            if type(rec) == "table" then
                local info = assetInfo(rec.AssetCategory or rec.Category)
                local inc = info.Rate * scaleFactor(tonumber(rec.AssetScale) or 1)
                    * mutMultiplier(rec.Mutations)
                local row = { Name = info.Name, Inc = inc, Rarity = info.Number,
                              Scale = tonumber(rec.AssetScale) or 1 }
                local isReady = false
                pcall(function() isReady = EggState.IsReadyToHatch(uid) end)
                if rec.Placement ~= nil then
                    local remain = 0
                    pcall(function()
                        remain = EggRecordsMod and EggRecordsMod.GrowthSecondsRemaining(rec, now, 1) or 0
                    end)
                    row.Remain = remain
                    if isReady then table.insert(ready, row) else table.insert(growing, row) end
                elseif isReady then
                    table.insert(ready, row)
                else
                    table.insert(inv, row)
                end
            end
        end
        local function sortRows(t, byTime)
            table.sort(t, function(a, b)
                if byTime then return (a.Remain or 0) < (b.Remain or 0) end
                if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
                return (a.Inc or 0) > (b.Inc or 0)
            end)
        end
        sortRows(ready); sortRows(growing, true); sortRows(inv)

        local lines = {}
        local function section(title, t, hex, limit)
            lines[#lines+1] = bold(col(hex, title .. "  (" .. #t .. ")"))
            if #t == 0 then lines[#lines+1] = "  -" end
            for i = 1, math.min(limit or 8, #t) do
                local r = t[i]
                local extra = r.Remain and ("  " .. clockStr(r.Remain)) or ""
                lines[#lines+1] = string.format("  %s  x%.2f  %s%s",
                    esc(r.Name), r.Scale, rate(r.Inc), extra)
            end
        end
        section("READY TO HATCH", ready, "#4DFF7A", 10)
        lines[#lines+1] = ""
        section("GROWING", growing, "#FFC24D", 10)
        lines[#lines+1] = ""
        section("IN INVENTORY", inv, "#7FD8FF", 10)
        return table.concat(lines, "\n")
    end

    -- ============================================================
    -- FUSE PREDICTOR
    -- ============================================================
    -- Tabel band ukuran (bobot distribusi roll)
    local FUSE_BANDS = {
        { 0.85, 1.05, 2000 }, { 1.45, 1.55, 250 }, { 1.9, 2.1, 125 },
        { 2.85, 3.15, 62.5 }, { 3.8, 4.2, 31.25 }, { 0.3, 0.45, 18 },
        { 0.1, 0.2, 5 }, { 5.8, 6.2, 15.625 }, { 9.5, 12.5, 3 },
        { 12, 17, 0.05 }, { 20, 35, 0.0001 },
    }
    local function bandColor(s)
        if s >= 20 then return "#FF4DE8" elseif s >= 12 then return "#FFD34D"
        elseif s >= 9.5 then return "#FF5C5C" elseif s >= 5.8 then return "#FF9A3D"
        elseif s >= 3.8 then return "#C08BFF" elseif s >= 2.85 then return "#6FA0FF"
        elseif s >= 1.9 then return "#4FE0FF" elseif s >= 1.45 then return "#7CFF9E"
        elseif s >= 0.85 then return "#FFFFFF" elseif s >= 0.3 then return "#C6CDDA" end
        return "#8F98A8"
    end

    function P.FuseText()
        local sv = save()
        local slots = sv.FusionSlots
        local lines = {}
        local items = {}
        if type(slots) == "table" then
            for i = 1, 3 do
                local it = slots[i]
                if type(it) == "table" and (it.Category or it.AssetCategory) then
                    table.insert(items, it)
                end
            end
        end
        lines[#lines+1] = bold(col("#FFFFFF", string.format("MESIN: %d/3 pet", #items)))
        if sv.FusionLocked == true then
            local dur = tonumber(sv.FusionDuration) or 0
            local left = dur > 1e9 and (dur - workspace:GetServerTimeNow()) or 0
            lines[#lines+1] = col("#FFC24D", "Sedang fusing... " .. clockStr(left))
        end
        if type(sv.FusionEggReward) == "table" then
            lines[#lines+1] = col("#4DFF7A", "Fuse selesai - claim egg!")
        end
        if #items == 0 then
            lines[#lines+1] = "Kosong. Isi 3 pet sejenis buat lihat odds."
            return table.concat(lines, "\n")
        end
        -- slot list
        local sum, n = 0, 0
        for i, it in ipairs(items) do
            local info = assetInfo(it.Category or it.AssetCategory)
            local sc = tonumber(it.Scale or it.AssetScale) or 1
            sum = sum + sc; n = n + 1
            lines[#lines+1] = string.format("  SLOT %d  %s  x%.2f  %s",
                i, esc(info.Name), sc, col(bandColor(sc), string.format("%.2f", sc)))
        end
        local avg = n > 0 and (sum / n) or 0
        lines[#lines+1] = "  Rata-rata ukuran: " .. string.format("%.3f", avg)

        -- distribusi
        local tot = 0
        for _, b in ipairs(FUSE_BANDS) do tot = tot + b[3] end
        local rows = {}
        for _, b in ipairs(FUSE_BANDS) do
            -- bias sederhana: makin dekat ke rata-rata, makin besar
            local mid = (b[1] + b[2]) / 2
            local dist = math.abs(mid - avg)
            local w = b[3] / (1 + dist * 1.6)
            rows[#rows+1] = { lo = b[1], hi = b[2], w = w }
        end
        local tw = 0
        for _, r in ipairs(rows) do tw = tw + r.w end
        table.sort(rows, function(a, b) return a.w > b.w end)
        lines[#lines+1] = ""
        lines[#lines+1] = bold(col("#FFFFFF", "PREDIKSI UKURAN"))
        for i = 1, math.min(7, #rows) do
            local r = rows[i]
            local pct = tw > 0 and (r.w / tw * 100) or 0
            local c = pct >= 10 and "#4DFF7A" or (pct >= 1 and "#FFC24D" or "#FF7A7A")
            lines[#lines+1] = string.format("  %s  %s",
                col(bandColor((r.lo+r.hi)/2), string.format("%.2f - %.2f", r.lo, r.hi)),
                col(c, string.format("%.1f%%", pct)))
        end
        return table.concat(lines, "\n")
    end

    -- ============================================================
    -- PREDICTOR PANEL  (ScreenGui mandiri, style modern)
    -- ============================================================
    local OVERLAY = {}
    local gui, win, tabsRow, tabIndicator, statusLabel, scroll, contentY
    local activeTab = "Rift"
    local tabBtns = {}

    -- ---------- theme ----------
    -- warna ambil dari theme aktif (biar panel ikut tema)
    local TH = HUB.Themes and HUB.Themes[HUB.ThemeName or "NhatKhanh"] or {}
    local C_BG      = TH.Background  or Color3.fromRGB(12, 15, 24)
    local C_SURF    = TH.Surface     or Color3.fromRGB(20, 25, 38)
    local C_SURF2   = TH.Surface2    or Color3.fromRGB(26, 32, 48)
    local C_CARD    = TH.Surface3    or Color3.fromRGB(24, 30, 45)
    local C_STROKE  = TH.Stroke      or Color3.fromRGB(40, 50, 72)
    local C_ACCENT  = TH.Accent      or Color3.fromRGB(96, 165, 250)
    local C_ACCENT2 = TH.StrokeHover or Color3.fromRGB(167, 139, 250)
    local C_TEXT    = TH.Text        or Color3.fromRGB(236, 242, 252)
    local C_SUB     = TH.Muted       or Color3.fromRGB(148, 163, 190)
    local C_MUTED   = TH.Muted       or Color3.fromRGB(96, 110, 138)
    local C_GOOD    = TH.Success     or Color3.fromRGB(110, 231, 160)
    local C_WARN    = TH.Warning     or Color3.fromRGB(250, 190, 90)
    local C_BAD     = TH.Error       or Color3.fromRGB(248, 113, 113)
    -- ★ modern: surface ketiga (lebih terang) buat gradient
    local C_SURF3   = TH.Surface3    or (function()
        local b = C_SURF2
        return Color3.new(math.min(b.R + 0.05, 1), math.min(b.G + 0.05, 1), math.min(b.B + 0.06, 1))
    end)()

    local FONT_BOLD, FONT_MED, FONT_REG
    pcall(function()
        FONT_BOLD = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
        FONT_MED  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        FONT_REG  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    end)

    local function hexToColor(hex)
        if type(hex) ~= "string" then return C_TEXT end
        hex = hex:gsub("#", "")
        local n = tonumber(hex, 16)
        if not n then return C_TEXT end
        return Color3.fromRGB(math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
    end

    -- ---------- icon lookup ----------
    local _iconCache = {}
    -- ★ FIX "gambar gak muncul": pakai LOGIKA PERSIS SAMA seperti ESP
    --   (yang terbukti SEMUA gambar muncul). ESP TIDAK menolak string
    --   berdasarkan panjang digit -> kalau d.Icon sudah berupa URL
    --   ("rbxassetid://123" / "rbxthumb://...") langsung dipakai apa adanya.
    local function eggIcon(cat)
        if cat == nil then return nil end
        if _iconCache[cat] ~= nil then return _iconCache[cat] end
        local out = nil
        pcall(function()
            if not AssetsData then AssetsData = require(ReplicatedStorage.Data.Assets) end
            local root = AssetsData and (AssetsData.Directory or AssetsData)
            local d = root and root[cat]
            if type(d) ~= "table" then return end

            -- 1) field utama (sama seperti ESP) -> dipakai APA ADANYA
            local icon = d.Icon or d.ImageId or d.Thumbnail or d.AssetId
            if type(icon) == "number" then icon = "rbxassetid://" .. tostring(icon) end
            if type(icon) == "string" and icon ~= "" then out = icon end

            -- 2) fallback: scan field lain yang menyerupai gambar
            if not out then
                local hints = { "icon", "imageid", "image", "thumbnail", "assetid",
                                "decalid", "picture", "render", "photo", "displayimage" }
                local function looksLikeImage(v)
                    if type(v) == "number" then
                        return #tostring(v) >= 5 and "rbxassetid://" .. tostring(v) or nil
                    end
                    if type(v) ~= "string" or v == "" then return nil end
                    if v:find("rbxassetid") or v:find("rbxthumb") then return v end
                    local num = v:match("id=(%d+)") or v:match("(%d+)")
                    if num and #num >= 5 then return "rbxassetid://" .. num end
                    return nil
                end
                for k, v in pairs(d) do
                    local kn = tostring(k):lower()
                    local isHint = false
                    for _, hh in ipairs(hints) do if kn:find(hh) then isHint = true; break end end
                    local isBad = kn:find("sound") or kn:find("anim") or kn:find("earning")
                        or kn:find("rate") or kn:find("price") or kn:find("weight")
                        or kn:find("color") or kn:find("rarity") or kn:find("scale")
                    if isHint and not isBad then
                        out = looksLikeImage(v); if out then break end
                    end
                end
            end
        end)
        _iconCache[cat] = out
        return out
    end

    -- ---------- small helpers ----------
    local function corner(inst, r)
        local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 8); c.Parent = inst; return c
    end
    local function stroke(inst, col, th, tr)
        local s = Instance.new("UIStroke")
        s.Color = col or C_STROKE; s.Thickness = th or 1; s.Transparency = tr or 0
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Parent = inst; return s
    end
    local function pad(inst, l, r, t, b)
        local p = Instance.new("UIPadding")
        p.PaddingLeft = UDim.new(0, l or 0); p.PaddingRight = UDim.new(0, r or 0)
        p.PaddingTop = UDim.new(0, t or 0);  p.PaddingBottom = UDim.new(0, b or 0)
        p.Parent = inst; return p
    end
    local function label(parent, txt, font, size, col)
        local l = Instance.new("TextLabel")
        l.BackgroundTransparency = 1
        l.Text = txt or ""
        if font then l.FontFace = font else l.Font = Enum.Font.Gotham end
        l.TextSize = size or 13
        l.TextColor3 = col or C_TEXT
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Center
        l.TextTruncate = Enum.TextTruncate.AtEnd
        l.RichText = false
        l.Parent = parent
        return l
    end

    -- ---------- icon container (rounded + rarity glow) ----------
    local function iconBox(parent, size, accent)
        local box = Instance.new("Frame")
        box.Size = UDim2.fromOffset(size, size)
        box.BackgroundColor3 = C_SURF2
        box.BorderSizePixel = 0
        box.Parent = parent
        corner(box, math.floor(size * 0.30))
        stroke(box, accent or C_STROKE, 1.2, 0.25)

        -- ★ modern: gradient halus di belakang icon
        local bg = Instance.new("UIGradient")
        bg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C_SURF3),
            ColorSequenceKeypoint.new(1, C_SURF2),
        }
        bg.Rotation = 135
        bg.Parent = box

        local img = Instance.new("ImageLabel")
        img.Size = UDim2.fromScale(0.80, 0.80)
        img.Position = UDim2.fromScale(0.10, 0.10)
        img.BackgroundTransparency = 1
        img.ScaleType = Enum.ScaleType.Fit
        img.Image = ""
        img.ZIndex = 2
        img.Parent = box

        -- placeholder: lingkaran kecil, tampil kalau gambar gak ada
        local ph = Instance.new("Frame")
        ph.Name = "Placeholder"
        ph.AnchorPoint = Vector2.new(0.5, 0.5)
        ph.Position = UDim2.fromScale(0.5, 0.5)
        ph.Size = UDim2.fromScale(0.34, 0.34)
        ph.BackgroundColor3 = C_MUTED
        ph.BackgroundTransparency = 0.45
        ph.BorderSizePixel = 0
        ph.Parent = box
        corner(ph, 99)
        img:GetPropertyChangedSignal("Image"):Connect(function()
            ph.Visible = (img.Image == nil or img.Image == "")
        end)

        -- ★ FALLBACK: kalau "rbxassetid://<id>" tidak ter-load (asset-nya
        --   bukan gambar biasa / butuh thumbnail), coba "rbxthumb://" setelah
        --   jeda singkat. Ini bikin SEMUA gambar muncul seperti ESP.
        local setImage = function(url)
            if type(url) ~= "string" or url == "" then return end
            img.Image = url
            local num = url:match("(%d+)")
            if not num then return end
            task.delay(0.85, function()
                if not img or not img.Parent then return end
                if img.IsLoaded then return end
                if img.Image ~= url then return end   -- sudah diganti yang lain
                local alt = "rbxthumb://type=Asset&id=" .. num .. "&w=150&h=150"
                if img.Image ~= alt then img.Image = alt end
            end)
        end
        return box, img, setImage
    end

    -- ---------- CARD ----------
    -- card: icon (opsional), title, sub, badge (kanan atas), accent
    local function card(order, opts)
        local h = opts.h or 52
        local f = Instance.new("Frame")
        f.Name = "Card"
        f.Size = UDim2.new(1, -14, 0, h)
        f.BackgroundColor3 = C_CARD
        f.BackgroundTransparency = 0.03
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = scroll
        corner(f, 11)
        -- ★ modern: border tipis + gradient subtle
        stroke(f, C_STROKE, 1, 0.55)
        do
            local cg = Instance.new("UIGradient")
            cg.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0, C_SURF3),
                ColorSequenceKeypoint.new(1, C_CARD),
            }
            cg.Rotation = 90
            cg.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0.55),
                NumberSequenceKeypoint.new(1, 0.95),
            }
            cg.Parent = f
        end

        -- accent bar kiri
        if opts.accent then
            local bar = Instance.new("Frame")
            bar.Size = UDim2.new(0, 3, 1, -14)
            bar.Position = UDim2.new(0, 0, 0, 7)
            bar.BackgroundColor3 = opts.accent
            bar.BorderSizePixel = 0
            bar.ZIndex = 3
            bar.Parent = f
            corner(bar, 2)
            local bg2 = Instance.new("UIGradient")
            bg2.Color = ColorSequence.new(opts.accent, C_ACCENT2)
            bg2.Rotation = 90
            bg2.Transparency = NumberSequence.new{
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 0.45),
            }
            bg2.Parent = bar
        end

        local textX = 12
        if opts.iconSize then
            local box, img, setImage = iconBox(f, opts.iconSize, opts.accent)
            box.Position = UDim2.fromOffset(10, math.floor((h - opts.iconSize) / 2))
            local url = (opts.iconId and opts.iconId ~= "") and opts.iconId or opts.icon
            if setImage then pcall(setImage, url) end
            textX = 10 + opts.iconSize + 10
        end

        local titleY = opts.sub and math.floor(h * 0.5) - 17 or math.floor(h * 0.5) - 9
        local t = label(f, opts.title, FONT_MED, opts.titleSize or 13, opts.titleColor or C_TEXT)
        t.Position = UDim2.fromOffset(textX, titleY)
        t.Size = UDim2.new(1, -(textX + (opts.badge and 68 or 12)), 0, 18)

        if opts.sub then
            local s = label(f, opts.sub, FONT_REG, 11, opts.subColor or C_SUB)
            s.Position = UDim2.fromOffset(textX, titleY + 18)
            s.Size = UDim2.new(1, -(textX + (opts.badge and 68 or 12)), 0, 16)
            s.TextTruncate = Enum.TextTruncate.AtEnd
        end

        if opts.badge then
            local b = Instance.new("TextLabel")
            b.AnchorPoint = Vector2.new(1, 0)
            b.Position = UDim2.new(1, -10, 0, 9)
            b.Size = UDim2.fromOffset(58, 18)
            b.BackgroundColor3 = opts.badgeColor or C_SURF2
            b.BackgroundTransparency = 0.1
            b.Text = opts.badge
            if FONT_MED then b.FontFace = FONT_MED else b.Font = Enum.Font.GothamBold end
            b.TextSize = 11
            b.TextColor3 = opts.badgeText or C_TEXT
            b.BorderSizePixel = 0
            b.Parent = f
            corner(b, 6)
        end
        return f
    end

    -- ---------- HERO (stat besar) ----------
    local function hero(order, opts)
        local f = Instance.new("Frame")
        f.Name = "Hero"
        f.Size = UDim2.new(1, -14, 0, 76)
        f.BackgroundColor3 = C_SURF
        f.BorderSizePixel = 0
        f.LayoutOrder = order
        f.Parent = scroll
        corner(f, 12)
        stroke(f, opts.accent or C_ACCENT, 1, 0.5)

        -- ★ modern: gradient diagonal 3-stop + glow halus
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, opts.accent or C_ACCENT),
            ColorSequenceKeypoint.new(0.55, C_ACCENT2),
            ColorSequenceKeypoint.new(1, C_SURF),
        }
        g.Rotation = 25
        g.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.80),
            NumberSequenceKeypoint.new(0.55, 0.90),
            NumberSequenceKeypoint.new(1, 1),
        }
        g.Parent = f

        local t = label(f, opts.title, FONT_BOLD, 12, C_SUB)
        t.Position = UDim2.fromOffset(14, 9); t.Size = UDim2.new(1, -28, 0, 16)

        local s = label(f, opts.sub, FONT_BOLD, 21, opts.accent or C_ACCENT)
        s.Position = UDim2.fromOffset(14, 24); s.Size = UDim2.new(1, -28, 0, 28)

        if opts.foot then
            local ft = label(f, opts.foot, FONT_REG, 11, C_SUB)
            ft.Position = UDim2.fromOffset(14, 52); ft.Size = UDim2.new(1, -28, 0, 15)
        end
        return f
    end

    -- ---------- SECTION HEADER ----------
    local function section(order, txt, col)
        local f = Instance.new("Frame")
        f.Name = "Section"
        f.Size = UDim2.new(1, -10, 0, 22)
        f.BackgroundTransparency = 1
        f.LayoutOrder = order
        f.Parent = scroll

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(3, 12)
        dot.Position = UDim2.new(0, 2, 0.5, -6)
        dot.BackgroundColor3 = col or C_ACCENT
        dot.BorderSizePixel = 0
        dot.Parent = f
        corner(dot, 2)

        local l = label(f, string.upper(txt), FONT_BOLD, 11, col or C_ACCENT)
        l.Position = UDim2.fromOffset(12, 0)
        l.Size = UDim2.new(1, -14, 1, 0)
        return f
    end

    -- ---------- pools ----------
    local pool = {}
    local function clearRows()
        for _, r in ipairs(pool) do pcall(function() r:Destroy() end) end
        table.clear(pool)
    end
    local function add(inst) table.insert(pool, inst); return inst end
    local function nextCard(order, opts) return add(card(order, opts)) end
    local function nextHero(order, opts) return add(hero(order, opts)) end
    local function nextSection(order, txt, col) return add(section(order, txt, col)) end

    -- ============================================================
    -- RENDERERS
    -- ============================================================
    local function renderRift()
        clearRows()
        local o = 0
        local m = riftMod()
        if type(m) ~= "table" then
            o = o + 1; nextCard(o, { title = "Rift data unavailable", sub = "Wait for the game to load", h = 48 })
            return
        end
        local rot = tonumber(call(m, "RotationSeconds")) or 10800
        local period = math.floor(workspace:GetServerTimeNow() / rot)
        local bid = call(m, "BannerIdForPeriod", period)
        local bname = bid and (call(m, "GetBannerDisplayName", bid) or tostring(bid)) or "?"
        local left = rot - (workspace:GetServerTimeNow() % rot)

        o = o + 1
        nextHero(o, { title = "ACTIVE RIFT", sub = tostring(bname),
            foot = "Rotates in " .. clockStr(left), accent = C_ACCENT })

        local st = askState()
        if st then
            o = o + 1
            if st.Unlocked == false then
                nextCard(o, { title = "Locked on this account", sub = "Rift not unlocked yet",
                    accent = C_BAD, badge = "LOCKED", badgeColor = C_BAD, badgeText = Color3.new(1,1,1) })
            else
                nextCard(o, {
                    title = string.format("Pity  %s / %s", tostring(st.PityCount or 0), tostring(st.PityThreshold or 0)),
                    sub = string.format("Free rerolls: %s", tostring(st.FreeRefreshesRemaining or 0)),
                    accent = C_GOOD,
                })
            end
            if st.PendingReward then
                o = o + 1
                nextCard(o, { title = "Reward ready to claim!", sub = "Open the rift to collect",
                    accent = C_GOOD, badge = "CLAIM", badgeColor = C_GOOD, badgeText = Color3.fromRGB(10,30,20) })
            end
        end

        -- recipe
        if st and type(st.Requirements) == "table" and #st.Requirements > 0 then
            o = o + 1; nextSection(o, "Current Recipe", C_ACCENT2)
            local inv = {}
            for _, it in pairs(save().Inventory or {}) do
                local c = it.Category or it.AssetCategory
                if c then inv[c] = (inv[c] or 0) + 1 end
            end
            for _, req in ipairs(st.Requirements) do
                o = o + 1
                local info = assetInfo(req)
                local have = inv[tostring(req)] or 0
                local okc = have > 0
                nextCard(o, {
                    h = 48, iconSize = 32, iconId = eggIcon(req),
                    title = info.Name, sub = "Have " .. have,
                    accent = okc and C_GOOD or C_BAD,
                    badge = okc and "READY" or "MISSING",
                    badgeColor = okc and C_GOOD or C_BAD,
                    badgeText = okc and Color3.fromRGB(10,30,20) or Color3.new(1,1,1),
                })
            end
        end

        -- odds
        local banner = call(m, "GetBanner", bid)
        local pets = type(banner) == "table" and banner.Pets or nil
        if type(pets) == "table" then
            local tot, rows = 0, {}
            for _, p in ipairs(pets) do
                local w = tonumber(call(m, "GetPetWeight", bid, p.AssetId)) or 0
                tot = tot + w
                rows[#rows+1] = { id = p.AssetId, w = w }
            end
            if tot > 0 then
                table.sort(rows, function(a, b) return a.w > b.w end)
                o = o + 1; nextSection(o, "Reward Odds", C_ACCENT)
                for i = 1, math.min(12, #rows) do
                    o = o + 1
                    local info = assetInfo(rows[i].id)
                    local pct = rows[i].w / tot * 100
                    local col = pct >= 10 and C_GOOD or (pct >= 1 and C_WARN or C_BAD)
                    nextCard(o, {
                        h = 48, iconSize = 32, iconId = eggIcon(rows[i].id),
                        title = info.Name,
                        sub = string.format("1 in %.0f", tot / math.max(rows[i].w, 0.0001)),
                        accent = col,
                        badge = string.format("%.2f%%", pct), badgeColor = col,
                        badgeText = Color3.fromRGB(12, 16, 24),
                    })
                end
            end
        end

        -- upcoming
        o = o + 1; nextSection(o, "Upcoming Rifts", C_SUB)
        for i = 1, 5 do
            o = o + 1
            local id2 = call(m, "BannerIdForPeriod", period + i)
            local nm2 = id2 and (call(m, "GetBannerDisplayName", id2) or tostring(id2)) or "?"
            nextCard(o, {
                h = 44, title = tostring(nm2),
                sub = "in " .. clockStr(i * rot),
                badge = (i == 1) and "NEXT" or ("#" .. i),
                badgeColor = (i == 1) and C_ACCENT or C_SURF2,
                badgeText = (i == 1) and Color3.new(1,1,1) or C_SUB,
            })
        end
    end

    local function renderEggs()
        clearRows()
        local o = 0
        local eggs
        pcall(function() eggs = EggState and EggState.ReadOwnerEggs(LP.UserId) end)
        if type(eggs) ~= "table" then
            o = o + 1; nextCard(o, { title = "Egg data unavailable", sub = "Wait for the game to load", h = 48 })
            return
        end
        local now = workspace:GetServerTimeNow()
        local ready, growing, inv = {}, {}, {}
        local total = 0
        for uid, rec in pairs(eggs) do
            if type(rec) == "table" then
                total = total + 1
                local info = assetInfo(rec.AssetCategory or rec.Category)
                local inc = info.Rate * scaleFactor(tonumber(rec.AssetScale) or 1) * mutMultiplier(rec.Mutations)
                local row = { cat = rec.AssetCategory or rec.Category, Name = info.Name,
                              Inc = inc, Rarity = info.Number, Scale = tonumber(rec.AssetScale) or 1 }
                local isReady = false
                pcall(function() isReady = EggState.IsReadyToHatch(uid) end)
                if rec.Placement ~= nil then
                    local remain = 0
                    pcall(function()
                        remain = EggRecordsMod and EggRecordsMod.GrowthSecondsRemaining(rec, now, 1) or 0
                    end)
                    row.Remain = remain
                    if isReady then table.insert(ready, row) else table.insert(growing, row) end
                elseif isReady then
                    table.insert(ready, row)
                else
                    table.insert(inv, row)
                end
            end
        end
        local function srt(t, byTime)
            table.sort(t, function(a, b)
                if byTime then return (a.Remain or 0) < (b.Remain or 0) end
                if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
                return (a.Inc or 0) > (b.Inc or 0)
            end)
        end
        srt(ready); srt(growing, true); srt(inv)

        o = o + 1
        nextHero(o, { title = "TOTAL EGGS", sub = tostring(total),
            foot = string.format("%d ready  ·  %d growing  ·  %d in bag", #ready, #growing, #inv),
            accent = C_ACCENT })

        local function group(title, t, col, showTimer)
            o = o + 1
            nextSection(o, title .. "  (" .. #t .. ")", col)
            if #t == 0 then
                o = o + 1
                nextCard(o, { h = 40, title = "-", sub = "nothing here", titleColor = C_MUTED })
                return
            end
            for i = 1, math.min(20, #t) do
                o = o + 1
                local e = t[i]
                local sub = string.format("x%.2f   %s/s", e.Scale, rate(e.Inc))
                if showTimer and e.Remain then sub = sub .. "   " .. clockStr(e.Remain) end
                nextCard(o, {
                    h = 48, iconSize = 32, iconId = eggIcon(e.cat),
                    title = e.Name, sub = sub, accent = col,
                })
            end
        end
        group("Ready to Hatch", ready, C_GOOD, false)
        group("Growing", growing, C_WARN, true)
        group("In Inventory", inv, C_ACCENT, false)
    end

    local function renderFuse()
        clearRows()
        local o = 0
        local sv = save()
        local slots = sv.FusionSlots
        local items = {}
        if type(slots) == "table" then
            for i = 1, 3 do
                local it = slots[i]
                if type(it) == "table" and (it.Category or it.AssetCategory) then
                    table.insert(items, it)
                end
            end
        end

        local locked = sv.FusionLocked == true
        local dur = tonumber(sv.FusionDuration) or 0
        local left = (locked and dur > 1e9) and (dur - workspace:GetServerTimeNow()) or 0

        o = o + 1
        nextHero(o, {
            title = "FUSE MACHINE",
            sub = locked and "FUSING..." or (string.format("%d / 3 loaded", #items)),
            foot = locked and ("Hoàn tất in " .. clockStr(left))
                or (type(sv.FusionEggReward) == "table" and "Reward ready to claim!" or "Load 3 same-species pets"),
            accent = locked and C_WARN or (type(sv.FusionEggReward) == "table" and C_GOOD or C_ACCENT),
        })

        if type(sv.FusionEggReward) == "table" then
            o = o + 1
            nextCard(o, { title = "Fuse finished", sub = "Claim your egg from the machine",
                accent = C_GOOD, badge = "CLAIM", badgeColor = C_GOOD, badgeText = Color3.fromRGB(10,30,20) })
        end

        if #items == 0 then
            o = o + 1
            nextCard(o, { h = 46, title = "Machine is empty", sub = "Load 3 pets of the same species", titleColor = C_SUB })
            return
        end

        o = o + 1; nextSection(o, "Đã tải xong Pets", C_ACCENT)
        local sum, n = 0, 0
        for i, it in ipairs(items) do
            o = o + 1
            local cat = it.Category or it.AssetCategory
            local info = assetInfo(cat)
            local sc = tonumber(it.Scale or it.AssetScale) or 1
            sum = sum + sc; n = n + 1
            nextCard(o, {
                h = 48, iconSize = 32, iconId = eggIcon(cat),
                title = string.format("Slot %d  ·  %s", i, info.Name),
                sub = string.format("x%.2f", sc),
                badge = string.format("x%.2f", sc), badgeColor = C_SURF2, badgeText = C_TEXT,
            })
        end
        local avg = n > 0 and (sum / n) or 0

        o = o + 1
        nextHero(o, { title = "AVERAGE SCALE", sub = string.format("%.3f", avg),
            foot = "Used to weight the size roll", accent = C_ACCENT2 })

        -- distribusi
        o = o + 1; nextSection(o, "Predicted Size", C_ACCENT)
        local rows, totw = {}, 0
        for _, b in ipairs(FUSE_BANDS) do
            local mid = (b[1] + b[2]) / 2
            local dist = math.abs(mid - avg)
            local w = b[3] / (1 + dist * 1.6)
            rows[#rows+1] = { lo = b[1], hi = b[2], w = w }
            totw = totw + w
        end
        table.sort(rows, function(a, b) return a.w > b.w end)
        for i = 1, math.min(8, #rows) do
            o = o + 1
            local r = rows[i]
            local pct = totw > 0 and (r.w / totw * 100) or 0
            local col = pct >= 10 and C_GOOD or (pct >= 1 and C_WARN or C_BAD)
            nextCard(o, {
                h = 40,
                title = string.format("%.2f  -  %.2f", r.lo, r.hi),
                sub = string.format("%.3f%%", pct),
                titleColor = col,
                badge = string.format("%.1f%%", pct), badgeColor = col,
                badgeText = Color3.fromRGB(12, 16, 24),
            })
        end
    end

    local RENDERERS = { Rift = renderRift, Eggs = renderEggs, Fuse = renderFuse }

    -- ============================================================
    -- PUBLIC API
    -- ============================================================
    function OVERLAY.Refresh()
        if not gui or not gui.Parent then return end
        local fn = RENDERERS[activeTab]
        if fn then
            local ok, err = pcall(fn)
            if not ok then
                clearRows()
                nextCard(1, { title = "Error", sub = tostring(err), accent = C_BAD })
            end
        end
        if statusLabel then
            statusLabel.Text = "Updated " .. os.date("%H:%M:%S")
        end
        if scroll then
            pcall(function() scroll.CanvasPosition = Vector2.new(0, 0) end)
        end
    end

    function OVERLAY.SetTab(name)
        activeTab = name
        for n, b in pairs(tabBtns) do
            local on = (n == name)
            b.TextColor3 = on and Color3.new(1, 1, 1) or C_MUTED
            b.BackgroundColor3 = on and C_ACCENT or C_SURF2
            b.BackgroundTransparency = on and 0 or 0.55
            -- ★ modern: tab aktif dapat stroke accent
            if b:FindFirstChildOfClass("UIStroke") then
                b:FindFirstChildOfClass("UIStroke").Transparency = on and 0.3 or 1
            end
        end
        OVERLAY.Refresh()
    end

    function OVERLAY.Hide()
        if gui then gui.Enabled = false end
    end

    -- ★ state minimize disimpan di level modul supaya Show() bisa
    --   memulihkan window kalau dibuka lagi (dulu bisa "nyangkut" 46px).
    local winMinimized = false
    local restoreFn = nil

    function OVERLAY.IsOpen()
        return gui ~= nil and gui.Parent ~= nil and gui.Enabled
    end

    function OVERLAY.Show()
        if gui and gui.Parent then
            gui.Enabled = true
            -- ★ kalau sebelumnya minimize, kembalikan ke ukuran penuh
            if winMinimized and restoreFn then pcall(restoreFn, false) end
            OVERLAY.Refresh()
            return
        end

        gui = Instance.new("ScreenGui")
        gui.Name = "AscendPredictor"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 55
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Enabled = true   -- ★ eksplisit (biar pasti terbuka)
        gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

        -- restore pos/size  (★ modern: default lebih lega)
        local sw, sh, spx, spy = 372, 500, 380, 80
        pcall(function()
            if readfile and isfile and isfile("Ascend_Predictor.json") then
                local d = game:GetService("HttpService"):JSONDecode(readfile("Ascend_Predictor.json"))
                if type(d) == "table" then
                    sw = math.clamp(tonumber(d.W) or sw, 280, 900)
                    sh = math.clamp(tonumber(d.H) or sh, 240, 900)
                    spx = tonumber(d.PX) or spx
                    spy = tonumber(d.PY) or spy
                end
            end
        end)

        -- ★ modern: drop shadow di belakang window
        local shadow = Instance.new("ImageLabel")
        shadow.Name = "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
        shadow.Size = UDim2.new(1, 44, 1, 44)
        shadow.BackgroundTransparency = 1
        shadow.Image = "rbxassetid://6014261993"
        shadow.ImageColor3 = Color3.new(0, 0, 0)
        shadow.ImageTransparency = 0.55
        shadow.ScaleType = Enum.ScaleType.Slice
        shadow.SliceCenter = Rect.new(49, 49, 450, 450)
        shadow.ZIndex = 0
        shadow.Parent = gui

        win = Instance.new("Frame")
        win.Name = "Window"
        win.Size = UDim2.fromOffset(sw, sh)
        win.Position = UDim2.new(0, spx, 0, spy)
        win.BackgroundColor3 = C_BG
        win.BorderSizePixel = 0
        win.Active = true
        win.ClipsDescendants = true
        win.ZIndex = 2
        win.Parent = gui
        corner(win, 14)
        stroke(win, C_STROKE, 1.4, 0.35)
        -- gradient halus di seluruh window
        local wbg = Instance.new("UIGradient")
        wbg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C_SURF2),
            ColorSequenceKeypoint.new(0.35, C_BG),
            ColorSequenceKeypoint.new(1, C_BG),
        }
        wbg.Rotation = 105
        wbg.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.82),
            NumberSequenceKeypoint.new(1, 0.98),
        }
        wbg.Parent = win
        -- shadow ikut window saat dipindah/di-resize
        local function syncShadow()
            shadow.Position = UDim2.new(
                win.Position.X.Scale, win.Position.X.Offset,
                win.Position.Y.Scale, win.Position.Y.Offset + 8)
            shadow.Size = UDim2.new(
                win.Size.X.Scale, win.Size.X.Offset + 44,
                win.Size.Y.Scale, win.Size.Y.Offset + 44)
        end
        syncShadow()
        win:GetPropertyChangedSignal("Position"):Connect(syncShadow)
        win:GetPropertyChangedSignal("Size"):Connect(syncShadow)

        -- ================= HEADER =================
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 54)
        header.BackgroundColor3 = C_SURF
        header.BorderSizePixel = 0
        header.ZIndex = 3
        -- ★ FIX DRAG: Frame default-nya Active=false -> input "lewat" saja,
        --   jadi header.InputBegan TIDAK PERNAH jalan -> window tidak bisa
        --   di-drag sama sekali. Wajib Active=true.
        header.Active = true
        header.Parent = win
        local hg = Instance.new("UIGradient")
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, C_ACCENT),
            ColorSequenceKeypoint.new(0.35, C_ACCENT2),
            ColorSequenceKeypoint.new(1, C_SURF),
        }
        hg.Rotation = 18
        hg.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.62),
            NumberSequenceKeypoint.new(0.35, 0.80),
            NumberSequenceKeypoint.new(1, 0.97),
        }
        hg.Parent = header
        -- garis accent tipis di bawah header
        local hline = Instance.new("Frame")
        hline.Size = UDim2.new(1, 0, 0, 1)
        hline.Position = UDim2.new(0, 0, 1, -1)
        hline.BackgroundColor3 = C_ACCENT
        hline.BackgroundTransparency = 0.55
        hline.BorderSizePixel = 0
        hline.ZIndex = 4
        hline.Parent = header

        -- ★ FIX "panel jelek": pakai LOGO HUB (gambar asli), bukan diamond.
        local logoSrc = (typeof(LOGO_ID) == "string" and LOGO_ID ~= "")
            and LOGO_ID or "rbxassetid://95983323492030"
        local logoBox = Instance.new("Frame")
        logoBox.Size = UDim2.fromOffset(32, 32)
        logoBox.Position = UDim2.fromOffset(12, 11)
        logoBox.ZIndex = 4
        logoBox.BackgroundColor3 = C_SURF2
        logoBox.BackgroundTransparency = 0.35
        logoBox.BorderSizePixel = 0
        logoBox.Parent = header
        corner(logoBox, 8)
        stroke(logoBox, C_ACCENT, 1, 0.6)
        local logo = Instance.new("ImageLabel")
        logo.Size = UDim2.fromScale(0.82, 0.82)
        logo.Position = UDim2.fromScale(0.09, 0.09)
        logo.BackgroundTransparency = 1
        logo.Image = logoSrc
        logo.ScaleType = Enum.ScaleType.Fit
        logo.Parent = logoBox
        -- fallback ke diamond lama kalau logo gagal load
        task.delay(1.0, function()
            if logo and logo.Parent and not logo.IsLoaded then
                logo.Visible = false
                local dm = Instance.new("Frame")
                dm.Size = UDim2.fromScale(0.55, 0.55)
                dm.AnchorPoint = Vector2.new(0.5, 0.5)
                dm.Position = UDim2.fromScale(0.5, 0.5)
                dm.BackgroundColor3 = C_ACCENT
                dm.BorderSizePixel = 0
                dm.Rotation = 45
                dm.Parent = logoBox
                corner(dm, 4)
            end
        end)

        local title = label(header, "!Gp4q Hub", FONT_BOLD, 15, C_TEXT)
        title.Position = UDim2.fromOffset(52, 9)
        title.Size = UDim2.new(1, -150, 0, 17)
        title.ZIndex = 4
        local sub = label(header, "PREDICTOR", FONT_MED, 10, C_ACCENT)
        sub.Position = UDim2.fromOffset(52, 26)
        sub.Size = UDim2.new(1, -150, 0, 13)
        sub.ZIndex = 4

        -- window buttons
        local function winBtn(txt, xoff, col, fn)
            local b = Instance.new("TextButton")
            b.AnchorPoint = Vector2.new(1, 0.5)
            b.Position = UDim2.new(1, xoff, 0, 27)
            b.Size = UDim2.fromOffset(28, 28)
            b.BackgroundColor3 = col
            b.BackgroundTransparency = 0.82
            b.Text = txt
            if FONT_BOLD then b.FontFace = FONT_BOLD else b.Font = Enum.Font.GothamBold end
            b.TextSize = 14
            b.TextColor3 = C_TEXT
            b.BorderSizePixel = 0
            b.AutoButtonColor = true
            b.Parent = header
            corner(b, 7)
            b.MouseEnter:Connect(function() b.BackgroundTransparency = 0.62 end)
            b.MouseLeave:Connect(function() b.BackgroundTransparency = 0.82 end)
            b.MouseButton1Click:Connect(fn)
            return b
        end
        winBtn("✕", -10, C_BAD, function() OVERLAY.Hide() end)
        local minimized = false
        local minBtn
        -- ★ FIX MINIMIZE: dulu cuma mengecilkan window jadi 46px, tapi
        --   tabBar/scroll/footer/grip TIDAK disembunyikan (dan didefinisikan
        --   SETELAH blok ini, jadi tidak bisa diakses). Akibatnya sisa UI
        --   tetap "nyangkut" & tombol restore tidak jalan.
        --   Sekarang: setMinimized() dideklarasikan di sini, diisi nanti
        --   setelah semua elemen ada.
        local setMinimized
        minBtn = winBtn("—", -42, C_SURF2, function()
            minimized = not minimized
            if setMinimized then setMinimized(minimized) end
        end)

        -- drag from header
        local dragging, dragStart, dragOrigin = false, nil, nil
        header.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; dragOrigin = win.Position
            end
        end)
        header.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        track(game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if not dragging or not gui or not gui.Parent then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
               or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - dragStart
                win.Position = UDim2.new(dragOrigin.X.Scale, dragOrigin.X.Offset + d.X,
                                         dragOrigin.Y.Scale, dragOrigin.Y.Offset + d.Y)
            end
        end))
        track(game:GetService("UserInputService").InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                pcall(function()
                    if writefile then
                        writefile("Ascend_Predictor.json", game:GetService("HttpService"):JSONEncode({
                            W = math.floor(win.AbsoluteSize.X), H = math.floor(win.AbsoluteSize.Y),
                            PX = win.Position.X.Offset, PY = win.Position.Y.Offset }))
                    end
                end)
            end
        end))

        -- ================= TAB BAR =================
        local tabBar = Instance.new("Frame")
        tabBar.Name = "TabBar"
        tabBar.Size = UDim2.new(1, -62, 0, 38)
        tabBar.Position = UDim2.fromOffset(10, 62)
        tabBar.BackgroundColor3 = C_SURF2
        tabBar.BackgroundTransparency = 0.4
        tabBar.BorderSizePixel = 0
        tabBar.Parent = win
        corner(tabBar, 9)

        tabsRow = Instance.new("Frame")
        tabsRow.Size = UDim2.fromScale(1, 1)
        tabsRow.BackgroundTransparency = 1
        tabsRow.Parent = tabBar
        pad(tabsRow, 3, 3, 3, 3)
        local tl = Instance.new("UIListLayout")
        tl.FillDirection = Enum.FillDirection.Horizontal
        tl.Padding = UDim.new(0, 3)
        tl.Parent = tabsRow

        local tabNames = { "Rift", "Eggs", "Fuse" }
        for _, name in ipairs(tabNames) do
            local b = Instance.new("TextButton")
            b.Name = name
            b.Size = UDim2.new(1 / #tabNames, -2, 1, 0)
            b.BackgroundColor3 = C_SURF2
            b.BackgroundTransparency = 0.35
            b.Text = name
            if FONT_MED then b.FontFace = FONT_MED else b.Font = Enum.Font.GothamBold end
            b.TextSize = 13
            b.TextColor3 = C_MUTED
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Parent = tabsRow
            corner(b, 9)
            stroke(b, C_ACCENT, 1, 1)   -- ★ modern: accent stroke (aktif saja)
            b.MouseEnter:Connect(function()
                if activeTab ~= name then b.BackgroundTransparency = 0.2 end
            end)
            b.MouseLeave:Connect(function()
                if activeTab ~= name then b.BackgroundTransparency = 0.45 end
            end)
            b.MouseButton1Click:Connect(function() OVERLAY.SetTab(name) end)
            tabBtns[name] = b
        end

        -- refresh icon button (kanan tab bar)
        local refreshBtn = Instance.new("TextButton")
        refreshBtn.Name = "Refresh"
        refreshBtn.AnchorPoint = Vector2.new(1, 0)
        refreshBtn.Position = UDim2.new(1, -10, 0, 62)
        refreshBtn.Size = UDim2.fromOffset(38, 38)
        refreshBtn.BackgroundColor3 = C_SURF2
        refreshBtn.BackgroundTransparency = 0.2
        refreshBtn.Text = "⟳"
        refreshBtn.Font = Enum.Font.GothamBold
        refreshBtn.TextSize = 19
        refreshBtn.TextColor3 = C_ACCENT
        refreshBtn.BorderSizePixel = 0
        refreshBtn.Parent = win
        corner(refreshBtn, 9)
        stroke(refreshBtn, C_ACCENT, 1, 0.75)
        refreshBtn.MouseEnter:Connect(function() refreshBtn.BackgroundTransparency = 0 end)
        refreshBtn.MouseLeave:Connect(function() refreshBtn.BackgroundTransparency = 0.2 end)
        refreshBtn.MouseButton1Click:Connect(function()
            refreshBtn.Rotation = 0
            task.spawn(function()
                for i = 1, 6 do
                    refreshBtn.Rotation = i * 60
                    task.wait(0.03)
                end
                refreshBtn.Rotation = 0
            end)
            OVERLAY.Refresh()
        end)

        -- ================= SCROLL =================
        scroll = Instance.new("ScrollingFrame")
        scroll.Name = "Content"
        scroll.Size = UDim2.new(1, -16, 1, -160)
        scroll.Position = UDim2.fromOffset(8, 108)
        scroll.BackgroundTransparency = 1
        scroll.BorderSizePixel = 0
        scroll.ScrollBarThickness = 4
        scroll.ScrollBarImageColor3 = C_ACCENT
        scroll.ScrollBarImageTransparency = 0.55
        scroll.CanvasSize = UDim2.new()
        scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        scroll.ScrollingDirection = Enum.ScrollingDirection.Y
        scroll.Parent = win
        local sl = Instance.new("UIListLayout")
        sl.SortOrder = Enum.SortOrder.LayoutOrder
        sl.Padding = UDim.new(0, 8)   -- ★ modern: spacing lebih lega
        sl.Parent = scroll
        pad(scroll, 3, 7, 5, 10)

        -- ================= FOOTER =================
        local footer = Instance.new("Frame")
        footer.Name = "Footer"
        footer.Size = UDim2.new(1, 0, 0, 26)
        footer.Position = UDim2.new(0, 0, 1, -26)
        footer.BackgroundColor3 = C_SURF
        footer.BackgroundTransparency = 0.3
        footer.BorderSizePixel = 0
        footer.Parent = win
        statusLabel = label(footer, "Ready  ·  drag header to move", FONT_REG, 11, C_MUTED)
        statusLabel.Position = UDim2.fromOffset(12, 0)
        statusLabel.Size = UDim2.new(1, -44, 1, 0)

        -- ================= RESIZE GRIP =================
        local grip = Instance.new("TextButton")
        grip.Name = "ResizeGrip"
        grip.Size = UDim2.fromOffset(26, 26)
        grip.Position = UDim2.new(1, -26, 1, -26)
        grip.BackgroundTransparency = 1
        grip.Text = ""
        grip.AutoButtonColor = false
        grip.ZIndex = 5
        grip.Parent = win
        for i = 1, 3 do
            local line = Instance.new("Frame")
            line.Size = UDim2.fromOffset(1.5, 3 + i * 3)
            line.Position = UDim2.new(1, -6 - i * 5, 1, -6 - i * 5)
            line.Rotation = 45
            line.BackgroundColor3 = C_MUTED
            line.BorderSizePixel = 0
            line.ZIndex = 6
            line.Parent = grip
        end

        local resizing, resizeStart, sizeStart = false, nil, nil
        grip.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then
                resizing = true; resizeStart = inp.Position; sizeStart = win.AbsoluteSize
            end
        end)
        local function save()
            pcall(function()
                if writefile then
                    writefile("Ascend_Predictor.json", game:GetService("HttpService"):JSONEncode({
                        W = math.floor(win.AbsoluteSize.X), H = math.floor(win.AbsoluteSize.Y),
                        PX = win.Position.X.Offset, PY = win.Position.Y.Offset }))
                end
            end)
        end
        local function endResize()
            if not resizing then return end
            resizing = false; save()
        end
        grip.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then endResize() end
        end)
        track(game:GetService("UserInputService").InputChanged:Connect(function(inp)
            if not resizing or not gui or not gui.Parent then return end
            if inp.UserInputType == Enum.UserInputType.MouseMovement
               or inp.UserInputType == Enum.UserInputType.Touch then
                local d = inp.Position - resizeStart
                win.Size = UDim2.fromOffset(
                    math.clamp(sizeStart.X + d.X, 280, 900),
                    math.clamp(sizeStart.Y + d.Y, 240, 900))
            end
        end))
        track(game:GetService("UserInputService").InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
               or inp.UserInputType == Enum.UserInputType.Touch then endResize() end
        end))

        -- ================= MINIMIZE (implementasi) =================
        -- ★ FIX: sembunyikan SEMUA elemen konten saat minimize, tampilkan lagi
        --   saat restore. Simpan tinggi asli supaya restore-nya pas.
        local fullH = sh
        setMinimized = function(on)
            if on then
                fullH = math.max(win.AbsoluteSize.Y, 240)
                win.Size = UDim2.fromOffset(math.max(win.AbsoluteSize.X, 340), 54)
            else
                win.Size = UDim2.fromOffset(math.max(win.AbsoluteSize.X, 340), fullH)
            end
            -- sembunyikan/tampilkan semua isi di bawah header
            for _, el in ipairs({ tabBar, refreshBtn, scroll, footer, grip }) do
                if el then el.Visible = not on end
            end
            if minBtn then minBtn.Text = on and "+" or "—" end
            winMinimized = on
            if on then
                -- pastikan drag tidak nyangkut saat window mengecil
                dragging = false
            end
            pcall(function()
                if writefile then
                    writefile("Ascend_Predictor.json", game:GetService("HttpService"):JSONEncode({
                        W = math.floor(win.AbsoluteSize.X), H = fullH,
                        PX = win.Position.X.Offset, PY = win.Position.Y.Offset }))
                end
            end)
        end

        restoreFn = setMinimized

        OVERLAY.SetTab(activeTab)
    end

    P.Overlay = OVERLAY

    P.Refresh = function()
        if type(HUB.PredUI) ~= "table" then return end
        if HUB.PredUI.Rift then pcall(function() HUB.PredUI.Rift:Set(P.RiftText()) end) end
        if HUB.PredUI.Egg  then pcall(function() HUB.PredUI.Egg:Set(P.EggText()) end) end
        if HUB.PredUI.Fuse then pcall(function() HUB.PredUI.Fuse:Set(P.FuseText()) end) end
    end

    return P
end)()
local function buildLogicTP()
local Settings = {
    Enabled = false,
    Delay = 15, -- 3-20 detik menunggu di atas telur target
    Speed = 60, -- 20-100, untuk reposition/recovery dan perangkat FPS rendah
    Names = {},
    Rarities = {},
    Areas = {},
    Mutations = {},
    MinValue = 0,
    MinWeight = 0,
    SkipBait = false, -- false = pakai bait guard Forest (default, seperti versi sebelumnya)
}

if not game:IsLoaded() then game.Loaded:Wait() end
local env = getgenv and getgenv() or _G
if type(env.LogicTP) == "table" and type(env.LogicTP.Destroy) == "function" then
    env.LogicTP.Destroy()
end



local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
assert(LocalPlayer, "[LogicTP] Jalankan dari client")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local runtimeEnv = {}
local Config = { StealHoldSeconds = Settings.Delay }
local alive = true
local function sessionAlive() return alive end
local function resolveObjectsRoot()
    return Workspace:FindFirstChild("World") or Workspace:FindFirstChild("__OBJECTS")
end
local fps = 60
local fpsConnection = RunService.Heartbeat:Connect(function(dt)
    if dt > 0 then fps = fps * 0.9 + (1 / dt) * 0.1 end
end)
local function currentFps() return fps end

local catalog = (function()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local function safeReq(path)
		local node = ReplicatedStorage
		for _, part in ipairs(path) do node = node and node:FindFirstChild(part) end
		if not node then return nil end
		local ok, mod = pcall(require, node)
		return ok and mod or nil
	end
	local Assets = safeReq({"Data", "Assets"})
	local Mutations = safeReq({"Shared", "Modules", "Mutations"})
	if not Assets then error("[!Gp4q Hub] Data.Assets wajib ada") end
	local Catalog = {}
	local RARITY_ORDER = {
		Common = 1, Uncommon = 2, Rare = 3, Epic = 4, Legendary = 5,
		Mythic = 6, Cosmic = 7, Secret = 8, Eternal = 9, Divine = 10,
	}
	function Catalog.resolveMutationId(value)
		if type(value) ~= "string" then return nil end
		if Mutations.IdSet[value] then return value end
		for id in pairs(Mutations.Ids()) do
			if id ~= Mutations.NO_MUTATION and Mutations.LabelOf(id) == value then
				return id
			end
		end
		return nil
	end
	function Catalog.resolve(record)
		local config = record and Assets.Directory[record.AssetCategory]
		local rarity = config and config.Rarity
		local rarityName = rarity and (rarity.DisplayName or rarity._id) or "Unknown"
		return {
			name = config and (config.DisplayName or config._id) or (record and record.AssetCategory) or "Unknown",
			category = record and record.AssetCategory or "Unknown",
			rarity = rarityName,
			rarityRank = RARITY_ORDER[rarityName] or 0,
			rarityColor = rarity and rarity.Color or nil,
		}
	end
	return Catalog
	end)()
local EggRuntime = (function()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local RunService = game:GetService("RunService")
	local LocalPlayer = Players.LocalPlayer
	-- FIX: require dibungkus pcall -> satu module hilang tidak mematikan seluruh engine
	local function safeRequire(path, label)
		local node = ReplicatedStorage
		for _, part in ipairs(path) do
			node = node and node:FindFirstChild(part)
		end
		if not node then
			warn("[!Gp4q Hub] module tidak ada: " .. tostring(label))
			return nil
		end
		local ok, mod = pcall(require, node)
		if not ok then
			warn("[!Gp4q Hub] require gagal (" .. tostring(label) .. "): " .. tostring(mod))
			return nil
		end
		return mod
	end

	local EggCmds = safeRequire({"Client", "EggState"}, "Client.EggState")
	local Remotes = safeRequire({"Shared", "Remotes"}, "Shared.Remotes")
	local EggWorld = Remotes and Remotes.EggWorld or nil
	local AreaEggs = safeRequire({"Shared", "Types", "AreaEggs"}, "Shared.Types.AreaEggs")
	local AreaEggSlotIdentity = safeRequire({"Shared", "Util", "AreaEggSlotIdentity"}, "AreaEggSlotIdentity")
	local AreaEggResetWall = safeRequire({"Client", "AreaEggResetWall"}, "AreaEggResetWall")
	local AssetEarnings = safeRequire({"Shared", "Util", "AssetEarnings"}, "AssetEarnings")
	local PlotState = safeRequire({"Client", "PlotState"}, "PlotState")
	if not EggCmds then
		error("[!Gp4q Hub] EggState wajib ada, engine tidak bisa jalan")
	end
	local MOVEMENT_SPEED_MULTIPLIER = 10
	local MIN_MOVEMENT_SPEED_INPUT = 20
	local MAX_MOVEMENT_SPEED_INPUT = 1000  -- max 1000 (x10 = 10000 stud/s)
	local DEFAULT_MOVEMENT_SPEED_INPUT = 120   -- default lebih ngebut
	local NEXT_TARGET_HANDOFF_SECONDS = 0.03
	local MIN_MOVEMENT_SPEED = MIN_MOVEMENT_SPEED_INPUT * MOVEMENT_SPEED_MULTIPLIER
	local MAX_MOVEMENT_SPEED = MAX_MOVEMENT_SPEED_INPUT * MOVEMENT_SPEED_MULTIPLIER
	local DEFAULT_MOVEMENT_SPEED = DEFAULT_MOVEMENT_SPEED_INPUT * MOVEMENT_SPEED_MULTIPLIER

	local function maxMoveSpeed()
		return MAX_MOVEMENT_SPEED
	end
	local MOVEMENT_SPOOF_KEY = "__LimboStealAnEggMovementSpoof"
	local MOVEMENT_SPOOF_VERSION = 436
	local INTEGRITY_SPOOF_KEY = "__LimboStealAnEggIntegritySpoof"
	local INTEGRITY_SIGNAL_NAME = "ClientCharacter: GetDebugSnapshot"
	local INTEGRITY_SAMPLE_FIELDS = {
		"LastObservedSample",
		"LastSample",
		"LastGoodSample",
		"LastGameplayTrustedSample",
		"LastValidatedSample",
		"LastValidatedGroundedSample",
		"LastConfirmedGroundSample",
		"CandidateGroundedSample",
	}
	local EGG_ARRIVAL_CLEARANCE = 0.15
	local HOVER_PAD_SIZE_XZ = 8
	local HOVER_PAD_THICKNESS = 1
	local HOVER_PAD_NAME = "__LogicTPHoverPad"
	local HOVER_PAD_OWNER_ATTRIBUTE = "LimboRuntimeOwner"
	local SAFE_ZONE_CFRAME = CFrame.new(
		544.40094, 70.5743103, -364.193054,
		0.0320008546, -1.19248071e-07, -0.999487817,
		-1.76635826e-08, 1, -1.19874713e-07,
		0.999487817, 2.14906297e-08, 0.0320008546
	)
	local SAFE_ZONE_POSITION = SAFE_ZONE_CFRAME.Position

	local FOREST_TRANSFER_ATTEMPTS = 5
	local FOREST_DROP_SETTLE = 0.6  -- wait after a drop request for the server to release

	local SETTLE_CAP_DEFAULT = 13   -- unknown area -> safest (schedule max)
	local SETTLE_BY_AREA = {
    ["Forest"] = 1.0,   ["Lake"] = 1.0,          ["Desert"] = 1.0,        ["Jungle"] = 1.0,
    ["Snow"] = 1.0,     ["Volcano"] = 1.0,        ["Abyss Ocean"] = 1.0,   ["Prehistoric"] = 1.0,
    ["Cosmic"] = 1.0,   ["Cherry Blossom"] = 1.0, ["Titan Temple"] = 1.0, ["Light Dark"] = 1.0,
    }

	local GLIDE_SPEED = 5000
	local FOREST_DROP_RELAY = CFrame.new(
		782.6416, 70.5762, -297.0993,
		0.35004562139511, 7.3665610500484e-08, 0.93673264980316,
		-8.2453034622176e-08, 1, -4.7829320948267e-08,
		-0.93673264980316, -6.0494002696032e-08, 0.35004562139511
	)

	local HOVER_DESYNC_HEIGHT = 3

	local SAFE_ZONE_HORIZONTAL_RADIUS = 30
	local SAFE_ZONE_VERTICAL_TOLERANCE = 18
	local SAFE_TELEPORT_STABLE_SECONDS = 0.15
	local SAFE_TELEPORT_TIMEOUT_SECONDS = 2
	local SAFE_TELEPORT_RETRY_SECONDS = 0.1
	local TREADMILL_DECOY_NAME = "__LogicTPDecoy"
	local TREADMILL_DECOY_REMOVE_CLASSES = {
		Script = true,
		LocalScript = true,
		BillboardGui = true,
		Sound = true,
	}
	local CARRY_RETRY_INTERVAL = 0.02
	local CARRY_CONFIRM_TIMEOUT_SECONDS = 5
	local CARRY_REAPPROACH_DISTANCE = 4
	local CARRY_STATE_GRACE = 0.01
	local TARGET_GONE_HANDOFF_GRACE = 0.65
	local INTEGRITY_SPEED_HEADROOM = 1.6
	local LONG_FRAME_CLAMP = 0.15
	local MOVEMENT_BASELINE_PADDING = 24
	local CORRECTION_DISTANCE_EPSILON = 2
	local CORRECTION_SLOWDOWN_SECONDS = 0.5
	local CORRECTION_SPEED_FACTOR = 0.45
	local MOVEMENT_ARRIVAL_HOLD = 0.15
	local PLAYER_TRAP_NAME = "PlayerTrap"
	local LEGACY_TRAP_MODEL_NAME = "Trap"
	local EggRuntime = {}
	EggRuntime.__index = EggRuntime
	local _Stats = game:GetService("Stats")
	-- ============================================================
	-- [Gp4q PATCH] CARRY DIAGNOSTIC
	-- Dulu (result, reason) dari AskFieldEggCarry dibuang total, jadi
	-- "stuck di carry" tidak bisa dibedakan: terlalu jauh / slot key
	-- invalid / egg sudah diambil orang. Sekarang disimpan & dihitung.
	-- ============================================================
	local CARRY_DIAG = { reason = nil, at = 0, uid = nil, ok = 0, fail = 0, lastSlotKey = nil }
	local function requestFieldEggCarry(uid, slotKey)
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if root then
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				end)
		end
		local ping = 0
		pcall(function() ping = _Stats.Network.ServerStats.Ping:GetValue() end)
		task.wait(0.05)
		-- FIX KRITIS: server menolak {Uid} saja dengan "Get closer to the egg".
		-- FirstAreaSlotKey harus SELALU ada; untuk telur non-Forest nilainya = Uid.
		-- (dulu: kalau slotKey nil -> field tidak dikirim -> carry selalu timeout)
		local payload = { Uid = uid, FirstAreaSlotKey = slotKey or tostring(uid) }
		local result, reason = EggWorld.AskFieldEggCarry:InvokeServer(payload)
		-- kalau bentuk ini ditolak, coba sekali lagi dengan uid sebagai slotKey
		if result ~= true and slotKey ~= nil and slotKey ~= tostring(uid) then
			local r2, reason2 = EggWorld.AskFieldEggCarry:InvokeServer({ Uid = uid, FirstAreaSlotKey = tostring(uid) })
			if r2 == true then
				CARRY_DIAG.ok += 1
				CARRY_DIAG.reason, CARRY_DIAG.at, CARRY_DIAG.uid = nil, os.clock(), uid
				CARRY_DIAG.lastSlotKey = tostring(uid)
				return true, nil
			end
			reason = reason2 or reason
		end
		-- [Gp4q PATCH] rekam alasan penolakan server
		if result == true then
			CARRY_DIAG.ok += 1
			CARRY_DIAG.reason, CARRY_DIAG.at, CARRY_DIAG.uid = nil, os.clock(), uid
		else
			CARRY_DIAG.fail += 1
			CARRY_DIAG.reason = (typeof(reason) == "string" and reason ~= "" and reason) or "no reason returned"
			CARRY_DIAG.at, CARRY_DIAG.uid = os.clock(), uid
			CARRY_DIAG.lastSlotKey = payload.FirstAreaSlotKey
		end
		return result == true, typeof(reason) == "string" and reason or nil
	end
	local function connect(signal, callback, connections)
		local connection = signal:Connect(callback)
		table.insert(connections, connection)
		return connection
	end
	local function disconnectAll(connections)
		for _, connection in ipairs(connections) do
			pcall(connection.Disconnect, connection)
		end
		table.clear(connections)
	end
	local function listContains(list, value)
		for _, candidate in ipairs(list or {}) do
			if candidate == value then
				return true
			end
		end
		return false
	end
	local resolveEggRate
	local function applyKillPartIgnore(character)
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
			root:SetAttribute("KillPartIgnore", true)
		end
	end
	local function stopHealthPinner(self)
		if self._healthPinner then
			pcall(self._healthPinner.Disconnect, self._healthPinner)
			self._healthPinner = nil
		end
		if self._healthChangedConnection then
			pcall(self._healthChangedConnection.Disconnect, self._healthChangedConnection)
			self._healthChangedConnection = nil
		end
	end
	local function startHealthPinner(self, char)
		stopHealthPinner(self)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not hum then return false end
		local maxHp = math.max(hum.MaxHealth, 100)
		local repairing = false
		local lastRepairAt = 0
		local function repair()
			if repairing or self.destroyed or LocalPlayer.Character ~= char or not hum.Parent then return end
			local now = os.clock()
			if now - lastRepairAt < 0.1 and hum.Health > 0 and hum:GetState() ~= Enum.HumanoidStateType.Dead then
				return
			end
			lastRepairAt = now
			repairing = true
			pcall(function()
				hum.BreakJointsOnDeath = false
				hum.RequiresNeck = false
				hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
				hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
				hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
				if hum.Health <= 0 then hum.Health = maxHp end
				if hum:GetState() == Enum.HumanoidStateType.Dead then
					hum:ChangeState(Enum.HumanoidStateType.Running)
				end
				if root and root.Parent == char and root.Anchored then
					root.Anchored = false
				end
				end)
			repairing = false
		end
		repair()
		self._healthChangedConnection = hum.HealthChanged:Connect(function(health)
			if health <= 0 or health < maxHp then repair() end
			end)
		self._healthPinner = RunService.Heartbeat:Connect(repair)
		return true
	end
	local function restoreHumanoid(character)
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end
		pcall(function()
			if humanoid.Health <= 0 then
				humanoid.Health = math.max(humanoid.MaxHealth, 1)
			end
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
			humanoid.BreakJointsOnDeath = true
			humanoid.RequiresNeck = true
			end)
	end
	local function environment()
		return runtimeEnv
	end
	local function getMovementSpoof()
		local env = environment()
		local existing = env[MOVEMENT_SPOOF_KEY]
		if type(existing) ~= "table" or existing.Version ~= MOVEMENT_SPOOF_VERSION then
			if type(existing) == "table" then existing.Enabled = false end
			existing = {
				Version = MOVEMENT_SPOOF_VERSION,
				Installed = false,
				Enabled = false,
				Mode = "StateBaseline",
				Humanoid = nil,
				RootPart = nil,
				WalkSpeed = DEFAULT_MOVEMENT_SPEED,
			}
			env[MOVEMENT_SPOOF_KEY] = existing
		end
		return existing
	end
	local function setMovementSpoof(character, speed)
		local holder = getMovementSpoof()
		if not holder then
			return false
		end
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		holder.Humanoid = humanoid
		holder.RootPart = root
		holder.WalkSpeed = math.clamp(
			tonumber(speed) or DEFAULT_MOVEMENT_SPEED,
			MIN_MOVEMENT_SPEED,
			MAX_MOVEMENT_SPEED * INTEGRITY_SPEED_HEADROOM
		)
		holder.Enabled = false
		return humanoid ~= nil and root ~= nil
	end
	local function clearMovementSpoof()
		local holder = environment()[MOVEMENT_SPOOF_KEY]
		if type(holder) == "table" then
			holder.Enabled = false
			holder.Humanoid = nil
			holder.RootPart = nil
		end
	end
	-- Match bertingkat: ketat (RootPart/Character cocok) -> longgar (Player+Evidence)
local function integrityLooksRight(value, player, humanoid, root)
	if type(value) ~= "table" then return false end
	if rawget(value, "Player") ~= player then return false end
	if type(rawget(value, "Evidence")) ~= "table" then return false end
	-- ketat: semua referensi karakter cocok
	if rawget(value, "Character") == player.Character
		and rawget(value, "Humanoid") == humanoid
		and rawget(value, "RootPart") == root
		and type(rawget(value, "SampleHistory")) == "table"
	then
		return true
	end
	-- longgar: Player + Evidence + (SampleHistory atau ThreatLevel)
	if type(rawget(value, "SampleHistory")) == "table" then return true end
	if rawget(value, "ThreatLevel") ~= nil then return true end
	return false
end

local function findIntegrityStateNow(player, humanoid, root)
		local found
		if type(getcallbackvalue) == "function" and type(debug) == "table" and type(debug.getupvalue) == "function" then
			local signalModule = ReplicatedStorage:FindFirstChild("Packages")
			and ReplicatedStorage.Packages:FindFirstChild("Signal")
			if signalModule then
				local okSig, Signal = pcall(require, signalModule)
				if okSig and type(Signal) == "table" and type(Signal.Invoked) == "function" then
					local okBind, bindable = pcall(Signal.Invoked, INTEGRITY_SIGNAL_NAME)
					if okBind and bindable then
						local okCb, callback = pcall(getcallbackvalue, bindable, "OnInvoke")
						if okCb and type(callback) == "function" then
							local okInfo, info = pcall(debug.getinfo, callback)
							if okInfo then
								local function scan(value, depth, seen)
									if found or type(value) ~= "table" or depth > 3 or seen[value] then return end
									seen[value] = true
									if integrityLooksRight(value, player, humanoid, root) then
										found = value
										return
									end
									local scanned = 0
									for _, child in pairs(value) do
										scanned = scanned + 1
										if scanned > 128 then break end
										if type(child) == "table" then scan(child, depth + 1, seen) end
									end
								end
								for idx = 1, info.nups or 0 do
									local okUp, upvalue = pcall(debug.getupvalue, callback, idx)
									if okUp and type(upvalue) == "table" then
										scan(upvalue, 0, {})
										if found then break end
									end
								end
							end
						end
					end
				end
			end
		end
		if not found and type(getgc) == "function" then
			local okGc, objects = pcall(getgc, true)
			if okGc and type(objects) == "table" then
				-- pass 1: kriteria longgar (Player + Evidence)
				for _, obj in ipairs(objects) do
					if type(obj) == "table" and integrityLooksRight(obj, player, humanoid, root) then
						found = obj
						break
					end
				end
				-- pass 2 (paling longgar): Player + Evidence saja
				if not found then
					for _, obj in ipairs(objects) do
						if type(obj) == "table"
						and rawget(obj, "Player") == player
						and type(rawget(obj, "Evidence")) == "table"
						then
							found = obj
							break
						end
					end
				end
			end
		end
		return found
	end
	local integrityScanRuntime = { busy = false, nextAt = 0, misses = 0, found = nil }
	local function findIntegrityState(player, humanoid, root)
		local cached = integrityScanRuntime.found
		if type(cached) == "table"
		and rawget(cached, "Player") == player
		and rawget(cached, "Character") == player.Character
		and rawget(cached, "Humanoid") == humanoid
		and rawget(cached, "RootPart") == root
		then
			return cached
		end
		if integrityScanRuntime.busy or os.clock() < integrityScanRuntime.nextAt then
			return nil
		end
		integrityScanRuntime.busy = true
		task.spawn(function()
			task.wait()
			local ok, found = pcall(findIntegrityStateNow, player, humanoid, root)
			found = ok and found or nil
			integrityScanRuntime.found = found
			integrityScanRuntime.misses = found and 0 or integrityScanRuntime.misses + 1
			integrityScanRuntime.nextAt = os.clock() + (found and 0.2 or (integrityScanRuntime.misses >= 5 and 10 or 1))
			integrityScanRuntime.busy = false
			end)
		return nil
	end
	local function patchIntegrityState(state, speed, travelVelocity)
		if type(state) ~= "table" then
			return false
		end
		local root = rawget(state, "RootPart")
		local rootCFrame = root and root.Parent and root.CFrame or nil
		local rootPosition = rootCFrame and rootCFrame.Position or nil
		local coherentVelocity = typeof(travelVelocity) == "Vector3" and travelVelocity or Vector3.zero
		local function patchSample(sample)
			if type(sample) == "table" then
				rawset(sample, "WalkSpeed", speed)
				if rootCFrame then
					rawset(sample, "CFrame", rootCFrame)
					rawset(sample, "Position", rootPosition)
					rawset(sample, "LinearVelocity", coherentVelocity)
					rawset(sample, "AngularVelocity", Vector3.zero)
				end
			end
		end
		for _, field in ipairs(INTEGRITY_SAMPLE_FIELDS) do
			patchSample(rawget(state, field))
		end
		for _, sample in pairs(rawget(state, "SampleHistory") or {}) do
			patchSample(sample)
		end
		for _, sample in pairs(rawget(state, "SafeGroundCheckpoints") or {}) do
			patchSample(sample)
		end
		local evidence = rawget(state, "Evidence")
		if type(evidence) == "table" then
			evidence.Speed = 0
			evidence.Teleport = 0
			evidence.Flight = 0
		end
		local impulse = rawget(state, "ImpulseContext")
		if type(impulse) == "table" then
			local horizontalSpeed = math.max(tonumber(impulse.MaxHorizontalSpeed) or 0, speed)
			local duration = math.max(
				(tonumber(impulse.ExpiresAt) or 0) - (tonumber(impulse.StartedAt) or 0),
				LONG_FRAME_CLAMP
			)
			impulse.MaxHorizontalSpeed = horizontalSpeed
			if rootPosition then impulse.OriginPosition = rootPosition end
			impulse.MaxHorizontalDistance = math.max(
				tonumber(impulse.MaxHorizontalDistance) or 0,
				horizontalSpeed * duration + MOVEMENT_BASELINE_PADDING * 2
			)
			patchSample(impulse.PreMovementSafeSample)
		end
		if rawget(state, "CorrectionContext") == nil then
			rawset(state, "FirstSuspiciousAt", nil)
			if rawget(state, "ThreatLevel") == "Observing" then
				rawset(state, "ThreatLevel", "Trusted")
			end
		end
		return true
	end
	local function getIntegritySpoof()
		local env = environment()
		local holder = env[INTEGRITY_SPOOF_KEY]
		if type(holder) ~= "table" then
			holder = {}
			env[INTEGRITY_SPOOF_KEY] = holder
		end
		return holder
	end
	local function integrityStateMatches(state, humanoid, root)
		return type(state) == "table"
		and rawget(state, "Player") == LocalPlayer
		and rawget(state, "Character") == LocalPlayer.Character
		and rawget(state, "Humanoid") == humanoid
		and rawget(state, "RootPart") == root
	end
	local function integrityStateCanTravel(state, humanoid, root)
		return integrityStateMatches(state, humanoid, root)
	end
	local function setIntegritySpoof(humanoid, root, speed)
		local holder = getIntegritySpoof()
		local state = holder.State
		if not integrityStateMatches(state, humanoid, root) then
			local now = os.clock()
			if now < (holder.NextSearchAt or 0) then return false end
			holder.NextSearchAt = now + 0.2
			state = findIntegrityState(LocalPlayer, humanoid, root)
		end
		if not state then
			return false
		end
		if not integrityStateCanTravel(state, humanoid, root) then
			holder.Enabled = false
			holder.Humanoid = humanoid
			holder.RootPart = root
			holder.State = state
			return false
		end
		holder.NextSearchAt = 0
		holder.Enabled = true
		holder.Humanoid = humanoid
		holder.RootPart = root
		holder.State = state
		holder.WalkSpeed = math.clamp(speed * INTEGRITY_SPEED_HEADROOM, MIN_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED * INTEGRITY_SPEED_HEADROOM)
		holder.TravelVelocity = Vector3.zero
		patchIntegrityState(state, holder.WalkSpeed, holder.TravelVelocity)
		return true
	end
	local function refreshIntegritySpoof(humanoid, root, speed, travelVelocity)
		local holder = environment()[INTEGRITY_SPOOF_KEY]
		if type(holder) ~= "table"
		or not holder.Enabled
		or holder.Humanoid ~= humanoid
		or holder.RootPart ~= root
		or not integrityStateCanTravel(holder.State, humanoid, root)
		then
			return false
		end
		holder.WalkSpeed = math.clamp(speed * INTEGRITY_SPEED_HEADROOM, MIN_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED * INTEGRITY_SPEED_HEADROOM)
		if typeof(travelVelocity) == "Vector3" then
			holder.TravelVelocity = travelVelocity
		elseif typeof(holder.TravelVelocity) ~= "Vector3" then
			holder.TravelVelocity = Vector3.zero
		end
		return patchIntegrityState(holder.State, holder.WalkSpeed, holder.TravelVelocity)
	end
	local function clearIntegritySpoof(humanoid)
		local holder = environment()[INTEGRITY_SPOOF_KEY]
		if type(holder) ~= "table" then
			return
		end
		if humanoid == nil or holder.Humanoid == humanoid then
			holder.Enabled = false
			holder.Humanoid = nil
			holder.RootPart = nil
			holder.State = nil
			holder.TravelVelocity = nil
			holder.NextSearchAt = 0
		end
	end
	local function hasSelectedMutation(record, selected)
		if #selected == 0 then
			return true
		end
		for _, mutation in ipairs(record.Mutations or {}) do
			if listContains(selected, mutation) then
				return true
			end
		end
		return record.BaseMutation ~= nil and listContains(selected, record.BaseMutation)
	end
	function EggRuntime.new(catalog)
		local self = setmetatable({}, EggRuntime)
		self.catalog = catalog
		self.connections = {}
		self.listeners = {}
		self.records = {}
		self.enabled = false
		self.userStealEnabled = false

		self.skippedEggs = {}

		self.running = false
		self.safeStarting = false
		self.movementRetryPending = false
		self.destroyed = false
		self.resetBlocked = AreaEggResetWall.IsSealed()
		self.gateOpenAt = self.resetBlocked and math.huge or os.clock()
		self.activeTween = nil
		self.activeTarget = nil

		self.carry = { active = false, uid = nil, generation = 0 }
		self.carryWorker = nil
		self.tweenRecoveryUid = nil
		self.planGeneration = 0
		self.treadmillDecoy = nil
		self.treadmillDecoyCamera = nil
		self.treadmillDecoyCameraConnection = nil
		self.treadmillDecoyCharacterConnection = nil
		self.treadmillPopupConnection = nil
		self.treadmillDecoyRealTransparency = nil
		self.hoverPadOwnerId = string.format("%s:%0.6f", tostring(self), os.clock())
		self.instantPhase = nil
		self.primerUid = nil
		self.targetUid = nil
		self.hitTimer = nil
		self.guardHitBoostInstalled = false
		self.stats = {
			status = self.resetBlocked and "Reset wall closed" or "Ready",
			available = 0,
			matching = 0,
			lastTarget = "None",
			lastResult = "Idle",
		}
		self.config = {
			speed = DEFAULT_MOVEMENT_SPEED,
			antiTrap = true,
			minWeightKg = 0,

			minValuePerSec = 0,
			rarityEnabled = false,
			rarities = {},
			nameEnabled = false,
			names = {},
			areaEnabled = false,
			areas = {},
			mutationEnabled = false,
			mutations = {},
		}

		if LocalPlayer.Character then
			applyKillPartIgnore(LocalPlayer.Character)
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				pcall(function()
					hum.BreakJointsOnDeath = false
					hum.RequiresNeck = false
					hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					end)
			end
			startHealthPinner(self, LocalPlayer.Character)
		end
		local okWeight, weightUtil = pcall(function()
			local node = ReplicatedStorage.Shared.Util.EggRecords
	if not node then return nil end
	local ok, mod = pcall(require, node)
	return ok and mod or nil
			end)
		self.weightUtil = okWeight and type(weightUtil.WeightKgForScale) == "function" and weightUtil or nil
		local function watchTrapContainer(container)
			if not container then
				return
			end
			connect(container.DescendantAdded, function(instance)
				if self.config.antiTrap then
					self:_purgeTrap(instance)
				end
				end, self.connections)
		end
		watchTrapContainer(workspace:FindFirstChild("Transient"))
		watchTrapContainer(workspace:FindFirstChild("__DEBRIS"))
		if self.config.antiTrap then self:_purgeTraps() end
		connect(workspace.ChildAdded, function(child)
			if child.Name == "Transient" or child.Name == "__DEBRIS" then
				watchTrapContainer(child)
				if self.config.antiTrap then
					self:_purgeTraps()
				end
			end
			end, self.connections)
		self:_replaceSnapshot(EggCmds.ReadFieldEggs())
		connect(EggCmds.FieldRefreshed, function(snapshot)
			self:_replaceSnapshot(snapshot)
			end, self.connections)
		connect(EggCmds.FieldShifted, function(record)
			self.records[record.Uid] = record
			self:_refreshCounts()
			end, self.connections)
		connect(EggCmds.FieldGone, function(uid)
			self.records[uid] = nil
			if self.activeTarget and self.activeTarget.Uid == uid then
				if self.carry.active and self.carry.uid == uid then
					self:_refreshCounts()
					return
				end
				self.carryAttemptToken = nil
				self:_clearArrivalHold(uid)
				if self.activeTween and self.activeTween.Cancel then
					pcall(self.activeTween.Cancel, self.activeTween)
				end
				local target = self.activeTarget
				task.delay(TARGET_GONE_HANDOFF_GRACE, function()
					if self.destroyed or not self.enabled then return end
					if self.carry.active and self.carry.uid == uid then return end
					if self.activeTarget == target and target.Uid == uid then
						self:_finish("Target removed — continuing")
					end
					end)
			end
			self:_refreshCounts()
			end, self.connections)
		connect(EggCmds.ResetCountdown, function()
			self:_closeGate("Egg reset countdown")
			end, self.connections)
		connect(EggCmds.ResetFade, function()
			self:_closeGate("Egg reset teleport")
			end, self.connections)
		connect(AreaEggResetWall.Changed, function(closed)
			if closed then
				self:_closeGate("Reset wall closed")
			else
				self.resetBlocked = false
				self.gateOpenAt = os.clock()
				self.safeStarting = false
				self.running = false
				self:_setStatus(self.enabled and "Searching" or "Ready")
				self:_schedule()
			end
			end, self.connections)
		connect(LocalPlayer.CharacterRemoving, function()
			self:_cleanupInstantSteal()
			self:_hideTreadmillDecoy()
			self._forestDropInProgress = nil
			self._instantReturnToken = nil
			self.carry.generation += 1
			self:_invalidateCarryWorker()
			self.carry.active = false
			self.carry.uid = nil
			self.safeStarting = false
			self.planGeneration += 1
			self:_cancelTween("Character resetting")
			self:_stopMovementProtection()
			end, self.connections)
		connect(RunService.Heartbeat, function()
			if self.destroyed then return end
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local velocity = root.AssemblyLinearVelocity
			if Vector3.new(velocity.X, 0, velocity.Z).Magnitude > 400
			or math.abs(velocity.Y) > 400
			then
				root.AssemblyLinearVelocity = Vector3.new(
					math.clamp(velocity.X, -100, 100),
					math.clamp(velocity.Y, -100, 100),
					math.clamp(velocity.Z, -100, 100)
				)
			end
			end, self.connections)
		connect(LocalPlayer.CharacterAdded, function(character)
			self:_hideTreadmillDecoy()
			applyKillPartIgnore(character)
			local freshHum = character:FindFirstChildOfClass("Humanoid")
			if freshHum then
				pcall(function()
					freshHum.BreakJointsOnDeath = false
					freshHum.RequiresNeck = false
					freshHum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
					freshHum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
					freshHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
					end)
			end
			startHealthPinner(self, character)
			task.delay(0.25, function()
				if not self.destroyed and self.enabled then
					self:_startMovementProtection()
				end
				end)
			task.delay(1, function()
				if not self.destroyed and self.enabled and self:_wallOpen() then
					self:_schedule()
				end
				end)
			end, self.connections)
		connect(EggCmds.CarryChanged, function(state)
			if state.IsCarrying then
				if self.running and self.activeTarget and state.Uid == self.activeTarget.Uid then
					if self.carry.active and self.carry.uid == state.Uid then return end
					if self.instantPhase == "priming" and state.Uid == self.primerUid then
						self.carry.active = true
						self.carry.uid = state.Uid
						self:_clearArrivalHold(state.Uid)
						self:_enterBaitWait()
						return
					end
					self.carry.generation += 1
					self:_invalidateCarryWorker()
					self:_clearArrivalHold(state.Uid)

					self.carry.active = true
					self.carry.uid = state.Uid
					self.carryStartTime = os.clock()
					self.carryStartPos = (self.activeTarget and self.activeTarget.BottomCFrame and self.activeTarget.BottomCFrame.Position)
					or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position)
					if self.tweenRecoveryUid == state.Uid then
						self.tweenRecoveryUid = nil
					end
					self.stats.lastResult = "Carry confirmed"
					self:_notify()
					self.carryAttemptToken = nil
					if self.activeTween and self.activeTween.Cancel then
						pcall(self.activeTween.Cancel, self.activeTween)
					end
					task.defer(function()
						if not self.destroyed and self.enabled
						and self.carry.uid == state.Uid
						and self:_hasConfirmedCarry(state.Uid)
						then
							self:_returnToSafe()
						end
						end)
				end
				return
			end
			if self.carry.uid ~= nil and state.Uid ~= nil and state.Uid ~= self.carry.uid then
				return
			end
			local droppedUid = state.Uid
			or self.carry.uid
			or (self.activeTarget and self.activeTarget.Uid)
			local wasTracked = self.carry.active
			self.carry.generation += 1
			local releaseGeneration = self.carry.generation
			self:_invalidateCarryWorker()
			if self.activeTween and self.activeTween.Cancel then
				pcall(self.activeTween.Cancel, self.activeTween)
			end
			self.carry.active = false
			self.carry.uid = nil
			if self.instantPhase == "priming" and (state.Uid == self.primerUid or droppedUid == self.primerUid) then
				self:_startPrimerTargetHunt()
				return
			end

			if self._forestDropInProgress ~= nil and droppedUid == self._forestDropInProgress then
				return
			end

			if not wasTracked then
				return
			end
			if not self.running or not self.activeTarget then
				return
			end
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root and self:_isInSafeArea(root) then
				self:_reportStolen()
				self:_finish("Safe return complete")
				return
			end
			task.delay(CARRY_STATE_GRACE, function()
				if self.destroyed or not self.enabled or self.carry.active
				or self.carry.generation ~= releaseGeneration
				then
					return
				end
				local latestRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if latestRoot and self:_isInSafeArea(latestRoot) then
					self:_reportStolen()
					self:_finish("Safe return complete")
					return
				end
				self:_reStealDroppedEgg(droppedUid)
				end)
			end, self.connections)
		connect(LocalPlayer:GetAttributeChangedSignal("RagdollEndTime"), function()
			local tEnd = LocalPlayer:GetAttribute("RagdollEndTime") or 0
			if self.instantPhase == "priming" and tEnd > workspace:GetServerTimeNow() then
				self:_startPrimerTargetHunt()
			end
			end, self.connections)
		local startupStatus = self.stats.status
		self.stats.status = startupStatus
		return self
	end
	function EggRuntime:_setStatus(status)
		if self.stats.status == status then
			return
		end
		self.stats.status = status
		self:_notify()
	end
	function EggRuntime:_notify()
		local snapshot = self:getSnapshot()
		for listener in pairs(self.listeners) do
			local ok, err = pcall(listener, snapshot)
			if not ok then
				warn("[StealAnEgg] Status listener thất bại:", err)
			end
		end
	end
	function EggRuntime:getSnapshot()
		return {
			status = self.stats.status,
			available = self.stats.available,
			matching = self.stats.matching,
			lastTarget = self.stats.lastTarget,
			lastResult = self.stats.lastResult,
			wallClosed = self.resetBlocked or AreaEggResetWall.IsSealed() or os.clock() < self.gateOpenAt,
			enabled = self.enabled,
			running = self.running,
			-- [Gp4q PATCH] diagnosa carry: alasan server + hitungan ok/fail
			carryReason = CARRY_DIAG.reason,
			carryOk = CARRY_DIAG.ok,
			carryFail = CARRY_DIAG.fail,
			carrySlotKey = CARRY_DIAG.lastSlotKey,
			carryReasonAge = CARRY_DIAG.at > 0 and (os.clock() - CARRY_DIAG.at) or nil,
		}
	end
	function EggRuntime:_replaceSnapshot(snapshot)
		table.clear(self.records)
		local records = snapshot and (snapshot.Records or snapshot) or {}
		for key, record in pairs(records) do
			if type(record) == "table" and type(record.Uid) == "string" then
				self.records[record.Uid] = record
			elseif type(key) == "string" and type(record) == "table" then
				self.records[key] = record
			end
		end
		self:_refreshCounts()
		self:_schedule()
	end
	function EggRuntime:_matchesNormalFilter(record)
		local info = self.catalog.resolve(record)
		local config = self.config
		if config.rarityEnabled and (#config.rarities == 0 or not listContains(config.rarities, info.rarity)) then
			return false
		end
		if config.nameEnabled and (#config.names == 0 or (not listContains(config.names, info.name) and not listContains(config.names, info.category))) then
			return false
		end
		if config.areaEnabled and (#config.areas == 0 or not listContains(config.areas, record.AreaId)) then
			return false
		end
		if config.mutationEnabled and not hasSelectedMutation(record, config.mutations) then
			return false
		end
		if (config.minWeightKg or 0) > 0 then
			local kg = self:_resolveWeightKg(record)
			if not kg or kg < config.minWeightKg then
				return false
			end
		end
		if (config.minValuePerSec or 0) > 0 then
			local rate = resolveEggRate(record)
			if not rate or rate < config.minValuePerSec then
				return false
			end
		end
		return true
	end
	function EggRuntime:_matches(record)
		return (record.State == AreaEggs.States.Slot or record.State == AreaEggs.States.Dropped)
			and self.userStealEnabled and self:_matchesNormalFilter(record)
	end
	function EggRuntime:_refreshCounts()
		local available = 0
		local matching = 0
		for _, record in pairs(self.records) do
			if record.State == AreaEggs.States.Slot then
				available += 1
				if self:_matches(record) then
					matching += 1
				end
			end
		end
		self.stats.available = available
		self.stats.matching = matching
		self:_notify()
	end
	function EggRuntime:isSkippedEgg(uid)

		if uid ~= nil and uid == workspace:GetAttribute("Event_CaptureTheEggUid") then return true end
		local untilAt = uid and self.skippedEggs[uid]
		if not untilAt then return false end
		if os.clock() < untilAt then return true end
		self.skippedEggs[uid] = nil
		return false
	end
	function EggRuntime:_chooseTarget()
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root then return nil end
		-- FIX (drop recovery): kalau sedang memulihkan telur yang jatuh (tweenRecoveryUid),
		-- utamakan telur ITU dulu — jangan sampai "ditukar" ke egg lain yang lebih
		-- dekat/lebih rare saat egg drop masih di lapangan.
		if self.tweenRecoveryUid then
			local rec = EggCmds.ReadFieldEgg(self.tweenRecoveryUid) or self.records[self.tweenRecoveryUid]
			if type(rec) == "table" and rec.BottomCFrame and self:_matches(rec) then
				return rec
			end
		end
		local best, bestRank, bestDistance
		for _, record in pairs(self.records) do
			if record.BottomCFrame and not self:isSkippedEgg(record.Uid) and self:_matches(record) then
				local rank = self.catalog.resolve(record).rarityRank or 0
				local distance = (record.BottomCFrame.Position - root.Position).Magnitude
				if not best or rank > bestRank or (rank == bestRank and distance < bestDistance) then
					best, bestRank, bestDistance = record, rank, distance
				end
			end
		end
		return best
	end
	-- FIX: simpan original di getgenv supaya TIDAK numpuk kalau script di-load 2x
	local _originalResolveHitDistance = (getgenv and getgenv()._GP4Q_OrigResolveHitDistance) or nil
	local GUARD_HIT_DISTANCE_BOOST = 25
	function EggRuntime:_installGuardHitDistanceBoost()
		if self.guardHitBoostInstalled then return end
		pcall(function()
			local gcpNode = ReplicatedStorage.Shared.Modules.GuardAreas.GuardChasePolicy
			local okGcp, GuardChasePolicy = pcall(require, gcpNode)
			GuardChasePolicy = okGcp and GuardChasePolicy or nil
			if GuardChasePolicy and type(GuardChasePolicy.ResolveHitDistance) == "function" then
				_originalResolveHitDistance = _originalResolveHitDistance or GuardChasePolicy.ResolveHitDistance
				pcall(function() getgenv()._GP4Q_OrigResolveHitDistance = _originalResolveHitDistance end)
				local runtime = self
				GuardChasePolicy.ResolveHitDistance = function(hitDist)
					if runtime.enabled and runtime.instantPhase == "priming" then
						return GUARD_HIT_DISTANCE_BOOST
					end
					if runtime.enabled then
						return -math.huge
					end
					local base = _originalResolveHitDistance and _originalResolveHitDistance(hitDist) or (hitDist or 10)
					return base
				end
				self.guardHitBoostInstalled = true
			end
			end)
	end
	function EggRuntime:_removeGuardHitDistanceBoost()
		if not self.guardHitBoostInstalled then return end
		pcall(function()
			local GuardChasePolicy = require(ReplicatedStorage.Shared.Modules.GuardAreas.GuardChasePolicy)
			if GuardChasePolicy and _originalResolveHitDistance then
				GuardChasePolicy.ResolveHitDistance = _originalResolveHitDistance
				self.guardHitBoostInstalled = false
			end
			pcall(function() getgenv()._GP4Q_OrigResolveHitDistance = nil end)
			end)
	end
	function EggRuntime:_setInstantAnchored(anchored)
		pcall(function()
			local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if root and root.Anchored ~= anchored then root.Anchored = anchored end
			end)
	end
	function EggRuntime:_kbCancelTimer()
		if self.hitTimer then
			pcall(task.cancel, self.hitTimer)
			self.hitTimer = nil
		end
	end
	function EggRuntime:_cleanupInstantSteal()
		self.instantPhase = nil
		self.primerUid = nil
		self.targetUid = nil
		self:_stopGuardStick()
		self:_stopGuardStrike()
		self:_kbCancelTimer()
		self:_setInstantAnchored(false)
		self:_hideTreadmillDecoy()
	end
	function EggRuntime:_choosePrimerEgg(excludeUid)
		local objects = resolveObjectsRoot()
		local areas = objects and objects:FindFirstChild("Areas")
		local guardAreas = areas and areas:FindFirstChild("GuardAreas")
		local forestArea = guardAreas and guardAreas:FindFirstChild("Forest")
		local forestGuard = forestArea and forestArea:FindFirstChild("Guard")
		local guardRoot = forestGuard and forestGuard:FindFirstChild("HumanoidRootPart")
		local guardPosition = guardRoot and guardRoot.Position
		local best, bestScore
		for _, rec in pairs(self.records) do
			if rec.State == AreaEggs.States.Slot and rec.AreaId == "Forest" and rec.Uid ~= excludeUid then
				local dist = guardPosition and (rec.BottomCFrame.Position - guardPosition).Magnitude
				or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					and (rec.BottomCFrame.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
				or math.huge)
				local rarityRank = self.catalog.resolve(rec).rarityRank or 0
				local score = -dist - (rarityRank * 100)
				if not best or score > bestScore then
					best = rec
					bestScore = score
				end
			end
		end
		return best
	end
	local GUARD_STAND_OFFSET = 2.5
	local GUARD_STRIKE_INTERVAL = 0.03
	local GUARD_STRIKE_TIMEOUT = 3.5   -- dinaikkan: cycle pertama guard sering masih bangun
	local GUARD_KNOCKBACK_VELOCITY = 18
	local GUARD_SETTLE_SECONDS = 0.25
	function EggRuntime:_stopGuardStick()
		if self.guardStickConnection then
			pcall(self.guardStickConnection.Disconnect, self.guardStickConnection)
			self.guardStickConnection = nil
		end
	end
	function EggRuntime:_startGuardStick()
		self:_stopGuardStick()
		local function forestGuardRoot()
			local objects = resolveObjectsRoot()
			local areas = objects and objects:FindFirstChild("Areas")
			local guardAreas = areas and areas:FindFirstChild("GuardAreas")
			local forest = guardAreas and guardAreas:FindFirstChild("Forest")
			local guard = forest and forest:FindFirstChild("Guard")
			return guard and guard:FindFirstChild("HumanoidRootPart")
		end
		self.guardStickConnection = RunService.PreSimulation:Connect(function()
			if self.destroyed or not self.enabled or self.instantPhase ~= "priming" then
				self:_stopGuardStick()
				return
			end
			local guardRoot = forestGuardRoot()
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not guardRoot or not root then
				return
			end
			local guardPosition = guardRoot.Position
			local front = guardRoot.CFrame.LookVector * GUARD_STAND_OFFSET
			local standAt = Vector3.new(guardPosition.X + front.X, root.Position.Y, guardPosition.Z + front.Z)
			local delta = standAt - root.Position
			if delta.Magnitude > 40 then
				delta = delta.Unit * 40
			end
			local nextPosition = root.Position + delta
			root.CFrame = CFrame.lookAt(nextPosition, Vector3.new(guardPosition.X, nextPosition.Y, guardPosition.Z))
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			self:_syncHoverPad(nextPosition)
			end)
	end
	function EggRuntime:_forestGuardModel()
		local objects = resolveObjectsRoot()
		local areas = objects and objects:FindFirstChild("Areas")
		local guardAreas = areas and areas:FindFirstChild("GuardAreas")
		local forest = guardAreas and guardAreas:FindFirstChild("Forest")
		return forest and forest:FindFirstChild("Guard")
	end
	function EggRuntime:_triggerGuardHit()
		local guard = self:_forestGuardModel()
		local guardRoot = guard and guard:FindFirstChild("HumanoidRootPart")
		if not guardRoot then return end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local guardPosition = guardRoot.Position
		local front = guardRoot.CFrame.LookVector * GUARD_STAND_OFFSET
		local standAt = Vector3.new(guardPosition.X + front.X, root.Position.Y, guardPosition.Z + front.Z)
		self.guardStrikeAnchor = standAt
		root.CFrame = CFrame.lookAt(standAt, Vector3.new(guardPosition.X, standAt.Y, guardPosition.Z))
		root.AssemblyLinearVelocity = Vector3.zero
		local collider = guard:FindFirstChild("Collider") or guardRoot
		if collider and firetouchinterest then
			pcall(function()
				firetouchinterest(root, collider, 0)
				firetouchinterest(root, collider, 1)
				end)
		end
		pcall(function()
			local strike = Remotes.GuardPatrol and Remotes.GuardPatrol.ForestStrike
			if strike then
				strike:FireServer({
					EggUid = self.primerUid,
					GuardCFrame = guardRoot.CFrame,
					})
			end
			end)
	end
	function EggRuntime:_stopGuardStrike()
		self.guardStrikeGeneration = (self.guardStrikeGeneration or 0) + 1
	end
	function EggRuntime:_knockbackLanded()
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return false end
		if humanoid.PlatformStand or humanoid.Sit then return true end
		local state = humanoid:GetState()
		if state == Enum.HumanoidStateType.Ragdoll
		or state == Enum.HumanoidStateType.FallingDown
		or state == Enum.HumanoidStateType.PlatformStanding
		then
			return true
		end
		return root.AssemblyLinearVelocity.Magnitude > GUARD_KNOCKBACK_VELOCITY
	end
	function EggRuntime:_settleAfterKnockback()
		local anchor = self.guardStrikeAnchor
		local deadline = os.clock() + GUARD_SETTLE_SECONDS
		while os.clock() < deadline and not self.destroyed do
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then return end
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				pcall(function()
					humanoid.PlatformStand = false
					humanoid.Sit = false
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
					end)
			end
			if anchor then root.CFrame = CFrame.new(anchor) end
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			self:_syncHoverPad(anchor or root.Position)
			RunService.Heartbeat:Wait()
		end
	end
	function EggRuntime:_startGuardStrike()
		self:_stopGuardStrike()
		local generation = self.guardStrikeGeneration
		task.spawn(function()
			local deadline = os.clock() + GUARD_STRIKE_TIMEOUT
			while not self.destroyed
			and self.enabled
			and self.instantPhase == "priming"
			and self.guardStrikeGeneration == generation
			and os.clock() < deadline
			do
				self:_triggerGuardHit()
				local waitUntil = os.clock() + GUARD_STRIKE_INTERVAL
				local landed = false
				while os.clock() < waitUntil do
					if self:_knockbackLanded() then landed = true break end
					RunService.Heartbeat:Wait()
				end
				if landed then break end
			end
			if self.guardStrikeGeneration == generation then
				self:_stopGuardStick()
				self:_settleAfterKnockback()
			end
			end)
	end
	function EggRuntime:_enterBaitWait()
		self:_setInstantAnchored(false)
		self:_setStatus("Provoking Forest guard")
		self:_startGuardStick()
		self:_startGuardStrike()
		if self.hitTimer then return end
		self.hitTimer = task.delay(GUARD_STRIKE_TIMEOUT + 0.3, function()
			self.hitTimer = nil
			if self.destroyed or not self.enabled then return end
			if self.instantPhase ~= "priming" then return end
			self:_stopGuardStick()
			self:_stopGuardStrike()
			self:_finish("Guard bait timeout")
			end)
	end

	function EggRuntime:_resolveSettleSeconds(record)

		local areaId = type(record) == "table" and record.AreaId or nil
		local secs = areaId and SETTLE_BY_AREA[tostring(areaId)] or nil
		if type(secs) ~= "number" then secs = SETTLE_CAP_DEFAULT end
		return secs
	end
	function EggRuntime:_startPrimerTargetHunt()
		if self.instantPhase ~= "priming" then return end
		self:_stopGuardStick()
		self:_stopGuardStrike()
		pcall(function()
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.PlatformStand = false
				humanoid.Sit = false
			end
			if root then
				if self.guardStrikeAnchor then root.CFrame = CFrame.new(self.guardStrikeAnchor) end
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
			end)
		self:_kbCancelTimer()
		self:_setInstantAnchored(false)
		self.instantPhase = "hunting"
		self:_clearArrivalHold()
		self.carry.generation += 1
		self:_invalidateCarryWorker()
		self.carry.active = false
		self.carry.uid = nil
		local targetUid = self.targetUid
		self.targetUid = nil
		if not targetUid then
			self:_finish("No target egg")
			return
		end
		local current = EggCmds.ReadFieldEgg(targetUid) or self.records[targetUid]
		if not current or (current.State ~= AreaEggs.States.Slot and current.State ~= AreaEggs.States.Dropped) then
			self:_finish("Target egg no longer available")
			return
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then
			self:_finish("Character unavailable")
			return
		end
		self.activeTarget = current
		local destination = self:_resolveEggDestination(current, root, humanoid)
		if not destination then
			self:_finish("Target destination unavailable")
			return
		end
		if not self.lowFpsPrime then

			local holdUid = current.Uid
			local function stale()
				return self.destroyed or not self.enabled
					or self.instantPhase ~= "hunting"
					or not self.activeTarget or self.activeTarget.Uid ~= holdUid
			end
			local hoverCF = destination + Vector3.new(0, HOVER_DESYNC_HEIGHT, 0)
			self:_setStatus("Gliding to target")
			if not self:_glideRoot(hoverCF, stale) then
				if not stale() then self:_finish("Glide to target thất bại") end
				return
			end
			task.spawn(function()

				-- HOLD DIHAPUS: begitu sampai di atas telur, LANGSUNG carry.
				-- (dulu diam "Hold Delay" detik dulu -> lambat)
				local hold = math.clamp(tonumber(Config.StealHoldSeconds) or 0, 0, 20)
				local deadline = os.clock() + hold
				while os.clock() < deadline do
					if stale() then return end
					self:_setStatus(string.format("Holding on egg (%.1fs)", math.max(0, deadline - os.clock())))
					local ch = LocalPlayer.Character
					local r = ch and ch:FindFirstChild("HumanoidRootPart")
					local h = ch and ch:FindFirstChildOfClass("Humanoid")
					if r and h then
						pcall(function()
							r.CFrame = hoverCF
							r.AssemblyLinearVelocity = Vector3.zero
							r.AssemblyAngularVelocity = Vector3.zero
							end)
						self:_syncHoverPad(hoverCF.Position)
						local ls = math.clamp(self.config.speed or DEFAULT_MOVEMENT_SPEED, MIN_MOVEMENT_SPEED, maxMoveSpeed())
						pcall(function()
							setMovementSpoof(ch, ls * INTEGRITY_SPEED_HEADROOM)
							refreshIntegritySpoof(h, r, ls, Vector3.zero)
							end)
					end
					task.wait(0.05)
				end
				if stale() then return end

				self:_glideRoot(destination, stale)
				if stale() then return end
				self:_setArrivalHold(destination, holdUid)
				self:_setStatus("Securing target egg")
				self:_requestCarry(current, true)
				end)
			return
		end

		self:_setStatus("Traveling to target")
		self:_tweenRoot(destination, function()
			if self.instantPhase == "hunting"
			and self.activeTarget
			and self.activeTarget.Uid == current.Uid
			then
				self:_requestCarry(current, false)
			end
			end, nil, {
				holdAfterArrival = true,
				holdUid = current.Uid,
				flightProfile = true,
				carryTarget = current,
			})
	end
	function EggRuntime:_wallOpen()
		if self.resetBlocked or AreaEggResetWall.IsSealed() or os.clock() < self.gateOpenAt then
			return false
		end
		local __root = resolveObjectsRoot()
		local areas = __root and __root:FindFirstChild("Areas")
		local collision = areas and areas:FindFirstChild("WallStartCollision")
		if collision and collision:IsA("BasePart") and collision.CanCollide then
			return false
		end
		return true
	end
	function EggRuntime:_closeGate(reason)
		self.resetBlocked = true
		self.gateOpenAt = math.huge
		self.safeStarting = false
		if not (self.activeTween and self.activeTween.sharedTravel) then
			self:_cancelTween(reason)
		end
		self:_setStatus(reason)
	end
	function EggRuntime:_cancelTween(reason, keepOperation)
		self:_cleanupInstantSteal()
		self.carryAttemptToken = nil
		self:_clearArrivalHold()
		self.safeStarting = false
		if self.activeTween then
			pcall(self.activeTween.Cancel, self.activeTween)
			self.activeTween = nil
		end
		if not self.activeTween and not self.arrivalHold then self:_stopHoverPad() end
		if self.running then
			self.running = false
			self.activeTarget = nil
			self.stats.lastResult = reason
			self:_notify()
		end
		if not keepOperation then

		end
	end

	function EggRuntime:_groundYAt(x, z, character)
		character = character or (LocalPlayer.Character)
		local origin = Vector3.new(x, (character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Position.Y or SAFE_ZONE_POSITION.Y) + 60, z)
		local exclude = {}
		if character then table.insert(exclude, character) end
		if self.hoverPad then table.insert(exclude, self.hoverPad) end
		if self.treadmillDecoy then table.insert(exclude, self.treadmillDecoy) end
		for _, c in ipairs(workspace:GetChildren()) do
			if c.Name == HOVER_PAD_NAME or c.Name == TREADMILL_DECOY_NAME then
				table.insert(exclude, c)
			end
		end
		for _ = 1, 10 do
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = exclude
			params.IgnoreWater = true
			local hit = workspace:Raycast(origin, Vector3.new(0, -300, 0), params)
			if not hit then return nil end
			if hit.Instance.CanCollide then return hit.Position.Y end
			table.insert(exclude, hit.Instance)
		end
		return nil
	end
	function EggRuntime:_resolveSafeCFrame(root)
		if not root then return nil end
		return SAFE_ZONE_CFRAME
	end

	function EggRuntime:_groundSnap()
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return false end
		local pos = root.Position
		local groundY = self:_groundYAt(pos.X, pos.Z, character)
		if not groundY then return false end
		local restY = groundY + self:_feetOffset(root, humanoid)
		if pos.Y < restY - 0.25 or pos.Y > restY + 8 then
			pcall(function()
				self:_syncHoverPad(Vector3.new(pos.X, restY, pos.Z))
				root.CFrame = CFrame.new(pos.X, restY, pos.Z) * root.CFrame.Rotation
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end)
			return true
		end
		return false
	end
	local function destroyTreadmillDecoyTrail(instance)
		if typeof(instance) == "Instance" and instance:IsA("Trail") then
			pcall(instance.Destroy, instance)
		end
	end
	local function destroyTreadmillStealPopup(instance)
		if typeof(instance) == "Instance"
		and (instance.Name == "SpeedGainPopup" or instance.Name == "PlusOne")
		then
			pcall(instance.Destroy, instance)
		end
	end
	function EggRuntime:_showTreadmillDecoy()
		if self.treadmillDecoy and self.treadmillDecoy.Parent then
			return true
		end
		self:_hideTreadmillDecoy()
		local character = LocalPlayer.Character
		if not character then return false end
		local oldArchivable = character.Archivable
		character.Archivable = true
		local cloned, clone = pcall(character.Clone, character)
		character.Archivable = oldArchivable
		if not cloned or not clone or typeof(clone) ~= "Instance" then return false end
		clone.Name = TREADMILL_DECOY_NAME
		for _, descendant in ipairs(clone:GetDescendants()) do
			if TREADMILL_DECOY_REMOVE_CLASSES[descendant.ClassName] or descendant:IsA("Trail") then
				pcall(descendant.Destroy, descendant)
			elseif descendant:IsA("BasePart") then
				descendant.LocalTransparencyModifier = 0
				descendant.Anchored = true
				descendant.CanCollide = false
				descendant.CanQuery = false
				descendant.CanTouch = false
			end
		end
		local root = clone:FindFirstChild("HumanoidRootPart")
		local humanoid = clone:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then
			clone:Destroy()
			return false
		end
		pcall(function()
			humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
			humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
			end)
		clone.Parent = workspace
		clone:PivotTo(SAFE_ZONE_CFRAME)
		self.treadmillDecoy = clone
		local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
		if playerGui then
			for _, instance in ipairs(playerGui:GetDescendants()) do
				if instance.Name == "SpeedGainPopup" or instance.Name == "PlusOne" then
					destroyTreadmillStealPopup(instance)
				end
			end
			self.treadmillPopupConnection = playerGui.DescendantAdded:Connect(function(instance)
				if self.treadmillDecoy == clone then
					destroyTreadmillStealPopup(instance)
				end
				end)
		end
		local originals = setmetatable({}, { __mode = "k" })
		local function hideLivePart(part)
			if not part or not part:IsA("BasePart") or not part:IsDescendantOf(character) then return end
			if originals[part] == nil then originals[part] = part.LocalTransparencyModifier end
			part.LocalTransparencyModifier = 1
		end
		for _, descendant in ipairs(character:GetDescendants()) do
			hideLivePart(descendant)
			destroyTreadmillDecoyTrail(descendant)
		end
		self.treadmillDecoyRealTransparency = originals
		self.treadmillDecoyCharacterConnection = character.DescendantAdded:Connect(function(descendant)
			if self.treadmillDecoy == clone then
				pcall(hideLivePart, descendant)
				destroyTreadmillDecoyTrail(descendant)
			end
			end)
		local camera = workspace.CurrentCamera
		if camera then
			self.treadmillDecoyCamera = camera.CameraSubject
			camera.CameraSubject = humanoid
		end
		self.treadmillDecoyCameraConnection = RunService.RenderStepped:Connect(function()
			if self.treadmillDecoy ~= clone or not clone.Parent or not humanoid.Parent then return end
			for part in pairs(originals) do
				if part.Parent and part.LocalTransparencyModifier ~= 1 then
					part.LocalTransparencyModifier = 1
				end
			end
			local liveCamera = workspace.CurrentCamera
			if liveCamera and liveCamera.CameraSubject ~= humanoid then
				liveCamera.CameraSubject = humanoid
			end
			end)
		return true
	end
	function EggRuntime:_hideTreadmillDecoy()
		if self.treadmillDecoyCameraConnection then
			pcall(self.treadmillDecoyCameraConnection.Disconnect, self.treadmillDecoyCameraConnection)
			self.treadmillDecoyCameraConnection = nil
		end
		if self.treadmillDecoyCharacterConnection then
			pcall(self.treadmillDecoyCharacterConnection.Disconnect, self.treadmillDecoyCharacterConnection)
			self.treadmillDecoyCharacterConnection = nil
		end
		if self.treadmillPopupConnection then
			pcall(self.treadmillPopupConnection.Disconnect, self.treadmillPopupConnection)
			self.treadmillPopupConnection = nil
		end
		for part, transparency in pairs(self.treadmillDecoyRealTransparency or {}) do
			if typeof(part) == "Instance" and part.Parent then
				pcall(function() part.LocalTransparencyModifier = transparency end)
			end
		end
		self.treadmillDecoyRealTransparency = nil
		local character = LocalPlayer.Character
		local liveHumanoid = character and character:FindFirstChildOfClass("Humanoid")
		local camera = workspace.CurrentCamera
		if camera then
			pcall(function()
				camera.CameraSubject = liveHumanoid or self.treadmillDecoyCamera
				end)
		end
		self.treadmillDecoyCamera = nil
		if self.treadmillDecoy then pcall(self.treadmillDecoy.Destroy, self.treadmillDecoy) end
		self.treadmillDecoy = nil
	end
	function EggRuntime:_restoreTreadmillVisualAtSafe()
		if not self.treadmillDecoy then
			self:_hideTreadmillDecoy()
			return true
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local safeDestination = self:_resolveSafeCFrame(root)
		if not root or not humanoid or not safeDestination then
			self:_hideTreadmillDecoy()
			return false
		end
		local deadline = os.clock() + SAFE_TELEPORT_TIMEOUT_SECONDS
		local stableSince = nil
		local nextTeleportAt = 0
		while not self.destroyed and os.clock() < deadline do
			local now = os.clock()
			if not self:_isInSafeArea(root) then
				stableSince = nil
				if now >= nextTeleportAt then
					nextTeleportAt = now + SAFE_TELEPORT_RETRY_SECONDS
					self:_teleportRoot(root, humanoid, safeDestination)
				end
			else
				stableSince = stableSince or now
				if now - stableSince >= SAFE_TELEPORT_STABLE_SECONDS then
					self:_hideTreadmillDecoy()
					return true
				end
			end
			task.wait(0.03)
		end
		self:_hideTreadmillDecoy()
		return false
	end
	function EggRuntime:_resolveEggDestination(record, root, humanoid)
		if type(record) ~= "table" or typeof(record.BottomCFrame) ~= "CFrame" then
			return nil
		end
		local character = LocalPlayer.Character
		root = root or (character and character:FindFirstChild("HumanoidRootPart"))
		humanoid = humanoid or (character and character:FindFirstChildOfClass("Humanoid"))
		if not root or not humanoid then
			return nil
		end
		local standingHeight = self:_feetOffset(root, humanoid) + EGG_ARRIVAL_CLEARANCE
		return CFrame.new(record.BottomCFrame.Position + Vector3.new(0, standingHeight, 0))
	end
	function EggRuntime:_resolveRouteCruiseY()
		return nil
	end
	function EggRuntime:_resolveElevatedDestination(root, destination)
		if not root or typeof(destination) ~= "CFrame" then return nil end
		return destination
	end
	function EggRuntime:_teleportRoot(root, humanoid, destination)
		if not root or not humanoid or typeof(destination) ~= "CFrame" then return false end
		local ok = pcall(function()
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			root.CFrame = destination
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
			end)
		if not ok then return false end
		local liveSpeed = math.clamp(self.config.speed or DEFAULT_MOVEMENT_SPEED, MIN_MOVEMENT_SPEED, maxMoveSpeed())
		setMovementSpoof(LocalPlayer.Character, liveSpeed * INTEGRITY_SPEED_HEADROOM)
		if not refreshIntegritySpoof(humanoid, root, liveSpeed, Vector3.zero) then
			setIntegritySpoof(humanoid, root, liveSpeed)
			refreshIntegritySpoof(humanoid, root, liveSpeed, Vector3.zero)
		end
		return true
	end

	function EggRuntime:_glideRoot(destCF, abortFn, speed)
		if typeof(destCF) ~= "CFrame" then return false end
		speed = speed or GLIDE_SPEED
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not root or not humanoid then return false end
		pcall(applyKillPartIgnore, character)
		local glideGeneration = self.planGeneration
		local originalAutoRotate = humanoid.AutoRotate
		local function finishGlide(result)
			if humanoid and humanoid.Parent then
				pcall(function() humanoid.AutoRotate = originalAutoRotate end)
			end
			return result
		end
		pcall(function() humanoid.AutoRotate = false end)
		self:_startHoverPad()
		local target = destCF.Position
		local function warmSpoof(ch, h, r)
			local ls = math.clamp(self.config.speed or DEFAULT_MOVEMENT_SPEED, MIN_MOVEMENT_SPEED, maxMoveSpeed())
			pcall(function()
				setMovementSpoof(ch, ls * INTEGRITY_SPEED_HEADROOM)
				refreshIntegritySpoof(h, r, ls, Vector3.zero)
				end)
		end

		local deadline = os.clock() + math.clamp((target - root.Position).Magnitude / math.max(speed, 1) * 1.6 + 6, 15, 120)
		while os.clock() < deadline do
			if self.destroyed or not self.enabled or self.planGeneration ~= glideGeneration then
				return finishGlide(false)
			end
			if abortFn and abortFn() then return finishGlide(false) end
			if self.destroyed or not self.enabled then return finishGlide(false) end
			character = LocalPlayer.Character
			root = character and character:FindFirstChild("HumanoidRootPart")
			humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not root or not humanoid then return finishGlide(false) end
			local pos = root.Position
			local remaining = target - pos
			local dist = remaining.Magnitude
			if dist <= 1.0 then
				pcall(function()
					root.CFrame = destCF
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					end)
				self:_syncHoverPad(target)
				warmSpoof(character, humanoid, root)
				return finishGlide(true)
			end
			local dt = RunService.Heartbeat:Wait()
			dt = math.max(math.min(dt, LONG_FRAME_CLAMP), 1 / 240)
			local step = math.min(speed * dt, dist)
			local nextPos = pos + remaining.Unit * step
			if dt >= (1 / 30) then
				local groundY = self:_groundYAt(nextPos.X, nextPos.Z, character)
				if groundY then
					local minY = groundY + self:_feetOffset(root, humanoid)
					if nextPos.Y < minY then nextPos = Vector3.new(nextPos.X, minY, nextPos.Z) end
				end
			end
			pcall(function()
				root.CFrame = CFrame.new(nextPos, nextPos + remaining.Unit)
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				end)
			self:_syncHoverPad(nextPos)
			warmSpoof(character, humanoid, root)
		end
		return finishGlide(false)
	end

	function EggRuntime:_isInSafeArea(root)
		if not root then return false end
		local delta = root.Position - SAFE_ZONE_POSITION
		return Vector2.new(delta.X, delta.Z).Magnitude <= SAFE_ZONE_HORIZONTAL_RADIUS
		and math.abs(delta.Y) <= SAFE_ZONE_VERTICAL_TOLERANCE
	end
	function EggRuntime:_isInField(root)
		local objects = resolveObjectsRoot()
		local areas = objects and objects:FindFirstChild("Areas")
		local wall = areas and areas:FindFirstChild("WallStartCollision")
		if not wall or not wall:IsA("BasePart") then
			return true
		end
		return root.Position.X >= wall.Position.X + 3
	end
	function EggRuntime:_invalidateCarryWorker()
		self.carryWorker = nil
	end
	function EggRuntime:_claimCarryWorker(kind, uid)
		local generation = self.carry.generation
		local current = self.carryWorker
		if current and current.generation == generation then return nil end
		local worker = {
			kind = kind,
			uid = uid,
			generation = generation,
			token = {},
		}
		self.carryWorker = worker
		return worker
	end
	function EggRuntime:_isCarryWorkerCurrent(worker)
		return type(worker) == "table"
		and self.carryWorker == worker
		and self.carry.generation == worker.generation
		and not self.destroyed
		and self.enabled
	end
	function EggRuntime:_releaseCarryWorker(worker)
		if self.carryWorker == worker then self.carryWorker = nil end
	end
	function EggRuntime:_hasConfirmedCarry(uid)
		if not self.carry.active then
			return false
		end
		if uid == nil or self.carry.uid == nil then
			return true
		end
		return self.carry.uid == uid
	end
	function EggRuntime:_recordShowsCarried(uid)
		if type(uid) ~= "string" or uid == "" then
			return false
		end
		local record = EggCmds.ReadFieldEgg(uid) or self.records[uid]
		return type(record) == "table"
		and record.State == AreaEggs.States.Carried
		and record.CarrierUserId == LocalPlayer.UserId
	end
	function EggRuntime:_resolveMovementSpeed(humanoid)
		if not humanoid.Parent or humanoid.Health <= 0 then
			return nil
		end
		return math.clamp(self.config.speed, MIN_MOVEMENT_SPEED, maxMoveSpeed())
	end
	function EggRuntime:_feetOffset(root, humanoid)
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			return root.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5)
		end
		return root.Size.Y * 0.5 + 2
	end
	function EggRuntime:_isForeignTrap(instance)
		if instance.Name == PLAYER_TRAP_NAME and instance:IsA("BasePart") then
			local owner = instance:GetAttribute("Owner")
			return type(owner) ~= "string" or owner ~= LocalPlayer.Name
		end
		return instance:IsA("Model")
		and instance.Name == LEGACY_TRAP_MODEL_NAME
		and instance:FindFirstChild("Hitbox") ~= nil
	end
	function EggRuntime:_purgeTrap(instance)
		if not self.config.antiTrap or not instance or not instance.Parent then
			return
		end
		if self:_isForeignTrap(instance) then
			pcall(instance.Destroy, instance)
		end
	end
	function EggRuntime:_purgeTraps()
		for _, fName in ipairs({ "Transient", "__DEBRIS" }) do
			local folder = workspace:FindFirstChild(fName)
			if folder then
				for _, instance in ipairs(folder:GetDescendants()) do
					self:_purgeTrap(instance)
				end
			end
		end
	end
	function EggRuntime:_syncHoverPad(position)
		local part = self.hoverPad
		if not part or not part.Parent
		or part:GetAttribute(HOVER_PAD_OWNER_ATTRIBUTE) ~= self.hoverPadOwnerId
		then
			return false
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return false end
		local rootPosition = typeof(position) == "Vector3" and position or root.Position
		part.CFrame = CFrame.new(
			rootPosition.X,
			rootPosition.Y - self:_feetOffset(root, humanoid) - HOVER_PAD_THICKNESS * 0.5 - 0.05,
			rootPosition.Z
		)
		return true
	end
	function EggRuntime:_setArrivalHold(destination, uid)
		if typeof(destination) ~= "CFrame" then
			return
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if not character or not root then
			return
		end
		self.arrivalHold = {
			Character = character,
			RootPart = root,
			CFrame = destination,
			Uid = uid,
		}
	end
	function EggRuntime:_clearArrivalHold(uid)
		local hold = self.arrivalHold
		if not hold or uid == nil or hold.Uid == nil or hold.Uid == uid then
			self.arrivalHold = nil
		end
	end
	function EggRuntime:_enforceArrivalHold()
		local hold = self.arrivalHold
		if type(hold) ~= "table" or typeof(hold.CFrame) ~= "CFrame" then
			return false
		end
		if LocalPlayer.Character ~= hold.Character
		or not hold.RootPart
		or not hold.RootPart.Parent
		then
			self.arrivalHold = nil
			return false
		end
		self:_startHoverPad()
		pcall(function()
			hold.RootPart.AssemblyLinearVelocity = Vector3.zero
			hold.RootPart.AssemblyAngularVelocity = Vector3.zero
			self:_syncHoverPad(hold.CFrame.Position)
			hold.RootPart.CFrame = hold.CFrame
			end)
		self:_syncHoverPad(hold.CFrame.Position)
		return true
	end
	function EggRuntime:_purgeOrphanHoverPads()
		for _, child in ipairs(workspace:GetChildren()) do
			if child.Name == HOVER_PAD_NAME
			and child ~= self.hoverPad
			then
				pcall(child.Destroy, child)
			end
		end
	end
	function EggRuntime:_startHoverPad()
		local part = self.hoverPad
		if not part or not part.Parent
		or part:GetAttribute(HOVER_PAD_OWNER_ATTRIBUTE) ~= self.hoverPadOwnerId
		then
			self:_purgeOrphanHoverPads()
			if part and part.Parent then pcall(part.Destroy, part) end
			part = Instance.new("Part")
			part.Name = HOVER_PAD_NAME
			part:SetAttribute(HOVER_PAD_OWNER_ATTRIBUTE, self.hoverPadOwnerId)
			part.Anchored = true
			part.CanCollide = true
			part.CanQuery = true
			part.CanTouch = false
			part.CastShadow = false
			part.Transparency = 1
			part.Material = Enum.Material.SmoothPlastic
			part.Size = Vector3.new(HOVER_PAD_SIZE_XZ, HOVER_PAD_THICKNESS, HOVER_PAD_SIZE_XZ)
			self.hoverPad = part
			part.Parent = workspace
		end
		self:_syncHoverPad()
		if not self.hoverPadConnection then
			self.hoverPadConnection = RunService.PreSimulation:Connect(function()
				if not self:_syncHoverPad() then self:_startHoverPad() end
				end)
		end
		if not self.hoverPadPostConnection then
			self.hoverPadPostConnection = RunService.PostSimulation:Connect(function()
				if self.activeTween or self.arrivalHold then self:_syncHoverPad() end
				end)
		end
	end
	function EggRuntime:_stopHoverPad()
		if self.hoverPadConnection then
			pcall(self.hoverPadConnection.Disconnect, self.hoverPadConnection)
			self.hoverPadConnection = nil
		end
		if self.hoverPadPostConnection then
			pcall(self.hoverPadPostConnection.Disconnect, self.hoverPadPostConnection)
			self.hoverPadPostConnection = nil
		end
		if self.hoverPad then
			pcall(self.hoverPad.Destroy, self.hoverPad)
			self.hoverPad = nil
		end
		self:_purgeOrphanHoverPads()
	end
	function EggRuntime:_startMovementProtection()
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not character or not root or not humanoid then
			return false
		end
		local speed = math.clamp(self.config.speed or DEFAULT_MOVEMENT_SPEED, MIN_MOVEMENT_SPEED, maxMoveSpeed())
		self.protectionCharacter = character
		self.protectionHumanoid = humanoid
		self.protectionRoot = root
		setMovementSpoof(character, speed * INTEGRITY_SPEED_HEADROOM)
		setIntegritySpoof(humanoid, root, speed)
		if not self.integritySpoofConnection then
			self.integritySpoofConnection = RunService.PreSimulation:Connect(function()
				local currentCharacter = LocalPlayer.Character
				local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
				local currentHumanoid = currentCharacter and currentCharacter:FindFirstChildOfClass("Humanoid")
				if not currentCharacter or not currentRoot or not currentHumanoid then
					return
				end
				local liveSpeed = math.clamp(
					self.config.speed or DEFAULT_MOVEMENT_SPEED,
					MIN_MOVEMENT_SPEED,
					maxMoveSpeed()
				)
				self.protectionCharacter = currentCharacter
				self.protectionHumanoid = currentHumanoid
				self.protectionRoot = currentRoot
				setMovementSpoof(currentCharacter, liveSpeed * INTEGRITY_SPEED_HEADROOM)
				if not refreshIntegritySpoof(currentHumanoid, currentRoot, liveSpeed) then
					setIntegritySpoof(currentHumanoid, currentRoot, liveSpeed)
				end
				self:_enforceArrivalHold()
				end)
		end
		if not self.arrivalHoldConnection then
			self.arrivalHoldConnection = RunService.Heartbeat:Connect(function()
				self:_enforceArrivalHold()
				end)
		end
		return true
	end
	function EggRuntime:_stopMovementProtection()
		if self.integritySpoofConnection then
			pcall(self.integritySpoofConnection.Disconnect, self.integritySpoofConnection)
			self.integritySpoofConnection = nil
		end
		if self.arrivalHoldConnection then
			pcall(self.arrivalHoldConnection.Disconnect, self.arrivalHoldConnection)
			self.arrivalHoldConnection = nil
		end
		self:_clearArrivalHold()
		self:_stopHoverPad()
		clearMovementSpoof()
		clearIntegritySpoof(self.protectionHumanoid)
		self.protectionCharacter = nil
		self.protectionHumanoid = nil
		self.protectionRoot = nil
	end
	function EggRuntime:_tweenRoot(destination, callback, speedOverride, handlers)
		self:_clearArrivalHold()
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		handlers = handlers or {}
		if not root or not humanoid then
			self.safeStarting = false
			if handlers.silent then
				if handlers.onDone then pcall(handlers.onDone, false) end
				return
			end
			self:_finish("Character unavailable")
			return
		end
		local movementSpeed = speedOverride or self:_resolveMovementSpeed(humanoid)
		if not movementSpeed then
			self.safeStarting = false
			if handlers.silent then
				if handlers.onDone then pcall(handlers.onDone, false) end
				return
			end
			self:_finish("Movement unavailable")
			return
		end
		movementSpeed = math.clamp(movementSpeed, MIN_MOVEMENT_SPEED, maxMoveSpeed())
		self:_startMovementProtection()
		pcall(applyKillPartIgnore, character)
		local camera = workspace.CurrentCamera
		if camera and camera.CameraSubject ~= humanoid then
			pcall(function()
				camera.CameraSubject = humanoid
				end)
		end
		local originalAutoRotate = humanoid.AutoRotate
		humanoid.AutoRotate = false
		local routeCruiseY = handlers.flightProfile == true
		and self:_resolveRouteCruiseY(root, destination)
		or nil
		local token = {
			sharedTravel = handlers.sharedTravel == true,
			routeCruiseY = routeCruiseY,
			travelPhase = routeCruiseY and "takeoff" or nil,

		}
		self.activeTween = token
		self:_startHoverPad()
		local released = false
		local connection
		local arrivalStableSince = nil
		local previousRemainingDistance = nil
		local correctionSlowUntil = 0
		local function release(completed)
			if released then
				return
			end
			released = true
			arrivalStableSince = nil
			if humanoid.Parent ~= nil then
				humanoid.AutoRotate = originalAutoRotate
			end
			if completed and handlers.holdAfterArrival then
				self:_setArrivalHold(destination, handlers.holdUid)
			end
			if handlers.onDone then
				pcall(handlers.onDone, completed == true)
			end
			if connection then
				connection:Disconnect()
				connection = nil
			end
			if self.activeTween == token then
				self.activeTween = nil
			end
			if not self.arrivalHold then self:_stopHoverPad() end
			if not self.enabled then
				self:_stopMovementProtection()
			end
			pcall(function()
				if LocalPlayer.Character == character and root.Parent then
					root.AssemblyLinearVelocity = Vector3.zero
				end
				end)
			if completed
			and LocalPlayer.Character == character
			and humanoid.Parent ~= nil
			then
				if callback then
					callback()
				end
			end
		end
		token.Cancel = function()
			release(false)
		end
		connection = RunService.Heartbeat:Connect(function(deltaTime)
			if handlers.abort and handlers.abort() then
				release(false)
				return
			end
			if self.destroyed or self.activeTween ~= token then
				release(false)
				return
			end
			if handlers.carryTarget and os.clock() >= (token.nextTargetCheck or 0) then
				token.nextTargetCheck = os.clock() + 0.1
				local targetUid = handlers.carryTarget.Uid
				local live = EggCmds.ReadFieldEgg(targetUid)
				local state = live and live.State
				if state ~= AreaEggs.States.Slot and state ~= AreaEggs.States.Dropped and state ~= "GuardCarried"
				and not (live and live.CarrierUserId == LocalPlayer.UserId)
				and not self:_hasConfirmedCarry(targetUid)
				then
					release(false)
					self:_finish("Target taken by someone else")
					return
				end
			end
			pcall(function()
				local liveSpeed = math.clamp(
					speedOverride or self.config.speed or movementSpeed,
					MIN_MOVEMENT_SPEED,
					maxMoveSpeed()
				)
				setMovementSpoof(character, liveSpeed * INTEGRITY_SPEED_HEADROOM)
				local holder = environment()[INTEGRITY_SPOOF_KEY]
				local integrityState = type(holder) == "table" and holder.State or nil
				if not integrityStateCanTravel(integrityState, humanoid, root) then
					previousRemainingDistance = nil
					arrivalStableSince = nil
					if integrityStateMatches(integrityState, humanoid, root) then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						self:_syncHoverPad(root.Position)
						patchIntegrityState(integrityState, liveSpeed * INTEGRITY_SPEED_HEADROOM, Vector3.zero)
						return
					end
					-- state belum ketemu -> JANGAN freeze. Coba cari (async), lalu
					-- tetap bergerak tanpa spoof. Kalau state sudah ada tapi tidak
					-- cocok, baru bail (tunggu karakter/root sinkron).
					setIntegritySpoof(humanoid, root, liveSpeed)
					if integrityState ~= nil then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						self:_syncHoverPad(root.Position)
						return
					end
				end
				local position = root.Position
				local remaining = destination.Position - position
				local remainingDistance = remaining.Magnitude
				local horizontalRemaining = Vector3.new(remaining.X, 0, remaining.Z)
				local horizontalDistance = horizontalRemaining.Magnitude
				local movementTarget = destination.Position
				if token.routeCruiseY then
					if token.travelPhase == "takeoff" then
						if position.Y >= token.routeCruiseY - 0.5 then
							token.travelPhase = "cruise"
						else
							movementTarget = Vector3.new(position.X, token.routeCruiseY, position.Z)
						end
					end
					if token.travelPhase == "cruise" then
						if horizontalDistance <= 4 then
							token.travelPhase = "descend"
						else
							movementTarget = Vector3.new(destination.Position.X, token.routeCruiseY, destination.Position.Z)
						end
					end
					if token.travelPhase == "descend" then
						movementTarget = destination.Position
					end
				end
				local movementRemaining = movementTarget - position
				local movementDistance = movementRemaining.Magnitude
				local progressDistance = token.routeCruiseY and horizontalDistance or remainingDistance
				if previousRemainingDistance
				and progressDistance > previousRemainingDistance + CORRECTION_DISTANCE_EPSILON
				then
					correctionSlowUntil = os.clock() + CORRECTION_SLOWDOWN_SECONDS
				end
				previousRemainingDistance = progressDistance
				local effectiveSpeed = os.clock() < correctionSlowUntil
				and math.max(MIN_MOVEMENT_SPEED, liveSpeed * CORRECTION_SPEED_FACTOR)
				or liveSpeed
if handlers.carryTarget and not token.__earlyCarrySpam and remainingDistance <= 20 then
    token.__earlyCarrySpam = true
    local targetRec = handlers.carryTarget
    local targetUid = targetRec.Uid
    local slotKey = AreaEggSlotIdentity.LooksLikeFirstAreaUid(targetUid)
    and AreaEggSlotIdentity.SlotKey(targetRec.AreaId, targetRec.NestId)
    or nil
    task.spawn(function()
        while not self.destroyed
        and self.enabled
        and self.activeTween == token
        and not self:_hasConfirmedCarry(targetUid)
        do
            local live = EggCmds.ReadFieldEgg(targetUid)
            if live and live.State ~= AreaEggs.States.Slot
                and live.State ~= AreaEggs.States.Dropped
            then
                break
            end
            pcall(requestFieldEggCarry, targetUid, slotKey)
            task.wait(0.06)
        end
        end)
end
				local safeDeltaTime = math.max(math.min(deltaTime, LONG_FRAME_CLAMP), 1 / 240)
				local stepDistance = effectiveSpeed * safeDeltaTime
				local flatDirection = horizontalRemaining
				local currentLook = Vector3.new(root.CFrame.LookVector.X, 0, root.CFrame.LookVector.Z)
				local facingDirection = flatDirection.Magnitude > 0.001 and flatDirection.Unit
				or (currentLook.Magnitude > 0.001 and currentLook.Unit or Vector3.new(0, 0, -1))
				local canArrive = not token.routeCruiseY or token.travelPhase == "descend"
				if canArrive and remainingDistance <= math.max(stepDistance, 0.05) then
					if remainingDistance > 0.5 then
						arrivalStableSince = nil
					end
					self:_syncHoverPad(destination.Position)
					root.CFrame = CFrame.lookAt(destination.Position, destination.Position + facingDirection)
					root.AssemblyLinearVelocity = Vector3.zero
					self:_syncHoverPad(destination.Position)
					refreshIntegritySpoof(humanoid, root, liveSpeed, Vector3.zero)
					arrivalStableSince = arrivalStableSince or os.clock()
					if os.clock() - arrivalStableSince >= MOVEMENT_ARRIVAL_HOLD then
						release(true)
					end
					return
				end
				arrivalStableSince = nil
				if movementDistance <= 0.001 then
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					self:_syncHoverPad(position)
					return
				end
				if not self.hoverPad or not self.hoverPad.Parent then self:_startHoverPad() end
				local actualStepDistance = math.min(stepDistance, movementDistance)
				local nextPosition = position + movementRemaining.Unit * actualStepDistance

				if safeDeltaTime >= (1 / 30) and (not token.routeCruiseY or token.travelPhase ~= "cruise") then
					local groundY = self:_groundYAt(nextPosition.X, nextPosition.Z, character)
					if groundY then
						local minY = groundY + self:_feetOffset(root, humanoid)
						if nextPosition.Y < minY then
							nextPosition = Vector3.new(nextPosition.X, minY, nextPosition.Z)
						end
					end
				end
				local travelVelocity = (nextPosition - position) / safeDeltaTime
				self:_syncHoverPad(nextPosition)
				root.CFrame = CFrame.lookAt(nextPosition, nextPosition + facingDirection)
				root.AssemblyLinearVelocity = Vector3.zero
				self:_syncHoverPad(nextPosition)
				if not refreshIntegritySpoof(humanoid, root, liveSpeed, travelVelocity) then
					setIntegritySpoof(humanoid, root, liveSpeed)
					refreshIntegritySpoof(humanoid, root, liveSpeed, travelVelocity)
				end
				end)
			end)
	end
	function EggRuntime:_reStealDroppedEgg(uid)
		if type(uid) ~= "string" or uid == "" then
			self:_finish("Egg lost — retrying")
			return
		end
		if self:isSkippedEgg(uid) then return end
		if self.tweenRecoveryUid == uid then
			self.running = false
			self.activeTarget = nil

			self:_scheduleMovementRetry()
			return
		end
		local worker = self:_claimCarryWorker("re-steal", uid)
		if not worker then return end
		local record = nil
		local deadline = os.clock() + 5
		self:_setStatus("Re-stealing dropped egg")
		while self:_isCarryWorkerCurrent(worker) and os.clock() < deadline do
			local candidate = EggCmds.ReadFieldEgg(uid) or self.records[uid]
			if candidate
			and (candidate.State == AreaEggs.States.Dropped or candidate.State == AreaEggs.States.Slot)
			then
				record = candidate
				break
			end
			task.wait(0.03)
		end
		if not self:_isCarryWorkerCurrent(worker) then return end
		if not record or not self:_wallOpen() then
			self:_releaseCarryWorker(worker)
			self:_finish("Egg lost — retrying")
			return
		end
		self:_cancelTween("Re-stealing dropped egg", true)
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local destination = self:_resolveEggDestination(record, root, humanoid)
		destination = destination and self:_resolveElevatedDestination(root, destination) or nil
		if not destination then
			self:_releaseCarryWorker(worker)
			self:_finish("Character unavailable")
			return
		end
		self.running = true
		self.activeTarget = record
		self:_setStatus("Re-grabbing dropped egg")
		if self:_regrabBurst(worker, record.Uid, 6.0) or not self:_isCarryWorkerCurrent(worker) then return end
		self:_setStatus("Teleporting to dropped egg")
		if not self:_teleportRoot(root, humanoid, destination) then
			self:_releaseCarryWorker(worker)
			self:_finish("Dropped egg teleport thất bại")
			return
		end
		self:_setArrivalHold(destination, record.Uid)
		self:_setStatus("Re-stealing egg")
		if self:_isCarryWorkerCurrent(worker) then self:_requestCarry(record, true) end
	end
	function EggRuntime:_regrabBurst(worker, uid, seconds)
		local function heldByMe()
			local current = EggCmds.ReadFieldEgg(uid)
			return current ~= nil and current.State == AreaEggs.States.Carried and current.CarrierUserId == LocalPlayer.UserId
		end
		local function currentEgg()
			return EggCmds.ReadFieldEgg(uid) or self.records[uid]
		end
		-- FIX KRITIS: server menolak AskFieldEggCarry kalau FirstAreaSlotKey tidak ada.
		-- Jalur burst dulu memanggil { Uid = uid } saja -> telur area pertama (Forest)
		-- selalu gagal. Sekarang ikut hitung slotKey seperti requestFieldEggCarry.
		local function slotKeyFor(rec)
			if rec and rec.Uid and AreaEggSlotIdentity.LooksLikeFirstAreaUid(rec.Uid) then
				return AreaEggSlotIdentity.SlotKey(rec.AreaId, rec.NestId)
			end
			return nil
		end
		local ragdoll = nil
		pcall(function() ragdoll = require(ReplicatedStorage.Shared.Modules.RagdollJoints) end)
		local askBusy, carryBusy = false, false
		local deadline = os.clock() + seconds
		while os.clock() < deadline and not self.destroyed and self.enabled do
			if heldByMe() then return true end
			if not self:_isCarryWorkerCurrent(worker) then return heldByMe() end
			local current = currentEgg()
			if not current or (current.State ~= AreaEggs.States.Dropped and current.State ~= AreaEggs.States.Slot) then
				-- anti-flicker: kalau state lagi "berkedip" (Carried singkat), coba baca ulang
				-- beberapa kali sebelum menyerah. Kalau memang sudah bukan milik kita, balikin false.
				local recovered = nil
				for _ = 1, 5 do
					task.wait(0.04)
					if heldByMe() then return true end
					local r2 = currentEgg()
					if r2 and (r2.State == AreaEggs.States.Dropped or r2.State == AreaEggs.States.Slot) then
						recovered = r2
						break
					end
				end
				if not recovered then return false end
				current = recovered
			end
			local character = LocalPlayer.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if not root or not humanoid then return false end
			pcall(function()
				if ragdoll and ragdoll.Release then ragdoll.Release(character) end
				humanoid.PlatformStand = false
				humanoid.Sit = false
				if humanoid:GetState() ~= Enum.HumanoidStateType.Running then
					humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
				end
				end)
			local destination = self:_resolveEggDestination(current, root, humanoid)
			if destination then
				root.CFrame = destination
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				self:_syncHoverPad(destination.Position)
			end
			if not askBusy then
				askBusy = true
				task.spawn(function()
					pcall(function() EggWorld.AskFieldEggCarry:InvokeServer({ Uid = uid, FirstAreaSlotKey = slotKeyFor(current) or tostring(uid) }) end)
					askBusy = false
					end)
			end
			if not carryBusy then
				carryBusy = true
				task.spawn(function()
					pcall(EggCmds.CarryFieldEgg, uid)
					carryBusy = false
					end)
			end
			pcall(function()
				local slots = workspace:FindFirstChild("AreaEggSlotsClient")
				local model = slots and slots:FindFirstChild(tostring(uid))
				local prompt = model and (model:FindFirstChild("CarryAreaEgg", true) or model:FindFirstChildWhichIsA("ProximityPrompt", true))
				if prompt and prompt.Enabled and type(fireproximityprompt) == "function" then
					prompt.HoldDuration = 0
					prompt.RequiresLineOfSight = false
					fireproximityprompt(prompt, 0)
				end
				end)
			task.wait(0.06)
		end
		return heldByMe()
	end
	function EggRuntime:_recoverCarryConfirmationTimeout(attemptToken, targetUid)
		if self.destroyed
		or not self.enabled
		or self.carryAttemptToken ~= attemptToken
		or self:_hasConfirmedCarry(targetUid)
		then
			return false
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local safeCFrame = root and self:_resolveSafeCFrame(root)
		safeCFrame = safeCFrame and self:_resolveElevatedDestination(root, safeCFrame) or nil
		self.tweenRecoveryUid = targetUid
		self.carry.generation += 1
		self:_invalidateCarryWorker()
		self.carryAttemptToken = nil
		self:_clearArrivalHold(targetUid)
		if self.activeTween and self.activeTween.Cancel then
			pcall(self.activeTween.Cancel, self.activeTween)
		end
		self.activeTween = nil
		self:_stopMovementProtection()
		self.running = false
		self.activeTarget = nil
		self.stats.lastResult = "Carry confirmation timeout"
		if root and safeCFrame then
			pcall(function()
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				root.CFrame = safeCFrame
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				end)
			self:_setStatus("Carry timeout — teleported safe")
		else
			self:_setStatus("Carry timeout — safe area unavailable")
		end
		if self.enabled then
			self:_startMovementProtection()
		end

		task.delay(0.35, function()
			if not self.destroyed and self.enabled and self.carryAttemptToken == nil then
				self:_schedule()
			end
			end)
		return true
	end
	function EggRuntime:_requestCarry(record, teleportReapproach)
		if not self:_wallOpen() then
			self:_finish("Wall closed before carry")
			return
		end
		local targetUid = record.Uid
		local attemptToken = {}
		local confirmationDeadline = nil

		local isPrimerCarry = self.instantPhase == "priming" and targetUid == self.primerUid
		local confirmWindow = isPrimerCarry and CARRY_CONFIRM_TIMEOUT_SECONDS
			or math.max(CARRY_CONFIRM_TIMEOUT_SECONDS, self:_resolveSettleSeconds(record) + 3)
		self.carryAttemptToken = attemptToken
		self.stats.lastResult = "Carry requested"
		self:_setStatus("Securing egg")
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			pcall(humanoid.UnequipTools, humanoid)
		end
		task.spawn(function()
			while not self.destroyed
			and self.enabled
			and self.running
			and self.carryAttemptToken == attemptToken
			and self.activeTarget
			and self.activeTarget.Uid == targetUid
			do
				if self:_hasConfirmedCarry(targetUid) then
					if self:_recordShowsCarried(targetUid) then
						self:_clearArrivalHold(targetUid)
						self.carryAttemptToken = nil
						if self.activeTween then
							pcall(self.activeTween.Cancel, self.activeTween)
							self.activeTween = nil
						end
						if self.instantPhase == "priming" and targetUid == self.primerUid then
							self.carry.active = true
							self.carry.uid = targetUid
							self.stats.lastResult = "Primer secured"
							self:_enterBaitWait()
							return
						end

						self.carry.active = true
						self.carry.uid = targetUid
						self.stats.lastResult = "Carry confirmed"
						self:_setStatus("Carry confirmed")
						task.defer(function()
							if not self.destroyed and self.enabled and self:_hasConfirmedCarry(targetUid) then
								self:_returnToSafe()
							end
							end)
						return
					end
					self:_setStatus("Confirming carry record")
					task.wait(CARRY_RETRY_INTERVAL)
					continue
				end
				if confirmationDeadline and os.clock() >= confirmationDeadline then
					self:_recoverCarryConfirmationTimeout(attemptToken, targetUid)
					return
				end
				if not self:_wallOpen() then
					self:_finish("Wall closed before carry")
					return
				end
				local current = EggCmds.ReadFieldEgg(targetUid) or self.records[targetUid]
				if not current then
					self:_finish("Target unavailable")
					return
				end
				if current.State == AreaEggs.States.Carried then
					if current.CarrierUserId == LocalPlayer.UserId then
						self:_setStatus("Confirming carry state")
						task.wait(CARRY_RETRY_INTERVAL)
						continue
					end
					self:_finish("Egg carried by another player")
					return
				end
				if current.State ~= AreaEggs.States.Slot and current.State ~= AreaEggs.States.Dropped then
					self:_finish("Target changed")
					return
				end
				local character = LocalPlayer.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				if not root then
					self:_finish("Character unavailable")
					return
				end
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not humanoid then
					self:_finish("Character unavailable")
					return
				end
				local groundedEggDestination = self:_resolveEggDestination(current, root, humanoid)
				local reapproachDestination = groundedEggDestination
				and self:_resolveElevatedDestination(root, groundedEggDestination)
				or nil
				if not reapproachDestination then
					self:_finish("Character unavailable")
					return
				end
				local eggPosition = reapproachDestination.Position
				if (root.Position - eggPosition).Magnitude > CARRY_REAPPROACH_DISTANCE then
					if teleportReapproach then
						self:_setStatus("Teleporting back to dropped egg")
						if not self:_teleportRoot(root, humanoid, reapproachDestination) then
							self:_finish("Dropped egg teleport thất bại")
							return
						end
						self:_setArrivalHold(reapproachDestination, targetUid)
						self:_setStatus("Re-stealing egg")
					else
						self:_setStatus("Re-approaching egg")
						local reapproachDone = false
						-- [Gp4q PATCH] dulu loop ini TANPA deadline: kalau _tweenRoot
						-- gagal jalan (activeTween masih kepakai) callback tak pernah
						-- dipanggil -> while abadi, confirmationDeadline tak pernah
						-- di-arm -> "stuck di proses naik". Sekarang ada batas waktu.
						local reapproachDeadline = os.clock() + math.max(confirmWindow, 4)
						self:_tweenRoot(groundedEggDestination, function()
							reapproachDone = true
							if self.carryAttemptToken == attemptToken and not self:_hasConfirmedCarry(targetUid) then
								self:_setStatus("Securing egg")
							end
							end, nil, {
								holdAfterArrival = true,
								holdUid = targetUid,
								flightProfile = true,
							})
						while not self.destroyed
						and self.enabled
						and self.carryAttemptToken == attemptToken
						and not self:_hasConfirmedCarry(targetUid)
						and not reapproachDone
						do
							if os.clock() >= reapproachDeadline then
								self:_recoverCarryConfirmationTimeout(attemptToken, targetUid)
								return
							end
							task.wait(CARRY_RETRY_INTERVAL)
						end
						continue
					end
				end
				local slotKey = AreaEggSlotIdentity.LooksLikeFirstAreaUid(current.Uid)
				and AreaEggSlotIdentity.SlotKey(current.AreaId, current.NestId)
				or nil
				-- [Gp4q PATCH] deadline di-arm SEBELUM request. Dulu di-arm sesudah,
				-- jadi kalau request pertama throw / loop kena `continue` di atas,
				-- timeout tak pernah aktif dan status bisa nyangkut selamanya.
				confirmationDeadline = confirmationDeadline or (os.clock() + confirmWindow)
				local okCarry, carryResult, carryReason = pcall(requestFieldEggCarry, current.Uid, slotKey)
				if not okCarry then
					CARRY_DIAG.reason = "invoke error: " .. tostring(carryResult)
					CARRY_DIAG.at, CARRY_DIAG.uid = os.clock(), current.Uid
				elseif carryResult ~= true and type(carryReason) == "string" then
					self.stats.lastResult = "Carry rejected: " .. carryReason
				end
				if okCarry and carryResult == true then self.stats.lastResult = "Carry requested" end
				self:_setStatus("Waiting for carry confirmation")
				task.wait(CARRY_RETRY_INTERVAL)
			end
			end)
	end

	function EggRuntime:_treadmillReset(abortFn)
		local function aborted() return abortFn ~= nil and abortFn() end
		local Treadmill = Remotes and Remotes.Treadmill
		if not Treadmill or aborted() then return false end
		local function serverMounted()
			local ok, ids = pcall(function() return Treadmill.AskRenderSnapshot:InvokeServer() end)
			if not ok or type(ids) ~= "table" then return nil end
			return table.find(ids, LocalPlayer.UserId) ~= nil
		end
		local function standCFrame()
			local ok, cf = pcall(function()
				local slot = type(PlotState.ResolveLocalSlot) == "function"
					and PlotState.ResolveLocalSlot() or PlotState.GetMySlot()
				local plotsFolder = type(PlotState.ResolveFolder) == "function"
					and PlotState.ResolveFolder() or PlotState.GetPlotsFolder()
				local plotFolder = plotsFolder and slot and plotsFolder:FindFirstChild(tostring(slot))
				local bottom = plotFolder and plotFolder:FindFirstChild("TreadmillBottom")
				if not (bottom and bottom:IsA("BasePart")) then return nil end
				local character = LocalPlayer.Character
				local root = character and character:FindFirstChild("HumanoidRootPart")
				local humanoid = character and character:FindFirstChildOfClass("Humanoid")
				if not root or not humanoid then return nil end
				local feetOffset = humanoid.RigType == Enum.HumanoidRigType.R15
					and (root.Size.Y * 0.5 + math.max(humanoid.HipHeight, 0.5))
					or (root.Size.Y * 0.5 + 2)
				return bottom.CFrame * CFrame.new(0, bottom.Size.Y * 0.5 + feetOffset + 0.05, 0)
			end)
			return ok and cf or nil
		end
		local stand = standCFrame()
		if not stand or aborted() then return false end

		self:_glideRoot(stand, function() return aborted() end)
		if aborted() then return false end
		local mountedOk = false
		local mountDeadline = os.clock() + 0.7
		while not aborted() and os.clock() < mountDeadline do
			pcall(function() Treadmill.AskWearStill:InvokeServer() end)
			task.wait(0.08)
			if serverMounted() == true then mountedOk = true break end
		end
		if mountedOk then
			local holdUntil = os.clock() + 0.25
			while not aborted() and os.clock() < holdUntil do
				task.wait(0.05)
			end
		end
		local released = false
		local releaseDeadline = os.clock() + 0.7
		while not aborted() and os.clock() < releaseDeadline do
			pcall(function() Treadmill.AskDoff:InvokeServer() end)
			task.wait(0.08)
			if serverMounted() == false then released = true break end
		end
		return mountedOk and released
	end
	function EggRuntime:_instantReturn(uid)
		if self._instantReturnToken ~= nil then return end
		local token = {}
		self._instantReturnToken = token

		task.spawn(function()
			local function alive()
				return not self.destroyed and self.enabled and self._instantReturnToken == token
			end
			local function parts()
				local character = LocalPlayer.Character
				return character and character:FindFirstChild("HumanoidRootPart"),
					character and character:FindFirstChildOfClass("Humanoid")
			end
			local function record()
				return EggCmds.ReadFieldEgg(uid)
			end
			local function heldByMe()
				local r = record()
				return r ~= nil and r.State == AreaEggs.States.Carried and r.CarrierUserId == LocalPlayer.UserId
			end
			local function banked()
				local r = record()
				if not r then return true end
				return r.State == AreaEggs.States.Claimed
			end
			local function safeCFrame()
				local root = (parts())
				return root and self:_resolveSafeCFrame(root) or nil
			end
			local function finish(reason, reportStolen)
				if self._instantReturnToken ~= token then return end
				self._instantReturnToken = nil
				self._forestDropInProgress = nil
				if not self.destroyed and self.enabled then
					if reportStolen ~= false then self:_reportStolen() end
					self:_finish(reason or "Safe return complete")
				end
			end

			self:_clearArrivalHold(uid)

			local dropRelay = FOREST_DROP_RELAY
			local needsTransfer = heldByMe()

			if needsTransfer then
				self._forestDropInProgress = uid

				self:_setStatus("Gliding egg to relay")
				if not self:_glideRoot(dropRelay, function()
					return not alive() or not heldByMe()
				end) then
					finish("Relay travel thất bại — retrying")
					return
				end
				if not alive() then return end

				local released = false
				for attempt = 1, FOREST_TRANSFER_ATTEMPTS do
					if not alive() or not heldByMe() then break end
					self:_setStatus(string.format("Dropping egg (%d/%d)", attempt, FOREST_TRANSFER_ATTEMPTS))
					self:_glideRoot(dropRelay, function() return not alive() or not heldByMe() end)
					if not alive() then return end
					if heldByMe() then

						task.wait(0.4)
						if not alive() then return end
						if heldByMe() then
							pcall(EggCmds.DropFieldEgg, "PlayerRequest")
						end
						local dropUntil = os.clock() + FOREST_DROP_SETTLE
						while alive() and heldByMe() and os.clock() < dropUntil do
							RunService.Heartbeat:Wait()
						end
					end
					local rec2 = record()
					if rec2 and rec2.State == AreaEggs.States.Dropped then released = true break end
					if not heldByMe() then break end
				end
				if not alive() then return end
				if not released then
					if self._instantReturnToken == token then self._instantReturnToken = nil end
					self._forestDropInProgress = nil
					-- [Gp4q PATCH] masih memegang egg & gagal drop -> jangan lepas
					-- tanpa jejak; tandai untuk dijemput ulang di siklus berikut.
					if heldByMe() then self.tweenRecoveryUid = uid end
					self:_finish("Drop thất bại — retrying")
					return
				end

				local dropPos
				local syncUntil = os.clock() + 3
				while alive() and os.clock() < syncUntil do
					local r = record()
					if r and r.State == AreaEggs.States.Dropped then
						local b = r.BottomCFrame or r.BoundsCFrame
						dropPos = b and b.Position
						if dropPos then break end
					elseif r and r.State ~= AreaEggs.States.Carried then
						break
					end
					task.wait(0.1)
				end
				if not alive() then return end
				self._forestDropInProgress = nil

				self:_setStatus("Reset at safe zone")
				local safeCF = safeCFrame()
				if safeCF then self:_glideRoot(safeCF, function() return not alive() end) end
				if not alive() then return end

				local rgWorker = self:_claimCarryWorker("instant-regrab", uid)
				local regrabCF = dropPos and CFrame.new(dropPos + Vector3.new(0, 3.2, 0)) or dropRelay
				local function gotoEgg()
					self:_glideRoot(regrabCF, function() return not alive() or heldByMe() end)
				end
				local got = false
				if rgWorker then

					self:_setStatus("Re-grabbing dropped egg")
					gotoEgg()
					if not alive() then return end
					got = self:_regrabBurst(rgWorker, uid, 1.4)
					if not alive() then return end
					if heldByMe() then got = true end
					if not got and not heldByMe() and self:_isCarryWorkerCurrent(rgWorker) then

						self:_setStatus("Reset at safe zone")
						local resetSafeCF = safeCFrame()
						if resetSafeCF then self:_glideRoot(resetSafeCF, function() return not alive() end) end
						if not alive() then return end
						self:_setStatus("Resetting on treadmill")
						self:_treadmillReset(function() return not alive() end)
						if not alive() then return end

						self:_setStatus("Back to safe zone")
						local resetSafeCF2 = safeCFrame()
						if resetSafeCF2 then self:_glideRoot(resetSafeCF2, function() return not alive() end) end
						if not alive() then return end
						if self:_isCarryWorkerCurrent(rgWorker) then
							self:_setStatus("Re-grabbing dropped egg")
							gotoEgg()
							if not alive() then return end
							got = self:_regrabBurst(rgWorker, uid, 1.6)
							if not alive() then return end
						end
					end
				end
				if not got and not heldByMe() then
					-- [Gp4q PATCH] dulu egg ditinggal di lapangan dengan state Dropped
					-- dan TIDAK didaftarkan untuk recovery -> hilang dari radar.
					-- Sekarang ditandai supaya _schedule menjemputnya lagi.
					if not banked() then self.tweenRecoveryUid = uid end
					finish(banked() and "Safe return complete" or "Re-grab thất bại — retrying")
					return
				end
			end

			if heldByMe() then
				self:_setStatus("Gliding egg home")
				local safeCF = safeCFrame()
				if safeCF then
					self:_glideRoot(safeCF, function() return not alive() or not heldByMe() end)
				end
			end

			self:_setStatus("Waiting for deposit")
			local depositDeadline = os.clock() + 8
			while alive() and not banked() and os.clock() < depositDeadline do
				local r, h = parts()
				if r and h and not self:_isInSafeArea(r) then
					local cf = self:_resolveSafeCFrame(r)
					if cf then self:_glideRoot(cf, function() return not alive() or banked() end) end
				end
				task.wait(0.2)
			end
			finish(banked() and "Safe return complete" or "Bank not confirmed — retrying")
			end)
	end
	function EggRuntime:_returnToSafe()

		if self.primerUid ~= nil and self.carry.uid == self.primerUid then
			local primerUid = self.carry.uid
			self.stats.lastResult = "Primer not banked"
			self.carry.active = false
			self.carry.uid = nil
			self.carry.generation += 1
			self:_invalidateCarryWorker()
			self.skippedEggs[primerUid] = os.clock() + 30
			pcall(EggCmds.DropFieldEgg, "PlayerRequest")
			if self.instantPhase == "priming" then self:_startPrimerTargetHunt() end
			self:_notify()
			return
		end

		local heldUid = self.carry.uid or (self.activeTarget and self.activeTarget.Uid)
		if heldUid then
			self:_instantReturn(heldUid)
		else
			self:_finish("Carry lost — retrying")
		end
	end
	function EggRuntime:_reportStolen()
		local record = self.activeTarget
		if type(record) ~= "table" or not record.Uid then return end
		if self.reportedUid == record.Uid then return end
		self.reportedUid = record.Uid
		task.delay(1.5, function()
			if self.destroyed then return end
			local field = nil
			pcall(function() field = EggCmds.ReadFieldEgg(record.Uid) end)
			local stillThere = type(field) == "table" and (field.State == AreaEggs.States.Slot
				or field.State == AreaEggs.States.Dropped
				or (field.State == AreaEggs.States.Carried and field.CarrierUserId ~= LocalPlayer.UserId))
			if stillThere then
				self.reportedUid = nil
				self.stats.deliveryFailed = (self.stats.deliveryFailed or 0) + 1
				self.stats.lastResult = "Delivery thất bại — retrying"
				self:_notify()
				if self.enabled and not self.running then self:_schedule() end
				return
			end
			self.stats.delivered = (self.stats.delivered or 0) + 1
			end)
	end
	function EggRuntime:_startWatchdog()
		if self.watchdogRunning then return end
		self.watchdogRunning = true
		task.spawn(function()
			local lastKey, keySince, idleSince = nil, os.clock(), nil
			while sessionAlive() and not self.destroyed and self.userStealEnabled do
				task.wait(2)
				if not self.enabled then
					lastKey, idleSince = nil, nil
				elseif self.running then
					idleSince = nil
					local key = tostring(self.activeTarget and self.activeTarget.Uid) .. "|" .. tostring(self.carry.active)
					if key ~= lastKey then
						lastKey, keySince = key, os.clock()
					elseif os.clock() - keySince > 25 then
						lastKey = nil
						self.stats.watchdogResets = (self.stats.watchdogResets or 0) + 1
						pcall(function() self:_invalidateCarryWorker() end)
						self:_finish("Stuck — retrying")
					end
				else
					lastKey = nil
					local okTarget, target = pcall(self._chooseTarget, self)
					if self:_wallOpen() and okTarget and target ~= nil then
						idleSince = idleSince or os.clock()
						if os.clock() - idleSince > 4 then
							idleSince = nil
							self.stats.watchdogResets = (self.stats.watchdogResets or 0) + 1

							self:_schedule()
						end
					else
						idleSince = nil
					end
				end
			end
			self.watchdogRunning = false
			end)
	end
	function EggRuntime:_finish(result)

		self:_hideTreadmillDecoy()
		self._forestDropInProgress = nil
		self._instantReturnToken = nil
		self:_invalidateCarryWorker()
		self.planGeneration += 1
		self:_cancelTween(result, self.enabled)
		self:_setStatus(self.enabled and "Searching" or "Idle")
		if self.enabled then
			task.delay(NEXT_TARGET_HANDOFF_SECONDS, function()
				if self.destroyed or not self.enabled then

					return
				end
				self:_reconcileRunningState()
				end)
		end
	end
	function EggRuntime:_scheduleMovementRetry()
		if self.movementRetryPending or self.destroyed or not self.enabled then
			return
		end
		self.movementRetryPending = true
		task.delay(0.2, function()
			self.movementRetryPending = false
			if not self.destroyed and self.enabled then
				self:_schedule()
			end
			end)
	end
	function EggRuntime:_schedule()
		if not self.running then
			self.safeStarting = false
		end
		if self.destroyed or not self.enabled or self.running then
			return
		end
		local character = LocalPlayer.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then

			self:_setStatus("Character unavailable")
			return
		end
		self:_startMovementProtection()
		if self.carry.active and self.carry.uid ~= nil then
			if self.instantPhase == "priming" and self.carry.uid == self.primerUid then
				return
			end
			local carried = self.records[self.carry.uid] or EggCmds.ReadFieldEgg(self.carry.uid)
			local wanted = type(carried) == "table" and self:_matchesNormalFilter(carried)
			if type(carried) == "table" and not wanted then
				self:_setStatus("Dropping unwanted egg")
				self.skippedEggs[self.carry.uid] = os.clock() + 30
				pcall(EggCmds.DropFieldEgg, "PlayerRequest")
				task.delay(0.5, function()
					if not self.destroyed and self.enabled then self:_schedule() end
					end)
				return
			end
			self:_returnToSafe()
			return
		end
		if not self:_wallOpen() then

			self:_setStatus("Waiting for reset wall")
			return
		end
		local recoveryUid = self.tweenRecoveryUid
		local record = recoveryUid and (EggCmds.ReadFieldEgg(recoveryUid) or self.records[recoveryUid]) or nil
		if recoveryUid and (type(record) ~= "table"
			or (record.State ~= AreaEggs.States.Slot and record.State ~= AreaEggs.States.Dropped))
		then
			self.tweenRecoveryUid = nil
			recoveryUid = nil
			record = nil
		end
		if not record then record = self:_chooseTarget() end
		if not record then
			if self.stats.matching == 0 and self.stats.available > 0 and (self.config.minWeightKg or 0) > 0 then
				self:_setStatus(string.format("No eggs ≥ %dKg", self.config.minWeightKg))
			else
				self:_setStatus("No matching eggs")
			end

			if not self.activeTween and self:_isInField(root) and not self:_isInSafeArea(root) then
				local safeDestination = self:_resolveSafeCFrame(root)
				if safeDestination then
					self:_tweenRoot(safeDestination, nil, nil, {
						silent = true,
						flightProfile = true,
						abort = function() return not self.enabled or self.running end,
						})
				end
			end
			return
		end
		local planGeneration = self.planGeneration

		self.safeStarting = true
		self.running = true
		self.activeTarget = record
		local info = self.catalog.resolve(record)
		self.stats.lastTarget = string.format("%s · %s · %s", info.rarity, info.name, record.AreaId)
		if recoveryUid then
			self.safeStarting = false
			self.stats.lastResult = "Recovering with tween"
			local destination = self:_resolveEggDestination(record, root, humanoid)
			if not destination then
				self.tweenRecoveryUid = nil
				self:_finish("Recovery destination unavailable")
				return
			end
			self:_setStatus("Returning to egg")
			self:_tweenRoot(destination, function()
				if self.tweenRecoveryUid == record.Uid then
					self:_requestCarry(record, false)
				end
				end, nil, {
					holdAfterArrival = true,
					holdUid = record.Uid,
					flightProfile = true,
					carryTarget = record,
				})
			return
		end

		if not self:_leftTreadmill(root) then
			self.running = false
			self.safeStarting = false
			self.activeTarget = nil

			self:_setStatus("Leaving treadmill")
			task.delay(0.3, function()
				if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
					self:_schedule()
				end
				end)
			return
		end

		local _safeDelta = root.Position - SAFE_ZONE_POSITION
		local _safeDistXZ = Vector2.new(_safeDelta.X, _safeDelta.Z).Magnitude

		if _safeDistXZ > 15 and os.clock() - (self.lastSafeRepositionAt or 0) > 30 then
			local safeDestination = self:_resolveSafeCFrame(root)
			if safeDestination then
				self.safeStarting = true
				self.running = true
				self.lastSafeRepositionAt = os.clock()
				self:_setStatus("Repositioning to safe area")
				self:_tweenRoot(safeDestination, function()
					self:_groundSnap()
					self.safeStarting = false
					self.running = false
					task.delay(0.15, function()
						if not self.destroyed and self.enabled and self.planGeneration == planGeneration then
							self:_schedule()
						end
						end)
					end, nil, {
						flightProfile = true,
					})
				return
			end
		end
		self.safeStarting = false
		-- FIX: SkipBait = langsung steal tanpa bait guard (anti "stuck di Forest").
		-- Bait guard rapuh: kalau guard tidak kena bait -> "Guard bait timeout" ->
		-- cycle gagal terus. Sekarang default: LANGSUNG ambil telur.
		local primer = (Settings.SkipBait ~= true) and self:_choosePrimerEgg(record.Uid) or nil
		if not primer then
			-- FIX: dulu di sini NUNGGU TERUS ("Waiting for Forest primer") ->
			-- cycle pertama sering nyangkut. Sekarang: kalau tidak ada telur
			-- Forest, LANGSUNG steal biasa (tanpa bait guard).
			self.stats.lastResult = "No Forest primer — direct steal"
			self.safeStarting = true
			self.running = true
			self.activeTarget = record
			local directDest = self:_resolveEggDestination(record, root, humanoid)
			if not directDest then
				self.running = false
				self.activeTarget = nil
				self:_finish("Destination unavailable")
				return
			end
			self:_setStatus("Traveling to target")
			self:_tweenRoot(directDest, function()
				if self.destroyed or not self.enabled then return end
				if self.activeTarget and self.activeTarget.Uid == record.Uid then
					self:_requestCarry(record, false)
				end
				end, nil, {
				holdAfterArrival = true,
				holdUid = record.Uid,
				flightProfile = true,
				carryTarget = record,
			})
			return
		end
		self.instantPhase = "priming"
		self.primerUid = primer.Uid
		self.skippedEggs[primer.Uid] = os.clock() + 8
		self.targetUid = record.Uid
		self.activeTarget = primer

		self:_showTreadmillDecoy()
		self:_installGuardHitDistanceBoost()
		self.stats.lastResult = "Instant priming"

		self.lowFpsPrime = currentFps() < 30
		local primerDest = self:_resolveEggDestination(primer, root, humanoid)
		if not primerDest then
			self:_finish("Primer destination unavailable")
			return
		end
		if self.lowFpsPrime then
			self:_setStatus("Gliding to Forest primer (low FPS)")
			self:_tweenRoot(primerDest, function()
				if self.instantPhase == "priming" and self.primerUid == primer.Uid then
					self:_requestCarry(primer, false)
				end
				end, nil, {
					holdAfterArrival = true,
					holdUid = primer.Uid,
					flightProfile = true,
					carryTarget = primer,
				})
			return
		end
		self:_setStatus("Teleporting to Forest primer")
		if not self:_teleportRoot(root, humanoid, primerDest) then
			self:_finish("Teleport primer thất bại")
			return
		end
		self:_setArrivalHold(primerDest, primer.Uid)
		self:_requestCarry(primer, true)
	end

	function EggRuntime:_leftTreadmill(root)
		local treadmill = Remotes.Treadmill
		if not treadmill then return true end
		local ok, ids = pcall(function() return treadmill.AskRenderSnapshot:InvokeServer() end)
		if ok and type(ids) == "table" and not table.find(ids, LocalPlayer.UserId) then
			return true
		end
		pcall(function() treadmill.AskDoff:InvokeServer() end)
		if root and root.Anchored then root.Anchored = false end
		return false
	end
	function EggRuntime:_reconcileRunningState()
		local shouldRun = self.userStealEnabled == true
		if self.enabled == shouldRun then
			if self.enabled then
				self:_refreshCounts()
				self:_schedule()
			end
			return
		end
		self.enabled = shouldRun
		if self.enabled then
			if LocalPlayer.Character then
				applyKillPartIgnore(LocalPlayer.Character)
				startHealthPinner(self, LocalPlayer.Character)
			end
			self:_installGuardHitDistanceBoost()
			self:_startMovementProtection()
			self:_setStatus("Searching")
			self:_schedule()
		else
			self.planGeneration += 1
			self.carry.generation += 1
			self:_cleanupInstantSteal()
			self:_removeGuardHitDistanceBoost()
			self:_invalidateCarryWorker()
			self._forestDropInProgress = nil
			self._instantReturnToken = nil
			self.carry.active = false
			self.carry.uid = nil
			self.tweenRecoveryUid = nil

			self.safeStarting = false
			self.movementRetryPending = false
			self:_cancelTween("Disabled")
			self:_restoreTreadmillVisualAtSafe()

			self:_stopMovementProtection()
			stopHealthPinner(self)
			self.activeTarget = nil
			self.running = false
			self:_setStatus("Idle")
		end
		self:_refreshCounts()
	end
	function EggRuntime:setEnabled(value)
		self.userStealEnabled = value == true
		self:_reconcileRunningState()
		if self.userStealEnabled then self:_startWatchdog() end
	end
	function EggRuntime:_resolveWeightKg(record)
		local util = self.weightUtil
		if not util or not record or not record.AssetScale or not record.AssetCategory then
			return nil
		end
		local ok, kg = pcall(util.WeightKgForScale, record.AssetCategory, record.AssetScale)
		if ok and type(kg) == "number" then
			return kg
		end
		return nil
	end
	resolveEggRate = function(record)
		if type(record) ~= "table" then return nil end
		local category = record.Category or record.AssetCategory
		local scale = tonumber(record.Scale or record.AssetScale)
		if type(category) ~= "string" or not scale or scale <= 0 then return nil end
		local mutations = type(record.Mutations) == "table" and table.clone(record.Mutations) or {}
		local item = {
			Category = category,
			Scale = scale,
			Mutations = mutations,
			BaseMutation = type(record.BaseMutation) == "string" and record.BaseMutation or nil,
		}
		local ok, rate = pcall(AssetEarnings.MutationOnlyRatePerSecond, item)
		return ok and type(rate) == "number" and rate or nil
	end
	function EggRuntime:setMinWeightKg(value)
		local num = tonumber(value) or 0
		self.config.minWeightKg = math.max(num, 0)
	end
	function EggRuntime:setMinValuePerSec(value)
		local num = tonumber(value) or 0
		self.config.minValuePerSec = math.max(num, 0)
		self:_refreshCounts()
		self:_schedule()
	end
	function EggRuntime:setSpeed(value)
		local inputSpeed = math.clamp(
			math.floor((tonumber(value) or DEFAULT_MOVEMENT_SPEED_INPUT) + 0.5),
			MIN_MOVEMENT_SPEED_INPUT,
			MAX_MOVEMENT_SPEED_INPUT
		)
		self.config.speed = inputSpeed * MOVEMENT_SPEED_MULTIPLIER
		if self.enabled or self.activeTween then
			self:_startMovementProtection()
		end
		return inputSpeed
	end
	function EggRuntime:setFilterEnabled(filter, value)
		self.config[filter .. "Enabled"] = value == true
		self:_refreshCounts()
		self:_schedule()
	end
	function EggRuntime:setFilter(filter, values)
		local normalized = type(values) == "table" and table.clone(values) or {}
		if filter == "mutations" and type(self.catalog.resolveMutationId) == "function" then
			local ids = {}
			for _, value in ipairs(normalized) do
				local id = self.catalog.resolveMutationId(value)
				if id then table.insert(ids, id) end
			end
			normalized = ids
		end
		self.config[filter] = normalized
		self:_refreshCounts()
		self:_schedule()
	end
	function EggRuntime:destroy()
		if self.destroyed then
			return
		end
		self.destroyed = true
		self.enabled = false
		self:_hideTreadmillDecoy()
		self.planGeneration += 1
		self.carry.generation += 1
		self:_invalidateCarryWorker()
		self.carry.active = false
		self.carry.uid = nil
		self.tweenRecoveryUid = nil
		self.safeStarting = false
		self:_cancelTween("Destroyed")
		self:_cleanupInstantSteal()
		self:_removeGuardHitDistanceBoost()

		self:_stopMovementProtection()
		if self._healthPinner then
			pcall(self._healthPinner.Disconnect, self._healthPinner)
			self._healthPinner = nil
		end
		if self._healthChangedConnection then
			pcall(self._healthChangedConnection.Disconnect, self._healthChangedConnection)
			self._healthChangedConnection = nil
		end
		restoreHumanoid(LocalPlayer.Character)
		disconnectAll(self.connections)
		table.clear(self.listeners)
		table.clear(self.records)

	end
	return EggRuntime
	end)()

local runtime = EggRuntime.new(catalog)
local controller = { Settings = Settings }
function controller.Start()
    assert(alive, "[LogicTP] Sudah Destroy; jalankan ulang file")
    runtime:setEnabled(false)
    Config.StealHoldSeconds = math.clamp(tonumber(Settings.Delay) or 0, 0, 20)
    runtime:setSpeed(Settings.Speed)
    runtime:setMinWeightKg(Settings.MinWeight)
    runtime:setMinValuePerSec(Settings.MinValue)
    for _, filter in ipairs({
        { "names", "name", Settings.Names },
        { "rarities", "rarity", Settings.Rarities },
        { "areas", "area", Settings.Areas },
        { "mutations", "mutation", Settings.Mutations },
    }) do
        local values = type(filter[3]) == "table" and filter[3] or {}
        runtime:setFilter(filter[1], values)
        runtime:setFilterEnabled(filter[2], #values > 0)
    end
    Settings.Enabled = true
    runtime:setEnabled(true)
end
function controller.Stop()
    if not alive then return end
    Settings.Enabled = false
    runtime:setEnabled(false)
end
function controller.Status()
    return runtime:getSnapshot()
end

-- terapkan setting UI secara LANGSUNG (tanpa restart farm)
function controller.Apply()
    Config.StealHoldSeconds = math.clamp(tonumber(Settings.Delay) or 0, 0, 20)
    runtime:setSpeed(Settings.Speed)
    runtime:setMinWeightKg(Settings.MinWeight)
    runtime:setMinValuePerSec(Settings.MinValue)
    for _, filter in ipairs({
        { "names", "name", Settings.Names },
        { "rarities", "rarity", Settings.Rarities },
        { "areas", "area", Settings.Areas },
        { "mutations", "mutation", Settings.Mutations },
    }) do
        local values = type(filter[3]) == "table" and filter[3] or {}
        runtime:setFilter(filter[1], values)
        runtime:setFilterEnabled(filter[2], #values > 0)
    end
end
function controller.Destroy()
    if not alive then return end
    alive = false
    Settings.Enabled = false
    runtime:destroy()
    fpsConnection:Disconnect()
    if env.LogicTP == controller then env.LogicTP = nil end
end
function controller.GetActiveTarget()
    local t = runtime.activeTarget
    if type(t) ~= "table" then return nil end
    return {
        Uid          = t.Uid,
        Category     = t.AssetCategory,
        Scale        = t.AssetScale,
        Mutations    = t.Mutations,
        BaseMutation = t.BaseMutation,
        AreaId       = t.AreaId,
        State        = t.State,
        CFrame       = t.BottomCFrame,
    }
end

function controller.GetHoldSeconds()
    return math.clamp(tonumber(Config.StealHoldSeconds) or 0, 0, 20)
end

env.LogicTP = controller
if Settings.Enabled then controller.Start() end
return controller
end


--=============================================================
-- BOOT ENGINE
--=============================================================
local LogicTP
do
	local ok, res = pcall(buildLogicTP)
	if ok and type(res) == "table" then
		LogicTP = res
	else
		warn("[!Gp4q Hub] engine gagal dimuat: " .. tostring(res))
	end
end
if not LogicTP then
	LogicTP = {
		Settings = { Enabled=false, Delay=0, Speed=60, Names={}, Rarities={}, Areas={}, Mutations={}, MinValue=0, MinWeight=0, SkipBait=false },
		Start=function() end, Stop=function() end, Destroy=function() end,
		Status=function() return {} end, GetActiveTarget=function() return nil end,
		Apply=function() end,
	}
end
local Settings = LogicTP.Settings
Settings.Delay = 0
Settings.Speed = 250
Settings.SkipBait = false
local function applyLive()
    pcall(function()
        if LogicTP and LogicTP.Apply then LogicTP.Apply() end
    end)
end
    -- WIND UI
    -- ============================================================-- ==================================================
    -- UI - Airflow (blue theme)
    -- ============================================================
    local success, loaded = pcall(function()
        return loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"
        ))()
    end)
    if not success or not loaded then warn("[Nhat Khanh Hub] Không tải được thư viện giao diện"); return end
    Airflow = loaded

    -- ============================================================
    -- THEME PRESETS  (Airflow cuma punya 1 theme bawaan -> kita bikin sendiri)
    -- ============================================================
    HUB.Themes = {
        NhatKhanh = {
            Background  = Color3.fromRGB(7, 10, 22),
            Surface     = Color3.fromRGB(13, 18, 38),
            Surface2    = Color3.fromRGB(20, 29, 58),
            Surface3    = Color3.fromRGB(32, 47, 88),
            Stroke      = Color3.fromRGB(48, 74, 132),
            StrokeHover = Color3.fromRGB(122, 92, 255),
            Accent      = Color3.fromRGB(64, 220, 255),
            AccentDark  = Color3.fromRGB(8, 20, 42),
            Text        = Color3.fromRGB(238, 248, 255),
            Muted       = Color3.fromRGB(142, 166, 205),
            Success     = Color3.fromRGB(90, 245, 180),
            Warning     = Color3.fromRGB(255, 195, 90),
            Error       = Color3.fromRGB(255, 95, 135),
        },
        Gold = {
            Background  = Color3.fromRGB(18, 14, 6),
            Surface     = Color3.fromRGB(28, 22, 10),
            Surface2    = Color3.fromRGB(38, 30, 14),
            Surface3    = Color3.fromRGB(58, 45, 20),
            Stroke      = Color3.fromRGB(74, 58, 26),
            StrokeHover = Color3.fromRGB(190, 150, 60),
            Accent      = Color3.fromRGB(255, 196, 66),
            AccentDark  = Color3.fromRGB(30, 22, 8),
            Text        = Color3.fromRGB(255, 246, 224),
            Muted       = Color3.fromRGB(170, 150, 108),
            Success     = Color3.fromRGB(170, 226, 130),
            Warning     = Color3.fromRGB(255, 176, 72),
            Error       = Color3.fromRGB(248, 122, 108),
        },
        Blue = {
            Background  = Color3.fromRGB(10, 14, 24),
            Surface     = Color3.fromRGB(16, 22, 36),
            Surface2    = Color3.fromRGB(20, 27, 44),
            Surface3    = Color3.fromRGB(34, 45, 68),
            Stroke      = Color3.fromRGB(44, 58, 86),
            StrokeHover = Color3.fromRGB(80, 120, 180),
            Accent      = Color3.fromRGB(90, 160, 255),
            AccentDark  = Color3.fromRGB(10, 16, 28),
            Text        = Color3.fromRGB(235, 242, 255),
            Muted       = Color3.fromRGB(130, 148, 178),
            Success     = Color3.fromRGB(150, 220, 170),
            Warning     = Color3.fromRGB(240, 176, 108),
            Error       = Color3.fromRGB(240, 120, 120),
        },
        Purple = {
            Background  = Color3.fromRGB(18, 12, 26),
            Surface     = Color3.fromRGB(26, 18, 38),
            Surface2    = Color3.fromRGB(34, 24, 50),
            Surface3    = Color3.fromRGB(52, 36, 76),
            Stroke      = Color3.fromRGB(64, 46, 92),
            StrokeHover = Color3.fromRGB(150, 110, 220),
            Accent      = Color3.fromRGB(178, 130, 255),
            AccentDark  = Color3.fromRGB(22, 14, 32),
            Text        = Color3.fromRGB(242, 236, 255),
            Muted       = Color3.fromRGB(152, 132, 186),
            Success     = Color3.fromRGB(150, 220, 190),
            Warning     = Color3.fromRGB(240, 176, 108),
            Error       = Color3.fromRGB(240, 120, 140),
        },
        Emerald = {
            Background  = Color3.fromRGB(8, 18, 14),
            Surface     = Color3.fromRGB(13, 28, 22),
            Surface2    = Color3.fromRGB(18, 38, 30),
            Surface3    = Color3.fromRGB(28, 58, 46),
            Stroke      = Color3.fromRGB(36, 74, 58),
            StrokeHover = Color3.fromRGB(70, 180, 130),
            Accent      = Color3.fromRGB(80, 220, 150),
            AccentDark  = Color3.fromRGB(10, 22, 17),
            Text        = Color3.fromRGB(230, 250, 240),
            Muted       = Color3.fromRGB(120, 168, 146),
            Success     = Color3.fromRGB(120, 240, 170),
            Warning     = Color3.fromRGB(240, 190, 110),
            Error       = Color3.fromRGB(240, 120, 120),
        },
        Crimson = {
            Background  = Color3.fromRGB(20, 10, 12),
            Surface     = Color3.fromRGB(30, 15, 18),
            Surface2    = Color3.fromRGB(42, 20, 24),
            Surface3    = Color3.fromRGB(64, 30, 36),
            Stroke      = Color3.fromRGB(84, 38, 44),
            StrokeHover = Color3.fromRGB(210, 90, 100),
            Accent      = Color3.fromRGB(248, 100, 110),
            AccentDark  = Color3.fromRGB(26, 12, 15),
            Text        = Color3.fromRGB(255, 238, 240),
            Muted       = Color3.fromRGB(180, 130, 138),
            Success     = Color3.fromRGB(160, 220, 170),
            Warning     = Color3.fromRGB(250, 180, 100),
            Error       = Color3.fromRGB(255, 110, 110),
        },
    }
    HUB.ThemeOrder = { "NhatKhanh", "Gold", "Blue", "Purple", "Emerald", "Crimson" }
    HUB.ThemeName = "NhatKhanh"

    HUB.ApplyTheme = function(name)
        local t = HUB.Themes[name] or HUB.Themes.NhatKhanh
        for k, v in pairs(t) do
            pcall(function() Airflow.Theme[k] = v end)
        end
        HUB.ThemeName = name
        pcall(function()
            if writefile then writefile("Ascend_Theme.txt", tostring(name)) end
        end)
    end

    -- muat theme tersimpan (default Gold)
    pcall(function()
        if readfile and isfile and isfile("Ascend_Theme.txt") then
            local saved = readfile("Ascend_Theme.txt")
            if saved and HUB.Themes[saved:gsub("%s", "")] then
                HUB.ThemeName = saved:gsub("%s", "")
            end
        end
    end)

    HUB.ApplyTheme(HUB.ThemeName)
Window = Airflow:CreateWindow({
    Name             = "Nhat Khanh Hub",
    LoadingSubtitle  = "Giao diện 3D • Bản tiếng Việt",
    Icon             = LOGO_ID,
    ToggleUIKeybind  = "F3",
    Size             = UDim2.fromOffset(520, 390),
    MinSize          = Vector2.new(420, 320),
    KeepOnScreen     = true,
    MaxNotifications = 4,
    OpenButton       = { Title = "Nhat Khanh Hub", Icon = LOGO_ID },
    Loading          = {
        Enabled  = true,
        Title    = "Nhat Khanh Hub",
        Text     = "Đang khởi động",
        Duration = 1.2,
    },
    -- ★ tab Home bawaan Airflow: avatar, DisplayName, executor,
    --   FPS / Ping / Executor / Game / Region / Time
    Home             = {
        Name       = "Trang chủ",
        Icon       = "house",
        SectionName = "Thông tin hệ thống",
        Stats      = { "FPS", "Ping", "Executor", "Game", "Region", "Time" },
    },
    -- ★ auto-save config ke file (folder & nama file)
    ConfigurationSaving = {
        Enabled    = true,
        FolderName = "NhatKhanhHub",
        FileName   = "default",
    },
})

Notify = function(title, text, dur)
    pcall(function()
        Airflow:Notify({ Title = title, Content = tostring(text), Duration = dur or 3 })
    end)
end

-- ---------- TABS ----------
local FarmTab   = Window:Tab({ Name = "Cày cuốc",      Icon = "egg"           })
local BaseTab   = Window:Tab({ Name = "Căn cứ",      Icon = "house"         })
local StoreTab  = Window:Tab({ Name = "Cửa hàng",     Icon = "shopping-cart" })
local PlayerTab = Window:Tab({ Name = "Nhân vật",    Icon = "user"          })
local PredTab   = Window:Tab({ Name = "Dự đoán", Icon = "activity"      })
local MiscTab   = Window:Tab({ Name = "Khác",      Icon = "wrench"        })
local ConfigTab = Window:Tab({ Name = "Cài đặt",    Icon = "settings"      })

-- ==========================================================
-- CONFIG  (pakai ConfigManager bawaan Airflow)
-- ==========================================================
ConfigTab:ConfigManager({
    Name = "Cấu hình",
})

-- ★ AUTO LOAD: Airflow cuma auto-SAVE. Ini menambah auto-load config
--   terakhir saat script dijalankan (file "Ascend_LastConfig.json").
ConfigTab:Toggle({
    Name = "Tự tải cấu hình",
    Desc = "Tự động tải cấu hình lần trước khi chạy script",
    CurrentValue = true,
    Flag = "Config/Auto Load",
    Callback = function(v) HUB._autoLoadCfg = v end,
})
ConfigTab:Button({
    Name = "Tải cấu hình lần trước",
    Desc = "Tải cấu hình đã dùng ở lần chạy trước",
    Callback = function()
        task.spawn(function()
            local name = nil
            pcall(function()
                if readfile and isfile and isfile("Ascend_LastConfig.json") then
                    local d = game:GetService("HttpService"):JSONDecode(readfile("Ascend_LastConfig.json"))
                    if type(d) == "table" and type(d.Name) == "string" then name = d.Name end
                end
            end)
            if not name then
                Notify("Config", "No previous config found")
                return
            end
            local ok, err = Window:LoadConfig(name)
            Notify("Config", ok and ("Đã tải xong: " .. name) or ("Failed: " .. tostring(err)))
        end)
    end,
})

-- simpan nama config terakhir tiap kali user ganti / save
HUB._rememberConfig = function(name)
    if type(name) ~= "string" or name == "" then return end
    HUB._lastCfg = name
    pcall(function()
        if writefile then
            writefile("Ascend_LastConfig.json",
                game:GetService("HttpService"):JSONEncode({ Name = name }))
        end
    end)
end

-- simpan nama config aktif secara berkala (ConfigManager tidak expose event)
task.spawn(function()
    local lastSeen = nil
    while not HUB.dead do
        task.wait(3)
        local nm = Window and Window.ConfigName
        if type(nm) == "string" and nm ~= "" and nm ~= lastSeen then
            lastSeen = nm
            HUB._rememberConfig(nm)
        end
    end
end)

-- AUTO LOAD saat start (delay supaya UI + modul siap)
task.spawn(function()
    task.wait(2.5)
    if HUB._autoLoadCfg == false then return end
    local name = nil
    pcall(function()
        if readfile and isfile and isfile("Ascend_LastConfig.json") then
            local d = game:GetService("HttpService"):JSONDecode(readfile("Ascend_LastConfig.json"))
            if type(d) == "table" and type(d.Name) == "string" then name = d.Name end
        end
    end)
    if not name then return end
    local ok = pcall(function() return Window:LoadConfig(name) end)
    if ok then
        print("[CONFIG] auto-load: " .. name)
        pcall(function() Airflow:Notify({ Title = "Cài đặt", Content = "Auto-loaded: " .. name, Duration = 3 }) end)
    end
end)

local function rarityValues()
    local t = { "All" }
    for _, v in ipairs(RARITY_NAMES) do t[#t + 1] = v end
    return t
end

-- Multi-select helper: "All" (or empty) = no filter
local function applyMultiFilter(target, v)
    table.clear(target)
    if type(v) == "table" then
        for _, o in ipairs(v) do
            if o ~= "All" then target[o] = true end
        end
    elseif type(v) == "string" and v ~= "All" then
        target[v] = true
    end
end

-- ==========================================================
local AREA_LIST = {
	"Forest","Desert","Snow","Lake","Jungle","Volcano","Prehistoric",
	"Cosmic","Abyss Ocean","Cherry Blossom","Light Dark","Titan Temple",
}
local RARITY_LIST = {
	"Common","Uncommon","Rare","Epic","Legendary","Mythic",
	"Cosmic","Secret","Eternal","Divine",
}

local function buildEggList()
	local labels, cat = {}, {}
	pcall(function()
		local Assets = require(ReplicatedStorage.Data.Assets)
		local dir = Assets and Assets.Directory
		local eggs = {}
		if type(dir) == "table" then
			for key, cfg in pairs(dir) do
				local r = type(cfg) == "table" and cfg.Rarity or nil
				local num = type(r) == "table" and tonumber(r.RarityNumber or r.Rank) or nil
				if num then
					table.insert(eggs, {
						Category = tostring(key), Name = tostring(cfg.DisplayName or key),
						Rarity = num, RarityName = tostring(r.DisplayName or r._id or num),
					})
				end
			end
		end
		table.sort(eggs, function(a, b)
			if a.Rarity ~= b.Rarity then return a.Rarity > b.Rarity end
			return a.Name < b.Name
		end)
		for _, e in ipairs(eggs) do
			local label = string.format("%s [%s]", e.Name, e.RarityName)
			if cat[label] then label = label .. " (" .. e.Category .. ")" end
			labels[#labels + 1] = label
			cat[label] = e.Category
		end
	end)
	if #labels == 0 then labels = { "(no data)" } end
	return labels, cat
end

local EGG_LABELS, EGG_CATEGORY = buildEggList()

local function applyMulti(target, v)
	table.clear(target)
	if type(v) == "table" then
		for _, o in ipairs(v) do
			if type(o) == "string" and o ~= "All" then target[o] = true end
		end
	elseif type(v) == "string" and v ~= "All" then
		target[v] = true
	end
end

--=============================================================
-- TAB: FARM
--=============================================================
-- FIX: dulu di sini bikin tab "Farm" KEDUA (Window:Tab lagi) padahal
-- FarmTab (tab Farm kosong dari gp4q lama) sudah dibuat di atas.
-- Airflow auto-pilih tab PERTAMA -> yang tampil tab Farm KOSONG,
-- jadi UI farm dari "New farm.txt" tidak pernah kelihatan.
-- Sekarang pakai FarmTab yang sama -> isinya langsung masuk ke tab Farm.
local T = FarmTab

T:Section("Tự động trộm trứng")
T:Toggle({ Name = "Tự động trộm trứng", Flag = "Farm/Auto Steal",
	Desc = "Di chuyển đến trứng phù hợp, tiếp cận, nhặt trứng rồi quay về vùng an toàn",
	CurrentValue = false,
	Callback = function(v)
		if v then
			pcall(function() LogicTP.Start() end)
			Notify("Tự động trộm trứng", "ĐÃ BẬT")
		else
			pcall(function() LogicTP.Stop() end)
			Notify("Tự động trộm trứng", "ĐÃ TẮT")
		end
	end })

T:Slider({ Name = "Tốc độ", Flag = "Farm/Speed",
	Desc = "Tốc độ di chuyển",
	Min = 20, Max = 1000, CurrentValue = 250, Increment = 5,
	Callback = function(v) Settings.Speed = v; applyLive() end })

T:Toggle({ Name = "Bỏ mồi nhử ở Rừng", Flag = "Farm/Skip Forest Bait",
	Desc = "Tắt = dùng mồi nhử lính gác ở Rừng. Bật = lấy trứng trực tiếp; có thể bị lính gác cản trở",
	CurrentValue = false,
	Callback = function(v)
		Settings.SkipBait = (v == true)
		Notify("Farm", Settings.SkipBait and "Skip bait ON (langsung steal)" or "Bait guard ON")
	end })

T:Section("Chọn mục tiêu")
T:Dropdown({ Name = "Khu vực mục tiêu", Flag = "Farm/Target Areas",
	Desc = "Chỉ lấy trứng ở khu vực đã chọn (để trống = tất cả)",
	Options = AREA_LIST, CurrentOption = {}, MultipleOptions = true,
	Callback = function(v) applyMulti(Settings.Areas, v); applyLive() end })

T:Dropdown({ Name = "Độ hiếm mục tiêu", Flag = "Farm/Target Rarities",
	Desc = "Chỉ lấy trứng thuộc độ hiếm đã chọn (để trống = tất cả)",
	Options = RARITY_LIST, CurrentOption = {}, MultipleOptions = true,
	Callback = function(v) applyMulti(Settings.Rarities, v); applyLive() end })

T:Dropdown({ Name = "Chọn loại trứng cụ thể", Flag = "Farm/Target Eggs",
	Desc = "Hanya curi telur ini (kosong = semua)",
	Options = EGG_LABELS, CurrentOption = {}, MultipleOptions = true,
	Callback = function(v)
		table.clear(Settings.Names)
		if type(v) == "table" then
			for _, lbl in ipairs(v) do
				local cat = EGG_CATEGORY[lbl]
				if cat then Settings.Names[#Settings.Names + 1] = cat end
			end
		end
		applyLive()
	end })

T:Dropdown({ Name = "Đột biến mục tiêu", Flag = "Farm/Target Mutations",
	Desc = "Hanya curi telur dengan mutasi ini (kosong = semua)",
	Options = {}, CurrentOption = {}, MultipleOptions = true,
	Callback = function(v) applyMulti(Settings.Mutations, v); applyLive() end })

T:Slider({ Name = "Giá trị tối thiểu (K/giây)", Flag = "Farm/Min Value",
	Desc = "Skip telur di bawah income ini (0 = off)",
	Min = 0, Max = 1000, CurrentValue = 0, Increment = 10,
	Callback = function(v) Settings.MinValue = (tonumber(v) or 0) * 1000; applyLive() end })

T:Slider({ Name = "Khối lượng tối thiểu (kg)", Flag = "Farm/Min Weight",
	Desc = "Skip telur di bawah berat ini (0 = off)",
	Min = 0, Max = 10000, CurrentValue = 0, Increment = 50,
	Callback = function(v) Settings.MinWeight = math.max(0, tonumber(v) or 0); applyLive() end })

T:Section("Trạng thái")
local statusPara = T:Paragraph({ Title = "Trực tiếp", Desc = "Đang chờ" })
task.spawn(function()
	while true do
		task.wait(0.5)
		pcall(function()
			local snap = LogicTP.Status and LogicTP.Status() or {}
			statusPara:Set(table.concat({
				"status: " .. tostring(snap.status),
				"running: " .. tostring(snap.running) .. "   enabled: " .. tostring(snap.enabled),
				"telur cocok: " .. tostring(snap.matching or 0) .. " / tersedia: " .. tostring(snap.available or 0),
				"target: " .. tostring(snap.lastTarget) .. " - " .. tostring(snap.lastResult),
			}, "\n"))
		end)
	end
end)

T:Section("Thao tác")
T:Button({ Name = "Sửa nhân vật", Desc = "Nhấn nút này nếu chức năng tự động trộm trứng không di chuyển",
	Callback = function()
		task.spawn(function()
			pcall(function() LogicTP.Stop() end)
			task.wait(0.3)
			local ch = LP.Character
			if ch then
				for _, v in ipairs(ch:GetDescendants()) do
					if v:IsA("Motor6D") and not v.Enabled then v.Enabled = true end
				end
				local h = ch:FindFirstChildOfClass("Humanoid")
				if h then
					h.PlatformStand = false
					h.AutoRotate = true
					if h:GetState() ~= Enum.HumanoidStateType.Running then
						h:ChangeState(Enum.HumanoidStateType.Running)
					end
				end
			end
			Notify("Fix", "Humanoid dibetulkan")
		end)
	end })
T:Button({ Name = "Dừng", Callback = function() pcall(function() LogicTP.Stop() end) end })
T:Button({ Name = "Làm mới danh sách trứng", Callback = function()
	task.spawn(function()
		EGG_LABELS, EGG_CATEGORY = buildEggList()
		Notify("Trứng", "Đã tải " .. #EGG_LABELS .. " loại trứng")
	end)
end })
-- ==========================================================
-- BASE
-- ==========================================================
BaseTab:Section("Đặt trứng")
BaseTab:Toggle({ Name = "Tự đặt trứng", Flag = "Base/Auto Place Eggs", CurrentValue = false,
    Callback = function(v) S.autoPlantEnabled = v end })
BaseTab:Dropdown({
    Name = "Độ hiếm được đặt", Flag = "Base/Place Rarities",
    Desc = "Các độ hiếm được phép đặt (để trống = tất cả)",
    Options = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v) applyMultiFilter(S.placeRarities, v) end,
})

BaseTab:Section("Ấp trứng")
BaseTab:Toggle({ Name = "Tự động ấp trứng", Flag = "Base/Auto Hatch Eggs", CurrentValue = false,
    Callback = function(v) S.autoHatchEnabled = v end })

BaseTab:Section("Ghép pet")
BaseTab:Toggle({ Name = "Tự động ghép pet", Flag = "Base/Auto Fuse Pets", CurrentValue = false,
    Callback = function(v) S.autoFusePets = v; Notify("Fuse", v and "ON" or "OFF") end })
BaseTab:Toggle({ Name = "Chỉ ghép pet đã chọn", Flag = "Base/Fuse Selected Only",
    Desc = "Chỉ ghép những pet nằm trong danh sách cho phép",
    CurrentValue = false,
    Callback = function(v) S.fuseSelectedOnly = v end })
BaseTab:Dropdown({
    Name = "Độ hiếm được ghép", Flag = "Base/Fuse Rarities",
    Desc = "Allowed rarities to fuse (empty = all)",
    Options = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v) applyMultiFilter(S.fuseRarities, v) end,
})
BaseTab:Button({ Name = "Ghép một lần",
    Callback = function()
        task.spawn(function()
            if not next(S.fuseRarities) and not S.fuseSelectedOnly then
                Notify("Fuse", "Set Fuse Rarities first (safety)"); return
            end
            local ok, msg = AutoFusePets()
            Notify("Fuse", ok and "Đã ghép pet!" or tostring(msg or "failed"))
        end)
    end })

BaseTab:Section("Nâng cấp tiến trình")
BaseTab:Toggle({ Name = "Tự nâng cấp căn cứ", Flag = "Base/Auto Upgrade Base", CurrentValue = false,
    Callback = function(v) S.autoUpgradeBase = v end })
BaseTab:Toggle({ Name = "Tự nâng cấp máy chạy", Flag = "Base/Auto Upgrade Treadmill", CurrentValue = false,
    Callback = function(v) S.autoUpgradeTreadmill = v end })
BaseTab:Toggle({ Name = "Tự nhận thưởng", Flag = "Base/Auto Claim Rewards", CurrentValue = false,
    Callback = function(v) S.autoClaimRewards = v end })
BaseTab:Toggle({ Name = "Tự trang bị pet mạnh nhất", Flag = "Base/Auto Equip Best Pets", CurrentValue = false,
    Callback = function(v) S.autoEquipBestPets = v end })

BaseTab:Section("Yêu thích")
BaseTab:Toggle({ Name = "Tự đánh dấu pet yêu thích", Flag = "Base/Auto Favorite Pets", CurrentValue = false,
    Callback = function(v) S.autoFavoritePets = v end })
BaseTab:Dropdown({
    Name = "Độ hiếm yêu thích", Flag = "Base/Favorite Rarities",
    Options = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v) applyMultiFilter(S.favRarities, v) end,
})

BaseTab:Section("Chạy một lần")
BaseTab:Button({ Name = "Đặt trứng ngay",
    Callback = function()
        task.spawn(function()
            local n = PlantAllCarriedEggsInPen()
            Notify("Place", "Planted " .. tostring(n) .. " eggs")
        end)
    end })
BaseTab:Button({ Name = "Ấp tất cả ngay",
    Callback = function()
        task.spawn(function()
            local n = HatchAllReadyEggs()
            Notify("Hatch", "Hatched " .. tostring(n) .. " eggs")
        end)
    end })
BaseTab:Button({ Name = "Nhận thưởng ngay",
    Callback = function() pcall(ClaimAllAvailableRewards); Notify("Rewards", "Đã nhận thưởng") end })
BaseTab:Button({ Name = "Nâng cấp căn cứ ngay",
    Callback = function() pcall(UpgradeHomesteadBase); Notify("Base", "Đã nâng cấp") end })
BaseTab:Button({ Name = "Nâng cấp máy chạy ngay",
    Callback = function() pcall(UpgradeTreadmillTier); Notify("Treadmill", "Đã nâng cấp") end })
BaseTab:Button({ Name = "Đánh dấu pet yêu thích ngay",
    Callback = function()
        task.spawn(function()
            local n = AutoFavoritePets()
            Notify("Favorite", "Favorited " .. tostring(n))
        end)
    end })

-- ==========================================================
-- STORE
-- ==========================================================
StoreTab:Section("Thú cưng")
StoreTab:Toggle({ Name = "Tự động bán pet", Flag = "Store/Auto Sell Pets", CurrentValue = false,
    Callback = function(v) S.autoSellPets = v end })
StoreTab:Dropdown({
    Name = "Độ hiếm pet được bán", Flag = "Store/Sell Pet Rarities",
    Desc = "Các độ hiếm được phép bán (để trống = tất cả)",
    Options = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v) applyMultiFilter(S.selectedSellPetRarities, v) end,
})
StoreTab:Button({ Name = "Bán pet ngay",
    Callback = function() task.spawn(function() pcall(SellSelectedPets); Notify("Sell", "Hoàn tất") end) end })

StoreTab:Section("Trứng")
StoreTab:Toggle({ Name = "Tự động bán trứng", Flag = "Store/Auto Sell Eggs", CurrentValue = false,
    Callback = function(v) S.autoSellEggs = v end })
StoreTab:Dropdown({
    Name = "Độ hiếm trứng được bán", Flag = "Store/Sell Egg Rarities",
    Desc = "Các độ hiếm được phép bán (để trống = tất cả)",
    Options = rarityValues(),
    CurrentOption = {},
    MultipleOptions = true,
    Callback = function(v) applyMultiFilter(S.selectedSellEggRarities, v) end,
})
StoreTab:Button({ Name = "Bán trứng ngay",
    Callback = function() task.spawn(function() pcall(SellSelectedEggs); Notify("Sell", "Hoàn tất") end) end })

-- ==========================================================
-- ==========================================================
-- PLAYER
-- ==========================================================
PlayerTab:Section("Chiến đấu")
PlayerTab:Toggle({ Name = "Chống bẫy", Flag = "Player/Anti Trap", Desc = "Tắt vùng va chạm của bẫy đối phương",
    CurrentValue = false,
    Callback = function(v)
        S.avoidTrapsEnabled = v
        ApplyAntiTrap(v)
        Notify("Anti Trap", v and "ON" or "OFF")
    end })
PlayerTab:Toggle({ Name = "Vung gậy tự động quanh người", Flag = "Player/Bat Aura", Desc = "Tự vung gậy khi có người chơi ở gần",
    CurrentValue = false,
    Callback = function(v) S.batAuraEnabled = v end })
PlayerTab:Slider({ Name = "Bán kính tác động", Flag = "Player/Aura Radius", Min = 5, Max = 60, CurrentValue = 20, Increment = 1,
    Callback = function(v) S.batAuraRadius = v end })
PlayerTab:Slider({ Name = "Độ trễ vung gậy (0,1 giây)", Flag = "Player/Aura Swing Delay (0.1s)", Min = 1, Max = 20, CurrentValue = 2, Increment = 1,
    Callback = function(v) S.batAuraDelay = v / 10 end })
PlayerTab:Button({ Name = "Vung gậy ngay",
    Callback = function()
        local re = GetNetRemote("RE/BatSwing/Trigger")
        if re then pcall(function() re:FireServer() end) end
        Notify("Bat", "Đã kích hoạt")
    end })

PlayerTab:Section("Di chuyển")
PlayerTab:Toggle({ Name = "Tốc độ chạy", Flag = "Player/WalkSpeed", CurrentValue = false,
    Callback = function(v)
        S.walkSpeedEnabled = v
        if not v then
            local h = findHum()
            if h and h:IsA("Humanoid") then pcall(function() h.WalkSpeed = 16 end) end
        end
    end })
PlayerTab:Slider({ Name = "Giá trị tốc độ chạy", Flag = "Player/WalkSpeed Value", Min = 16, Max = 500, CurrentValue = 24, Increment = 1,
    Callback = function(v) S.walkSpeedVal = v end })
PlayerTab:Toggle({ Name = "Lực nhảy", Flag = "Player/JumpPower", CurrentValue = false,
    Callback = function(v)
        S.jumpPowerEnabled = v
        if not v then
            local h = findHum()
            if h and h:IsA("Humanoid") then pcall(function() h.JumpPower = 50 end) end
        end
    end })
PlayerTab:Slider({ Name = "Giá trị lực nhảy", Flag = "Player/JumpPower Value", Min = 50, Max = 300, CurrentValue = 60, Increment = 1,
    Callback = function(v) S.jumpPowerValue = v end })
PlayerTab:Toggle({ Name = "Nhảy vô hạn", Flag = "Player/Infinite Jump", Desc = "Giữ phím Space để nhảy liên tục",
    CurrentValue = false, Callback = function(v) S.infiniteJumpEnabled = v end })
PlayerTab:Toggle({ Name = "Bay (WASD)", Flag = "Player/Fly (WASD)", CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        if v then startFly() else stopFly() end
        Notify("Fly", v and "ON" or "OFF")
    end })
PlayerTab:Slider({ Name = "Tốc độ bay", Flag = "Player/Fly Speed", Min = 20, Max = 250, CurrentValue = 60, Increment = 1,
    Callback = function(v) S.flySpeed = v end })

PlayerTab:Section("Tiện ích")
PlayerTab:Toggle({ Name = "Chống bật lùi", Flag = "Player/No Knockback", CurrentValue = true,
    Callback = function(v) pcall(function() SetNoKnockback(v) end) end })
PlayerTab:Toggle({ Name = "Chống AFK", Flag = "Player/Anti AFK", CurrentValue = false,
    Callback = function(v) HUB.SetAntiAFK(v) end })
PlayerTab:Toggle({ Name = "Tăng sáng tối đa", Flag = "Player/Fullbright", CurrentValue = false,
    Callback = function(v) SetFullbright(v) end })
PlayerTab:Dropdown({ Name = "Dịch chuyển đến khu vực", Flag = "Player/Teleport To Area", Options = areaKeys, CurrentOption = "Forest",
    Callback = function(v) selectedAreaTp = v end })
PlayerTab:Button({ Name = "Đi đến khu vực",
    Callback = function()
        local pos = AREA_COORDINATES[selectedAreaTp]
        if pos then
            Notify("Travel", "Traveling to " .. selectedAreaTp)
            task.spawn(function() MoveToPoint(pos, TRAVEL_SPEED) end)
        end
    end })

PlayerTab:Section("Hiệu năng")
PlayerTab:Slider({ Name = "Giới hạn FPS", Flag = "Player/FPS Cap", Desc = "Executor cần hỗ trợ setfpscap",
    Min = 30, Max = 1000, CurrentValue = 240, Increment = 1,
    Callback = function(v) HUB.SetFpsCap(v) end })
PlayerTab:Toggle({ Name = "Tối ưu đồ họa", Flag = "Player/Optimizer",
    Desc = "Tắt bóng, họa tiết, hạt và đèn (có thể khôi phục)",
    CurrentValue = false,
    Callback = function(v) HUB.OptimizerToggle(v) end })
PlayerTab:Toggle({ Name = "Bảng FPS và Ping", Flag = "Player/FPS + Ping HUD",
    Desc = "Bảng thông số có thể kéo ở góc màn hình",
    CurrentValue = false,
    Callback = function(v) HUB.HudToggle(v) end })
PlayerTab:Slider({ Name = "Kích thước bảng HUD", Flag = "Player/HUD Scale", Min = 60, Max = 160, CurrentValue = 100, Increment = 5, Unit = "%",
    Callback = function(v) HUB.HudSetSize(v) end })
PlayerTab:Toggle({ Name = "Giảm hiệu ứng bản đồ", Flag = "Player/Reduce Map",
    Desc = "Tắt bóng và hiệu ứng hạt; lính gác và trứng được giữ nguyên",
    CurrentValue = false,
    Callback = function(v)
        S.reduceMap = v
        HUB.ApplyReduceMap(v)
    end })
PlayerTab:Toggle({ Name = "Ẩn pet", Flag = "Player/Hide Pets",
    Desc = "Ẩn mô hình pet trong khu đất của bạn", CurrentValue = false,
    Callback = function(v)
        hideAllPets = v
        if v then HUB.ApplyHideAllPets(true) else HUB.RestoreCache(_savedPets) end
    end })
PlayerTab:Toggle({ Name = "Ẩn trứng đã đặt", Flag = "Player/Hide Placed Eggs", CurrentValue = false,
    Callback = function(v)
        hideAllEggs = v
        if v then
            for _, c in ipairs(Workspace:GetChildren()) do
                if c.Name == "PlacedEggRenders" then HUB.HideDescendants(c, _savedEggs) end
            end
        else
            HUB.RestoreCache(_savedEggs)
        end
    end })
PlayerTab:Toggle({ Name = "Ẩn đồ trang trí khu đất", Flag = "Player/Hide Plot Decor", CurrentValue = false,
    Callback = function(v)
        hidePlotVisuals = v
        if v then
            local plots = Workspace:FindFirstChild("Plots")
            if plots then HUB.HideDescendants(plots, _savedPlot) end
        else
            HUB.RestoreCache(_savedPlot)
        end
    end })
PlayerTab:Button({ Name = "Xóa hình hiển thị pet",
    Callback = function()
        local n = DeleteOwnPetRenders()
        Notify("FPS", "Removed " .. tostring(n) .. " models")
    end })

-- ==========================================================
-- PREDICTOR  (panel GUI mandiri - bisa digeser & di-resize)
-- ==========================================================
PredTab:Section("Bảng dự đoán")
PredTab:Paragraph({ Title = "Bảng thông tin trực tiếp",
    Desc = "Bảng riêng có hình trứng. Có thể kéo bằng thanh tiêu đề và đổi kích thước ở góc dưới bên phải." })
PredTab:Button({ Name = "Mở bảng",
    Callback = function() HUB.Predictor.Overlay.Show() end })
PredTab:Button({ Name = "Ẩn bảng",
    Callback = function() HUB.Predictor.Overlay.Hide() end })
PredTab:Dropdown({
    Name = "Tab của bảng", Flag = "Pred/Panel Tab",
    Options = { "Khe nứt", "Trứng", "Ghép pet" },
    CurrentOption = "Khe nứt",
    Callback = function(v) HUB.Predictor.Overlay.SetTab(({ ["Khe nứt"]="Rift", ["Trứng"]="Eggs", ["Ghép pet"]="Fuse" })[tostring(v)] or "Rift") end,
})
PredTab:Button({ Name = "Làm mới ngay",
    Callback = function() HUB.Predictor.Overlay.Refresh() end })

PredTab:Section("Thiết lập")
PredTab:Toggle({ Name = "Tự làm mới (5 giây)", Flag = "Pred/Auto Refresh (5s)",
    Desc = "Làm mới bảng mỗi 5 giây khi bảng đang mở",
    CurrentValue = false,
    Callback = function(v) HUB._predAuto = v end })
PredTab:Toggle({ Name = "Mở bảng khi khởi chạy", Flag = "Pred/Open Panel On Load", CurrentValue = false,
    Callback = function(v) HUB._predOnLoad = v end })
track(task.spawn(function()
    while not HUB.dead do
        task.wait(5)
        if HUB._predAuto and HUB.Predictor.Overlay.IsOpen() then pcall(HUB.Predictor.Overlay.Refresh) end
    end
end))

-- ==========================================================
-- MISC
-- ==========================================================
MiscTab:Section("ESP trứng")
MiscTab:Toggle({ Name = "ESP trứng", Flag = "Misc/Egg ESP", Desc = "Nhãn trứng nhiều thông tin với màu chuyển sắc theo độ hiếm",
    CurrentValue = false,
    Callback = function(v) if v then HUB.ESP.EggsOn() else HUB.ESP.EggsOff() end end })
MiscTab:Dropdown({
    Name = "Thông tin trứng", Flag = "Misc/Egg Info",
    Desc = "Chọn thông tin hiển thị trên mỗi nhãn",
    Options = { "Biểu tượng", "Tên", "Độ hiếm", "Đột biến", "Giá trị", "Khối lượng", "Kích thước", "Giá bán", "Khoảng cách", "Khu vực", "Trạng thái" },
    CurrentOption = { "Biểu tượng", "Tên", "Độ hiếm", "Đột biến", "Giá trị" },
    MultipleOptions = true,
    Callback = function(v)
        local set = {}
        local keyMap = { ["Biểu tượng"]="Icon", ["Tên"]="Name", ["Độ hiếm"]="Rarity", ["Đột biến"]="Mutation", ["Giá trị"]="Value", ["Khối lượng"]="Weight", ["Kích thước"]="Size", ["Giá bán"]="Sell Price", ["Khoảng cách"]="Distance", ["Khu vực"]="Area", ["Trạng thái"]="State" }
        if type(v) == "table" then for _, label in ipairs(v) do local k = keyMap[label]; if k then set[k] = true end end end
        for k in pairs(HUB.ESP.Info) do HUB.ESP.Info[k] = nil end
        HUB.ESP.Info.Icon = set.Icon == true
        HUB.ESP.Info.Name = set.Name == true
        HUB.ESP.Info.Rarity = set.Rarity == true
        HUB.ESP.Info.Mutation = set.Mutation == true
        HUB.ESP.Info.Value = set.Value == true
        HUB.ESP.Info.Weight = set.Weight == true
        HUB.ESP.Info.Size = set.Size == true
        HUB.ESP.Info["Sell Price"] = set["Sell Price"] == true
        HUB.ESP.Info.Distance = set.Distance == true
        HUB.ESP.Info.Area = set.Area == true
        HUB.ESP.Info.State = set.State == true
        HUB.ESP.Relayout()
    end,
})
MiscTab:Dropdown({
    Name = "Độ hiếm tối thiểu", Flag = "Misc/Min Rarity",
    Desc = "Hiện độ hiếm này trở lên (Bất kỳ = tất cả)",
    Options = (function()
        local t = { "Any" }
        for _, r in ipairs(RARITY_NAMES) do t[#t + 1] = r end
        return t
    end)(),
    CurrentOption = "Any",
    Callback = function(v)
        HUB.ESP.MinRarity = (v == "Any") and 0 or (RARITY_SCORE_MAP[tostring(v)] or 0)
    end,
})
MiscTab:Slider({ Name = "Giá trị tối thiểu (K/giây)", Flag = "Misc/Min Value (K/s)", Desc = "Chỉ hiện trứng có thu nhập cao hơn mức này",
    Min = 0, Max = 1000000, CurrentValue = 0, Increment = 1000,
    Callback = function(v) HUB.ESP.MinValue = math.max(0, tonumber(v) or 0) end })
MiscTab:Dropdown({ Name = "Chế độ tô sáng", Flag = "Misc/Highlight Mode", Options = { "Tắt", "Chỉ loại hiếm", "Tất cả mục đang hiện" },
    CurrentOption = "Tắt",
    Callback = function(v) HUB.ESP.Highlight = ({ ["Tắt"]="Off", ["Chỉ loại hiếm"]="Rare Only", ["Tất cả mục đang hiện"]="All Shown" })[tostring(v)] or "Off" end })
MiscTab:Toggle({ Name = "Hiện trứng ở căn cứ của tôi", Flag = "Misc/Show Own Base Eggs", CurrentValue = true,
    Callback = function(v) HUB.ESP.OwnBase = (v ~= false) end })
MiscTab:Slider({ Name = "Kích thước nhãn trứng", Flag = "Misc/Egg Tag Size", Min = 50, Max = 200, CurrentValue = 75, Increment = 5, Unit = "%",
    Callback = function(v) HUB.ESP.SetSizeScale(v) end })

MiscTab:Section("ESP lính gác")
MiscTab:Toggle({ Name = "ESP lính gác", Flag = "Misc/Guard ESP", Desc = "Hiện trạng thái lính gác (ngủ / thức / đuổi theo bạn)",
    CurrentValue = false,
    Callback = function(v) if v then HUB.ESP.GuardsOn() else HUB.ESP.GuardsOff() end end })
MiscTab:Slider({ Name = "Kích thước nhãn lính gác", Flag = "Misc/Guard Tag Size", Min = 50, Max = 200, CurrentValue = 75, Increment = 5, Unit = "%",
    Callback = function(v) HUB.ESP.SetGuardSize(v) end })

MiscTab:Section("ESP người chơi")
MiscTab:Toggle({ Name = "ESP người chơi", Flag = "Misc/Player ESP", CurrentValue = false,
    Callback = function(v) if v then HUB.ESP.PlayersOn() else HUB.ESP.PlayersOff() end end })
MiscTab:Dropdown({
    Name = "Thông tin người chơi", Flag = "Misc/Player Info",
    Options = { "Tên tài khoản", "Vật phẩm đang cầm" },
    CurrentOption = { "Vật phẩm đang cầm" },
    MultipleOptions = true,
    Callback = function(v)
        local set = {}
        if type(v) == "table" then for _, label in ipairs(v) do
            if label == "Tên tài khoản" then set.Username = true elseif label == "Vật phẩm đang cầm" then set.Tool = true end
        end end
        HUB.ESP.PlayerInfo = { Username = set.Username == true, Tool = set.Tool == true }
    end,
})

MiscTab:Section("ESP vật phẩm thất lạc")
MiscTab:Toggle({ Name = "ESP vật phẩm thất lạc", Flag = "Misc/Lost Parts ESP", Desc = "Bánh răng cơ khí và dây điện",
    CurrentValue = false,
    Callback = function(v) if v then HUB.ESP.LostOn() else HUB.ESP.LostOff() end end })

MiscTab:Section("Máy chủ")
MiscTab:Dropdown({ Name = "Kiểu đổi máy chủ", Flag = "Misc/Server Hop Mode",
    Options = { "Ít người chơi nhất", "Nhiều người chơi nhất", "Ngẫu nhiên" },
    CurrentOption = "Ít người chơi nhất",
    Callback = function(v) HUB.SetHopMode(({ ["Ít người chơi nhất"]="Least Players", ["Nhiều người chơi nhất"]="Most Players", ["Ngẫu nhiên"]="Random" })[tostring(v)] or "Least Players") end })
MiscTab:Button({ Name = "Đổi máy chủ",
    Callback = function()
        task.spawn(function()
            local tries = 0
            while tries < 40 do
                tries = tries + 1
                local r = HUB.ServerHop()
                if r == "waiting" then
                    if tries % 10 == 0 then
                        Notify("Server Hop", string.format("Tất cả máy chủ đều đầy, đã thử %d lần...", tries), 3)
                    end
                    task.wait(0.4)
                elseif r == "empty" then
                    Notify("Đổi máy chủ", "Không tìm thấy máy chủ còn chỗ, hãy thử lại sau.", 3)
                    break
                else
                    break
                end
            end
        end)
    end })

MiscTab:Section("Giao diện")
MiscTab:Dropdown({
    Name = "Chủ đề giao diện", Flag = "Misc/UI Theme",
    Desc = "Đổi màu giao diện (cần chạy lại để áp dụng toàn bộ)",
    Options = HUB.ThemeOrder,
    CurrentOption = HUB.ThemeName,
    Callback = function(v)
        HUB.ApplyTheme(tostring(v))
        Notify("Giao diện", "Chủ đề: " .. tostring(v) .. "  (chạy lại script để áp dụng đầy đủ)")
    end,
})

MiscTab:Section("Script")
MiscTab:Button({ Name = "Tắt script", Icon = "power",
    Callback = function() if HUB.Unload then pcall(HUB.Unload) end end })



-- ============================================================
-- END
-- ============================================================
print("[Nhat Khanh Hub] Đã tải xong!")
