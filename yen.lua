--[=[
    ████████╗██╗    ██╗ ██████╗     ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗
    ╚══██╔══╝██║    ██║██╔═══██╗    ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝
       ██║   ██║ █╗ ██║██║   ██║    ███████╗██║     ██████╔╝██║██████╔╝   ██║
       ██║   ██║███╗██║██║   ██║    ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║
       ██║   ╚███╔███╔╝╚██████╔╝    ███████║╚██████╗██║  ██║██║██║        ██║
       ╚═╝    ╚══╝╚══╝  ╚═════╝     ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝

    TwoK Script Hub — Pixel Lineage [🎃Spear Class + Dragon Race]
    PlaceId 126256942507957 • Single-file (TwoKUI Cyber-Neon inline)

    Everything below talks to the game through the exact payloads its own
    client sends (PlatformBattles.Remotes.RPGCommand / RPGState), read from
    the decompiled RPGClient, PixelQTE, RunMapView and Shared.DefenseTiming.
]=]

pcall(function()
    local setIdent = setthreadidentity or setthreadcontext or (syn and syn.set_thread_identity)
    if setIdent then setIdent(7) end
end)

-- ── 0. TEARDOWN ───────────────────────────────────────────────────────────────
local genv = (getgenv and getgenv()) or _G
pcall(function()
    if _G.TwoKPixelLineageCleanUp then _G.TwoKPixelLineageCleanUp() end
end)

local myToken = tick()
_G.TwoKPixelLineageActiveToken = myToken
_G.TwoKPixelLineageRunning = true
local function alive()
    return _G.TwoKPixelLineageRunning and _G.TwoKPixelLineageActiveToken == myToken
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
pcall(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
end)
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

local function cleanPrevGui()
    for _, con in ipairs({ CoreGui, LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") }) do
        if con then
            for _, child in ipairs(con:GetChildren()) do
                if child.Name == "TwoK_UI_Screen" or child.Name == "TwoK_PixelLineage_Screen"
                    or child.Name == "TwoK_Pyramid_Float" or child.Name == "TwoKPixel_Float" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end
cleanPrevGui()

local _conns = {}
local function track(c)
    _conns[#_conns + 1] = c
    return c
end

-- Original module functions live in genv so a re-run wraps the game's real
-- function, never the previous run's wrapper.
genv.__TwoKPL_Orig = genv.__TwoKPL_Orig or {}
local ORIG = genv.__TwoKPL_Orig
local patched = {}
local function patch(mod, key, tag, make)
    if type(mod) ~= "table" or type(rawget(mod, key)) ~= "function" then return end
    local id = tag .. "." .. key
    ORIG[id] = ORIG[id] or rawget(mod, key)
    mod[key] = make(ORIG[id])
    patched[#patched + 1] = { mod = mod, key = key, id = id }
end

_G.TwoKPixelLineageCleanUp = function()
    _G.TwoKPixelLineageRunning = false
    for _, c in ipairs(_conns) do pcall(function() c:Disconnect() end) end
    table.clear(_conns)
    for _, p in ipairs(patched) do
        pcall(function() p.mod[p.key] = ORIG[p.id] end)
    end
    table.clear(patched)
end

pcall(function()
    local vu = game:GetService("VirtualUser")
    track(LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end))
end)

pcall(function()
    local qot = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
    -- Queue a retrying launcher. Executors may resolve readfile paths relative
    -- to a different working directory after Teleport, and the game can take
    -- longer than three seconds to restore ReplicatedStorage.
    if qot and genv.__TwoKPL_Queued ~= game.JobId then
        genv.__TwoKPL_Queued = game.JobId
        qot([[
            task.spawn(function()
                pcall(function()
                    if not game:IsLoaded() then game.Loaded:Wait() end
                end)
                local env = (getgenv and getgenv()) or _G
                local paths = {
                    "TwoK_PixelLineage_Hub.luau",
                    "C:/Users/Administrator/Downloads/TwoK_PixelLineage_Hub.luau",
                    "C:\\Users\\Administrator\\Downloads\\TwoK_PixelLineage_Hub.luau",
                }
                if type(env.TwoKPixelLineagePath) == "string" and env.TwoKPixelLineagePath ~= "" then
                    table.insert(paths, 1, env.TwoKPixelLineagePath)
                end
                for attempt = 1, 30 do
                    if game.PlaceId ~= 126256942507957 then return end
                    for _, path in ipairs(paths) do
                        if type(path) == "string" and path ~= "" and readfile and isfile and isfile(path) and loadstring then
                            local ok = pcall(function() loadstring(readfile(path))() end)
                            if ok then return end
                        end
                    end
                    task.wait(1)
                end
                warn("[TwoK] queued launch could not find TwoK_PixelLineage_Hub.luau")
            end)
        ]])
    end
end)

-- ── 1. GAME HANDLES ───────────────────────────────────────────────────────────
local pb = ReplicatedStorage:WaitForChild("PlatformBattles", 15)
local remotes = pb and pb:WaitForChild("Remotes", 15)
local RPGCommand = remotes and remotes:WaitForChild("RPGCommand", 15)
local RPGState = remotes and remotes:WaitForChild("RPGState", 15)
local ProfileRequest = remotes and remotes:WaitForChild("ProfileRequest", 15)
local Shared = pb and pb:WaitForChild("Shared", 15)
local function platformBattlesClient()
    local scripts = LocalPlayer:WaitForChild("PlayerScripts", 30)
    return scripts and scripts:WaitForChild("PlatformBattlesClient", 30)
end

local function safeRequire(inst)
    if not inst then return nil end
    local ok, m = pcall(require, inst)
    return ok and m or nil
end
local RunConfig = safeRequire(Shared and Shared:WaitForChild("RunConfig", 10))
local RunModifiers = safeRequire(Shared and Shared:WaitForChild("RunModifiers", 10))
local DefenseTiming = safeRequire(Shared and Shared:WaitForChild("DefenseTiming", 10))
local actCount = math.max(1, RunConfig and type(RunConfig.Acts) == "table" and #RunConfig.Acts or 1)
local TORMENT_MAX = math.max(1, tonumber(RunConfig and RunConfig.Torment and RunConfig.Torment.OpenTiers) or 99)
local RunLobbyState
local _gameConfig, _potionStock
local function gameConfig()
    if _gameConfig then return _gameConfig end
    _gameConfig = safeRequire(Shared and Shared:FindFirstChild("GameConfig"))
    return _gameConfig
end
local function potionStock()
    if _potionStock then return _potionStock end
    _potionStock = safeRequire(Shared and Shared:FindFirstChild("PotionStock"))
    return _potionStock
end

local function cmd(name, payload)
    if not RPGCommand then return false end
    return pcall(RPGCommand.FireServer, RPGCommand, name, payload)
end

local function serverNow()
    local ok, t = pcall(Workspace.GetServerTimeNow, Workspace)
    return ok and t or os.clock()
end

-- Sleeps coarsely, then finishes on Heartbeat so a send lands within a frame
-- of the requested server time.
local function waitServer(t)
    local d = t - serverNow()
    if d > 0.05 then task.wait(d - 0.04) end
    while alive() and serverNow() < t do RunService.Heartbeat:Wait() end
end

-- ── 2. CONFIG (persisted) ─────────────────────────────────────────────────────
local Config = {
    Farm = false,
    Difficulty = "normal",
    TormentTier = 1,
    StartAct = 1,
    Modifier = "none",
    EndAction = "replay",
    EndDelay = 1.5,
    AutoVote = true,
    PathMode = "balanced",
    AutoEvents = true,
    Watchdog = true,
    StopOnLifeLoss = true,

    AutoDodge = true,
    AutoMinigame = true,
    AutoBattle = true,
    AutoSkill = true,
    SkillList = {},
    EnemySkillSequence = {},
    BossSkillSequence = {},
    AutoEnemySkill = true,
    AutoBossSkill = true,
    KnownSkills = {},
    TargetMode = "lowest",
    BraceGuard = true,
    AutoHeal = true,
    HealPct = 45,
    LifeGuard = true,
    LifeGuardPct = 30,
    ActDelay = 0.35,
    DelayMode = "Legit",

    AutoJoin = false,
    AutoCodes = true,
    AutoSlot = false,
    Slot = 1,

    AutoStats = false,
    StatBuild = "balanced",
    AutoPotionBuy = true,
    PotionKeep = 9,
    AutoClimb = true,

    WalkSpeedOn = false,
    WalkSpeed = 32,
    JumpOn = false,
    JumpPower = 75,
    Noclip = false,
}

local UI = {}
local CFG_ROOT = "2KScript_PixelLineage"
local CFG_ACCOUNT = tostring(LocalPlayer and LocalPlayer.UserId or "default")
local CFG_DIR = CFG_ROOT .. "/Accounts/" .. CFG_ACCOUNT
local LEGACY_CFG_DIR = CFG_ROOT
local function ensureConfigFolders()
    if not (makefolder and isfolder) then return end
    for _, folder in ipairs({ CFG_ROOT, CFG_ROOT .. "/Accounts", CFG_DIR }) do
        if not isfolder(folder) then pcall(makefolder, folder) end
    end
end

local saveQueued = false
local function queueSave()
    -- Configs are saved only through the explicit Config controls.
end
local function setFlag(k, v)
    Config[k] = v
    queueSave()
end

local function cleanConfigName(name)
    name = tostring(name or ""):gsub("[^%w _%-]", ""):sub(1, 40)
    return name ~= "" and name or nil
end
local function configSavePath(name)
    name = cleanConfigName(name)
    return name and (CFG_DIR .. "/" .. name .. ".json") or nil
end
local function configPath(name)
    name = cleanConfigName(name)
    if not name then return nil end
    return CFG_DIR .. "/" .. name .. ".json"
end
local function autoLoadMarkerPath()
    return CFG_DIR .. "/autoload.txt"
end
local function readAutoLoadName()
    if not (isfile and readfile) then return nil end
    local path = autoLoadMarkerPath()
    if isfile(path) then
        local ok, value = pcall(readfile, path)
        return ok and cleanConfigName(value) or nil
    end
    return nil
end
local function migrateLegacyAutoLoad()
    if not (isfile and readfile and writefile) or isfile(autoLoadMarkerPath()) then return nil end
    local legacyMarker = LEGACY_CFG_DIR .. "/autoload.txt"
    if not isfile(legacyMarker) then return nil end
    local okName, rawName = pcall(readfile, legacyMarker)
    local name = okName and cleanConfigName(rawName) or nil
    local legacyPath = name and (LEGACY_CFG_DIR .. "/" .. name .. ".json") or nil
    if not (name and legacyPath and isfile(legacyPath)) then return nil end
    local okData, data = pcall(readfile, legacyPath)
    if not okData then return nil end
    ensureConfigFolders()
    local copied = pcall(writefile, configSavePath(name), data)
    local marked = copied and pcall(writefile, autoLoadMarkerPath(), name)
    if copied and marked then
        pcall(delfile, legacyMarker)
        return name
    end
    return nil
end
local function configNames()
    local out = {}
    local seen = {}
    pcall(function()
        if listfiles and isfolder and isfolder(CFG_DIR) then
            for _, file in ipairs(listfiles(CFG_DIR) or {}) do
                local name = tostring(file):match("([^\\/]+)%.json$")
                if name and not seen[name] then
                    seen[name] = true
                    out[#out + 1] = name
                end
            end
        end
    end)
    table.sort(out)
    return out
end
local function saveConfig(name)
    local path = configSavePath(name)
    if not path or not writefile then print("[TwoK Config] Enter a valid config name"); return end
    local ok = pcall(function()
        ensureConfigFolders()
        writefile(path, HttpService:JSONEncode(Config))
        print("[TwoK Config] Saved " .. tostring(name))
    end)
    if not ok then print("[TwoK Config] Save failed") end
end
local function loadConfig(name)
    local path = configPath(name)
    if not (path and isfile and isfile(path)) then print("[TwoK Config] Config not found"); return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if ok and type(data) == "table" then
        for k, v in pairs(data) do if Config[k] ~= nil and type(v) == type(Config[k]) then Config[k] = v end end
        print("[TwoK Config] Loaded " .. tostring(name))
        if UI and UI.applyConfig then pcall(UI.applyConfig) end
        return true
    end
    return false
end
-- Load the account's named config before any startup workers or one-shot
-- actions run. The UI applies the same config again after its controls exist.
local earlyAutoLoadName = migrateLegacyAutoLoad() or readAutoLoadName()
if earlyAutoLoadName then
    pcall(loadConfig, earlyAutoLoadName)
end

-- totals live in a file: the game hops servers between floors and every hop
-- re-injects the hub, which would otherwise zero the counters each time
local STATS_FILE = CFG_DIR .. "/stats.json"
local STAT_KEYS = { "dodges", "minigames", "actions", "runs", "wins", "fightsWon", "fightsLost", "floors", "seconds" }
local Stats = { startedAt = os.clock() }
for _, k in ipairs(STAT_KEYS) do Stats[k] = 0 end
pcall(function()
    if not (isfile and readfile and isfile(STATS_FILE)) then return end
    local data = HttpService:JSONDecode(readfile(STATS_FILE))
    for _, k in ipairs(STAT_KEYS) do
        if type(data[k]) == "number" then Stats[k] = data[k] end
    end
end)
local secondsBase = Stats.seconds
local function saveStats()
    if not writefile then return end
    pcall(function()
        ensureConfigFolders()
        Stats.seconds = secondsBase + (os.clock() - Stats.startedAt)
        local out = {}
        for _, k in ipairs(STAT_KEYS) do out[k] = Stats[k] end
        writefile(STATS_FILE, HttpService:JSONEncode(out))
    end)
end
local function resetStats()
    for _, k in ipairs(STAT_KEYS) do Stats[k] = 0 end
    secondsBase, Stats.startedAt = 0, os.clock()
    saveStats()
end
local function notify(title, content, dur)
    if UI.notify then pcall(UI.notify, title, content, dur) end
end

-- ── 3. RPG CONTROLLER (for closing the QTE overlay cleanly) ───────────────────
local _ctrl, _ctrlScanAt = nil, -1e9
local function rpgController()
    if _ctrl then return _ctrl end
    if os.clock() - _ctrlScanAt < 5 then return nil end
    _ctrlScanAt = os.clock()
    if not (RPGState and getconnections and debug and debug.getupvalues) then return nil end
    pcall(function()
        for _, c in ipairs(getconnections(RPGState.OnClientEvent)) do
            local fn = c.Function
            if fn then
                local seen = {}
                local function walk(f, depth)
                    if _ctrl or depth > 4 or seen[f] then return end
                    seen[f] = true
                    for _, v in ipairs(debug.getupvalues(f)) do
                        if type(v) == "table" and rawget(v, "warriorBladeTiming") then
                            _ctrl = v
                            return
                        elseif type(v) == "function" then
                            walk(v, depth + 1)
                        end
                    end
                end
                walk(fn, 1)
                if _ctrl then return end
            end
        end
    end)
    return _ctrl
end

-- The game's own minigame UI submits a MISS the moment its needle runs out,
-- and the server keeps the first result it gets. So the UI is shut as soon as
-- it opens (whichever client the game routed it to) and only our result goes out.
local function silenceQte(token, text)
    token = tostring(token)
    local deadline = os.clock() + 1.5
    while alive() and os.clock() < deadline do
        local ctrl = rpgController()
        local q = ctrl and ctrl.pixelQTE
        if q and q.token ~= nil and tostring(q.token) == token then
            pcall(q._close, q, 0.8, text)
            return true
        end
        for _, key in ipairs({ "warriorBladeTiming", "thiefSlash", "mageRhythm" }) do
            local c = ctrl and ctrl[key]
            if type(c) == "table" and c.token ~= nil and tostring(c.token) == token then
                pcall(c.Cancel, c)
                return true
            end
        end
        RunService.Heartbeat:Wait()
    end
    return false
end

-- ── 4. DEFENSE: PERFECT DODGE EVERY HIT ───────────────────────────────────────
-- Server grading (Shared.DefenseTiming.Submit) uses the client's pressedAt,
-- clamped to [receivedAt - min(0.3, 2*latency + 0.08), receivedAt]. Sending a
-- hair after the strike lands with pressedAt = the exact strike time therefore
-- grades as a dead-centre "Dodge" no matter how tight the window has shrunk.
local SEND_LAG = 0.012
local handledTokens = {}

local function markDefense(token, hit, barrage)
    local ctrl = rpgController()
    local q = ctrl and ctrl.pixelQTE
    local d = q and q.defense
    if not (d and tostring(d.token) == tostring(token)) then return end
    if barrage then
        if d.mirror and DefenseTiming and DefenseTiming.BarragePress then
            pcall(DefenseTiming.BarragePress, d.mirror, d.mirror.userId, d.mirror.battleId, d.mirror.token, hit, hit)
        end
    else
        d.pressed = true
        d.frozen = true
    end
end

local function onDefense(data)
    if not Config.AutoDodge then return end
    local startedAt = tonumber(data.startedAt)
    if not startedAt then return end
    local token = data.token
    local key = "def:" .. tostring(token)
    if handledTokens[key] then return end
    handledTokens[key] = true

    if type(data.marks) == "table" and #data.marks > 0 then
        local duration = math.max(0.2, tonumber(data.duration) or 2)
        for _, m in ipairs(data.marks) do
            if not alive() then return end
            local hit = startedAt + math.clamp(tonumber(m) or 0.5, 0, 1) * duration
            waitServer(hit + SEND_LAG)
            cmd("DefenseTimingInput", { battleId = data.battleId, token = token, pressedAt = hit })
            markDefense(token, hit, true)
        end
    else
        local target = tonumber(data.target)
        if not target then return end
        local duration = tonumber(data.duration) or (DefenseTiming and DefenseTiming.Duration) or 0.85
        local hit = startedAt + target * duration
        waitServer(hit + SEND_LAG)
        if not alive() then return end
        cmd("DefenseTimingInput", { battleId = data.battleId, token = token, pressedAt = hit })
        markDefense(token, hit, false)
    end
    Stats.dodges += 1
end

-- ── 5. ATTACK MINIGAMES ──────────────────────────────────────────────────────
-- Match the native client's result timing. Sending at the Started event can
-- race the server's minigame setup and leave the turn without a scored result.
local function sendMinigame(name, payload, delay, token, text)
    task.wait(delay)
    if not (alive() and Config.AutoMinigame) then return end
    if not cmd(name, payload) then return end
    task.spawn(silenceQte, token, text)
    Stats.minigames += 1
end

local function onWarrior(data)
    if not Config.AutoMinigame then return end
    local token = tostring(data.token or "")
    if handledTokens["war:" .. token] then return end
    handledTokens["war:" .. token] = true
    local rounds = {}
    for i, r in ipairs(type(data.rounds) == "table" and data.rounds or {}) do
        if i > 5 or type(r) ~= "table" then break end
        rounds[i] = r
    end
    if #rounds == 0 then rounds[1] = { targetPosition = 0.5, sweepSeconds = 1 } end
    local results = {}
    for i, r in ipairs(rounds) do
        results[i] = { pressed = true, position = math.clamp(tonumber(r.targetPosition) or 0.5, 0, 1) }
    end
    sendMinigame("WarriorBladeTimingResult",
        { battleId = tostring(data.battleId or ""), token = token, results = results },
        3.42, token, "FULL CHAIN!")
end

local function onMage(data)
    if not Config.AutoMinigame or data.preview then return end
    local token = tostring(data.token or "")
    if handledTokens["mag:" .. token] then return end
    handledTokens["mag:" .. token] = true
    local circles = type(data.circles) == "table" and #data.circles or 0
    local hits = math.min(3, circles)
    local circleSeconds = math.clamp(tonumber(data.circleSeconds) or 0.95, 0.65, 1.5)
    sendMinigame("MageRhythmResult",
        { battleId = tostring(data.battleId or ""), token = token, hits = hits },
        math.max(0.35, hits * (circleSeconds * 0.70 + 0.17) + 0.12), token, "PERFECT CAST!")
end

local function onThief(data)
    if not Config.AutoMinigame then return end
    local token = tostring(data.token or "")
    if handledTokens["thf:" .. token] then return end
    handledTokens["thf:" .. token] = true
    local targets = type(data.targets) == "table" and #data.targets or 0
    local maxHits = math.clamp(math.floor(tonumber(data.maximumHits) or targets), 1, 6)
    local hits = math.min(maxHits, targets)
    local targetSeconds = math.clamp(tonumber(data.targetSeconds) or 0.78, 0.55, 1.25)
    sendMinigame("ThiefSlashResult",
        { battleId = tostring(data.battleId or ""), token = token, hits = hits },
        math.max(1.1, hits * targetSeconds * 0.46) + 0.06, token, "FLAWLESS!")
end

-- ── 6. TURN BATTLE AI ─────────────────────────────────────────────────────────
local Battle = { snap = nil, lastUpdate = 0, lastKey = nil, lastAt = 0, status = "-" }

local function lives()
    return tonumber(LocalPlayer:GetAttribute("RPGLives"))
end

local function pctOf(t)
    if type(t) ~= "table" then return nil end
    local hp = tonumber(t.hp or t.health or t.HP)
    local mx = tonumber(t.maxHp or t.maxHP or t.hpMax or t.maxHealth or t.max_hp)
    if hp and mx and mx > 0 then return hp / mx * 100 end
    return nil
end

local function myBattlePct(s)
    for _, p in ipairs(type(s.party) == "table" and s.party or {}) do
        if type(p) == "table" and tonumber(p.userId) == LocalPlayer.UserId then
            return pctOf(p) or pctOf(p.actor)
        end
    end
    return pctOf(s.player) or (type(s.player) == "table" and pctOf(s.player.actor)) or nil
end

local function category(a)
    local v = string.lower(tostring(a.category or a.kind or a.id or ""))
    if v == "meditate" then return "Meditate" end
    if v == "gearscroll" then return "Scroll" end
    if v:find("skill", 1, true) or v:find("spell", 1, true) or v:find("ability", 1, true) then return "Skill" end
    if v:find("item", 1, true) or v:find("bag", 1, true) or v:find("potion", 1, true) then return "Item" end
    if v:find("guard", 1, true) or v:find("defend", 1, true) or v:find("block", 1, true) then return "Guard" end
    if v:find("run", 1, true) or v:find("flee", 1, true) or v:find("escape", 1, true) then return "Run" end
    return "Attack"
end

local function usable(a)
    return type(a) == "table" and a.id ~= nil and a.enabled ~= false
end

local function isHealItem(a)
    local s = string.lower(tostring(a.name or "") .. " " .. tostring(a.id or "") .. " " .. tostring(a.description or ""))
    return s:find("potion", 1, true) or s:find("heal", 1, true) or s:find("elixir", 1, true)
        or s:find("tonic", 1, true) or s:find("restore", 1, true)
end

local function aliveEnemies(s)
    local out = {}
    for i, e in ipairs(type(s.enemies) == "table" and s.enemies or {}) do
        local actor = type(e) == "table" and (e.actor or e) or nil
        if actor and (tonumber(actor.hp) or 1) > 0 then
            out[#out + 1] = { index = tonumber(e.index) or i, actor = actor, entry = e }
        end
    end
    return out
end

-- A braced boss shows status "BossBrace" ("hits on its next turn"); that hit
-- (BraceHit) comes with no dodge prompt, so Guard is the only answer to it.
local function hasBrace(statuses)
    if type(statuses) ~= "table" then return false end
    if statuses.BossBrace then return true end
    for k, v in pairs(statuses) do
        if k == "BossBrace" or v == "BossBrace" or (type(v) == "table" and (v.id == "BossBrace" or v.name == "BossBrace")) then
            return true
        end
    end
    return false
end

local function bossBracing(s)
    for _, e in ipairs(aliveEnemies(s)) do
        local a = e.actor
        if a.brace or a.telegraph or a.bracing or hasBrace(a.statuses) or hasBrace(e.entry.statuses) then
            return true
        end
    end
    return false
end

local function pickTarget(s)
    local list = aliveEnemies(s)
    if #list == 0 then return tonumber(s.activeEnemyIndex) or 1 end
    local best = list[1]
    for _, e in ipairs(list) do
        local a, b = e.actor, best.actor
        if Config.TargetMode == "boss" then
            if (a.isBoss or e.entry.isBoss or a.boss) and not (b.isBoss or best.entry.isBoss or b.boss) then best = e end
        elseif Config.TargetMode == "lowest" then
            if (tonumber(a.hp) or 1e9) < (tonumber(b.hp) or 1e9) then best = e end
        end
    end
    return best.index
end

-- latest hero profile, pushed by the server as RPGState "Profile"
local Hero = { profile = nil }
local function heroProfile()
    if type(Hero.profile) == "table" then return Hero.profile end
    local ctrl = rpgController()
    local pg = ctrl and ctrl.pixelGear
    return pg and type(pg.profile) == "table" and pg.profile or nil
end

-- class skill definitions carry the real numbers (power, hits, area)
local function skillDef(id)
    local cls = LocalPlayer:GetAttribute("RPGClass")
    local GC = gameConfig()
    local c = GC and GC.Classes and GC.Classes[cls]
    for _, d in ipairs(c and c.skills or {}) do
        if d.id == id then return d end
    end
    return nil
end

local function currentClassSkillIds()
    local cls = LocalPlayer:GetAttribute("RPGClass")
    local GC = gameConfig()
    local classDef = GC and GC.Classes and GC.Classes[cls]
    if type(classDef) ~= "table" or type(classDef.skills) ~= "table" then return nil end
    local ids = {}
    for _, def in pairs(classDef.skills) do
        if type(def) == "table" and def.id ~= nil then ids[tostring(def.id)] = true end
    end
    return next(ids) and ids or nil
end
local function skillAllowedForCurrentClass(id)
    local ids = currentClassSkillIds()
    return not ids or ids[tostring(id)] == true
end
local function pruneClassSkillState()
    local ids = currentClassSkillIds()
    if not ids then return false end
    local changed = false
    for id in pairs(Config.KnownSkills) do
        if not ids[tostring(id)] then Config.KnownSkills[id] = nil; changed = true end
    end
    for _, key in ipairs({ "SkillList", "EnemySkillSequence", "BossSkillSequence" }) do
        local list = Config[key]
        if type(list) == "table" then
            for i = #list, 1, -1 do
                if not ids[tostring(list[i])] then table.remove(list, i); changed = true end
            end
        end
    end
    if changed then queueSave() end
    return changed
end

local function skillScore(a, foes)
    local d = skillDef(a.id)
    if not d then return (tonumber(a.cost) or 0) * 0.01 end
    local hits = tonumber(d.hits) or 1
    local area = (d.allEnemies or d.aoe) and math.max(1, foes) or 1
    return (tonumber(d.power) or 1) * hits * area
end

local function isBossBattle(s)
    if s.boss == true then return true end
    for _, e in ipairs(aliveEnemies(s)) do
        if e.entry.boss == true or e.entry.isBoss == true or e.actor.boss == true or e.actor.isBoss == true then return true end
    end
    return false
end

local function sequenceSkill(actions, sequence)
    for _, wanted in ipairs(type(sequence) == "table" and sequence or {}) do
        for _, action in ipairs(actions) do
            if usable(action) and category(action) == "Skill" and tostring(action.id) == tostring(wanted) then return action end
        end
    end
    return nil
end

-- skills are only visible inside a fight; remember every one seen so the
-- picker is filled even before the next battle starts
local function learnSkills(s)
    pruneClassSkillState()
    local added = false
    for _, a in ipairs(type(s.actions) == "table" and s.actions or {}) do
        if type(a) == "table" and a.id ~= nil and category(a) == "Skill"
            and skillAllowedForCurrentClass(a.id) then
            local id = tostring(a.id)
            local name = tostring(a.name or a.id)
            if Config.KnownSkills[id] ~= name then
                Config.KnownSkills[id] = name
                added = true
            end
        end
    end
    if added then
        queueSave()
        if UI.refreshSkills then pcall(UI.refreshSkills) end
    end
end

local lastSkillClass = LocalPlayer:GetAttribute("RPGClass")
task.spawn(function()
    while alive() do
        task.wait(1)
        local cls = LocalPlayer:GetAttribute("RPGClass")
        if cls ~= lastSkillClass then
            lastSkillClass = cls
            local changed = pruneClassSkillState()
            if changed and UI.refreshSkills then pcall(UI.refreshSkills) end
        end
    end
end)

local function chooseAction(s)
    local acts = type(s.actions) == "table" and s.actions or {}
    local byCat = { Skill = {}, Item = {}, Guard = {}, Run = {}, Attack = {}, Meditate = {}, Scroll = {} }
    for _, a in ipairs(acts) do
        if usable(a) then table.insert(byCat[category(a)] or byCat.Attack, a) end
    end
    local hpPct = myBattlePct(s)
    local lv = lives()

    if Config.LifeGuard and lv and lv <= 1 and hpPct and hpPct < Config.LifeGuardPct
        and #byCat.Run > 0 and not (type(s.arena) == "table") then
        return byCat.Run[1], "Flee (last life)"
    end
    if Config.AutoHeal and hpPct and hpPct < Config.HealPct then
        for _, a in ipairs(byCat.Item) do
            if isHealItem(a) then return a, "Heal" end
        end
    end
    if Config.BraceGuard and #byCat.Guard > 0 and bossBracing(s) then
        return byCat.Guard[1], "Guard against boss attack"
    end
    -- picked skills only; with nothing picked, every damage skill (taunts and
    -- buffs waste turns when every hit is already dodged)
    if Config.AutoSkill then
        local boss = isBossBattle(s)
        local sequence = boss and Config.BossSkillSequence or Config.EnemySkillSequence
        local enabled = boss and Config.AutoBossSkill or Config.AutoEnemySkill
        local foes = #aliveEnemies(s)
        local skill, best
        if enabled then skill = sequenceSkill(byCat.Skill, sequence) end
        if not skill then for _, a in ipairs(byCat.Skill) do
            local ok
            ok = a.kind == nil or tostring(a.kind):find("Damage", 1, true) ~= nil
            if ok then
                local sc = skillScore(a, foes)
                if not skill or sc > best then skill, best = a, sc end
            end
        end end
        if skill then return skill, "Skill" end
    end
    if #byCat.Attack > 0 then return byCat.Attack[1], "Attack" end
    if #byCat.Meditate > 0 then return byCat.Meditate[1], "Meditate" end
    for _, a in ipairs(acts) do
        if usable(a) and category(a) ~= "Run" and category(a) ~= "Scroll" then return a, "Other" end
    end
    return nil
end

local function tryAct()
    local s = Battle.snap
    if not (Config.AutoBattle and alive() and type(s) == "table" and s.canAct == true and s.id ~= nil) then return end
    local key = tostring(s.id) .. ":" .. tostring(s.turnNumber) .. ":" .. tostring(s.activeUnit)
    -- the same turn is only re-sent if the server ignored us for a while
    if Battle.lastKey == key and os.clock() - Battle.lastAt < 4 then return end
    Battle.lastKey, Battle.lastAt = key, os.clock()
    local action, why = chooseAction(s)
    if not action then return end
    local payload = { battleId = s.id, actionId = action.id }
    local tt = tostring(action.targetType or "Self")
    if tt == "Enemy" then
        payload.targetEnemyIndex = pickTarget(s)
    elseif tt == "Ally" then
        payload.targetUserId = LocalPlayer.UserId
    end
    local delay = math.clamp(tonumber(Config.ActDelay) or 0.75, 0.1, 1)
    task.wait(delay)
    local cur = Battle.snap
    if not (alive() and cur and cur.id == s.id and cur.canAct == true) then return end
    cmd("CombatAction", payload)
    Stats.actions += 1
    Battle.status = tostring(why) .. ": " .. tostring(action.name or action.id)
end

local function snapOf(a2)
    if type(a2) ~= "table" then return nil end
    return a2.snapshot or a2.battle or a2
end

-- ── 7. RPGState LISTENER (single entry for combat) ────────────────────────────
if RPGState then
    track(RPGState.OnClientEvent:Connect(function(name, data)
        if not alive() then return end
        if name == "RunLobby" and type(data) == "table" then
            RunLobbyState = data
        elseif name == "BattleStarted" or name == "BattleUpdated" then
            local s = snapOf(data)
            if type(s) == "table" then
                Battle.snap = s
                Battle.lastUpdate = os.clock()
                pcall(learnSkills, s)
                local hp = myBattlePct(s)
                if hp then Battle.runMinHp = math.min(Battle.runMinHp or 100, hp) end
                task.spawn(tryAct)
            end
        elseif name == "Profile" and type(data) == "table" then
            Hero.profile = data
        elseif name == "BattleEnded" then
            Battle.snap = nil
            Battle.lastKey = nil
            local d = type(data) == "table" and data or {}
            local res = string.lower(tostring(d.result or d.outcome or ""))
            if d.victory == true or res == "victory" then
                Stats.fightsWon += 1
                Battle.status = "Battle won"
            else
                Stats.fightsLost += 1
                Battle.status = "Battle ended (" .. (res ~= "" and res or "not won") .. ")"
            end
            saveStats()
        elseif name == "RunResumeOffer" or (name == "Toast" and type(data) == "table"
            and tostring(data.text or ""):find("Resume or abandon", 1, true)) then
            -- a run left hanging by a rejoin/disconnect blocks every new start;
            -- resuming keeps its progress (abandoning would throw it away)
            if Config.Farm and os.clock() - (Battle.resumeAt or 0) > 10 then
                Battle.resumeAt = os.clock()
                task.delay(1.5, function()
                    if alive() and Config.Farm then
                        cmd("RunLobby", { action = "resume" })
                        notify("2K Dungeon", "Found an unfinished run; resuming", 4)
                    end
                end)
            end
        elseif type(data) == "table" then
            if name == "DefenseTimingStarted" then
                task.spawn(onDefense, data)
            elseif name == "WarriorBladeTimingStarted" then
                task.spawn(onWarrior, data)
            elseif name == "MageRhythmStarted" then
                task.spawn(onMage, data)
            elseif name == "ThiefSlashStarted" then
                task.spawn(onThief, data)
            end
        end
    end))
end

-- loaded mid-fight (reload or teleport re-inject): our RPGState listener is
-- only set up after the server already pushed BattleStarted, so Battle.snap
-- never arrives on its own. The real snapshot still lives as an upvalue of
-- whatever closure the game's own UI connected to RPGState — the same place
-- rpgController() finds the controller — so pull it out directly instead of
-- asking the server to resend something it already sent once.
local function recoverBattleSnap()
    if not (RPGState and getconnections and debug and debug.getupvalues) then return false end
    local ok = pcall(function()
        for _, c in ipairs(getconnections(RPGState.OnClientEvent)) do
            local seen = {}
            local function walk(f, depth)
                if Battle.snap or depth > 6 or seen[f] then return end
                seen[f] = true
                for _, v in ipairs(debug.getupvalues(f)) do
                    if type(v) == "table" and rawget(v, "activeEnemyIndex") ~= nil then
                        Battle.snap = v
                        Battle.lastUpdate = os.clock()
                        return
                    elseif type(v) == "function" then
                        walk(v, depth + 1)
                    end
                end
            end
            if c.Function then walk(c.Function, 1) end
            if Battle.snap then break end
        end
    end)
    if ok and Battle.snap then
        pcall(learnSkills, Battle.snap)
        task.spawn(tryAct)
        return true
    end
    return false
end

task.spawn(function()
    -- a few quick tries right after boot (connections may not be listed yet),
    -- then a slow watchdog for the rest of the fight in case a later reinject
    -- lands mid-turn the same way
    for _ = 1, 5 do
        task.wait(1)
        if not alive() then return end
        if LocalPlayer:GetAttribute("InTurnBattle") == true and not Battle.snap then
            pcall(recoverBattleSnap)
        end
    end
    while alive() do
        task.wait(5)
        if LocalPlayer:GetAttribute("InTurnBattle") == true
            and (not Battle.snap or os.clock() - Battle.lastUpdate > 8) then
            pcall(recoverBattleSnap)
        end
    end
end)

-- ── 8. RUN MAP: VOTE / EVENTS / STORY / ENDING ────────────────────────────────
local Run = { view = nil, voted = {}, evChoice = {}, evReady = {}, story = {}, ended = {}, endingAt = -1e9,
              phaseKey = nil, phaseSince = os.clock(), status = "-" }

local function memberPct(view)
    local ok, m = pcall(function() return view:_localMember() end)
    return ok and pctOf(m) or nil
end

local function cardStats(kind)
    if not RunConfig then return 2, 2 end
    if kind == "dungeonReturn" then kind = "retreat" end
    local ev = RunConfig.Events and RunConfig.Events[kind]
    if ev then
        local danger = ev.elite and (ev.danger or 4) or math.max(2, ev.danger or 0)
        return danger, ev.reward or 2
    end
    local node = (RunConfig.NodeTypes and (RunConfig.NodeTypes[kind] or RunConfig.NodeTypes.fight)) or {}
    return node.danger or 2, node.reward or 2
end

local PATH_WEIGHTS = {
    loot = { reward = 1.0, danger = 0.15 },
    balanced = { reward = 1.0, danger = 0.6 },
    safe = { reward = 0.6, danger = 1.3 },
}

local function scoreChoice(choice, hpPct)
    local kind = tostring(choice.type or "")
    if kind == "retreat" or kind == "dungeonReturn" or kind == "expLeave" then return -100 end
    local danger, reward = cardStats(kind)
    local w = PATH_WEIGHTS[Config.PathMode] or PATH_WEIGHTS.balanced
    local s = reward * w.reward - danger * w.danger
    if hpPct and hpPct < 50 and (kind == "rest" or kind == "camp") then s += 5 end
    if hpPct and hpPct < 35 and danger >= 4 then s -= 4 end
    return s
end

local function sendRun(view, payload, st)
    local ok, sent = pcall(function() return view:_send(payload, st) end)
    return ok and sent ~= false
end

local function handleEnding(view, st)
    local runId = tostring(st.id or "run")
    if Run.ended[runId] then return end
    Run.ended[runId] = true
    Run.endingAt = os.clock()
    Stats.runs += 1
    if st.result == "victory" then Stats.wins += 1 end
    saveStats()
    local climbed = false
    if Config.AutoClimb and Config.Difficulty ~= "torment" then
        local ladder = { "normal", "hard", "nightmare" }
        local i = table.find(ladder, Config.Difficulty) or 1
        local minHp = Battle.runMinHp or 100
        if st.result == "victory" and minHp >= 50 and i < #ladder then
            i += 1
        elseif st.result ~= "victory" and i > 1 then
            i -= 1
        end
        if ladder[i] ~= Config.Difficulty then
            setFlag("Difficulty", ladder[i])
            climbed = true
            notify("2K Difficulty", "Next run: " .. ladder[i] .. " (lowest HP this run: " .. math.floor(minHp) .. "%)", 6)
            if UI.syncDifficulty then pcall(UI.syncDifficulty) end
        end
    end
    Battle.runMinHp = nil
    task.spawn(function()
        cmd("RunLobby", { action = "endingDone", runId = runId })
        pcall(function()
            view.endingPlaying = false
            view.endingDone = view.endingDone or {}
            view.endingDone[runId] = true
        end)
        if Config.EndAction == "off" then return end
        task.wait(math.clamp(Config.EndDelay, 0.5, 10))
        for _ = 1, 6 do
            local cur = view.state
            if not alive() or not cur or tostring(cur.id) ~= runId or cur.phase ~= "ended" then break end
            local nextTier = tonumber(cur.tormentNext)
            if Config.EndAction == "home" or not Config.Farm or climbed then
                cmd("RunLobby", { action = "replayDecline" })
                cmd("RunGoHome")
                pcall(function() view.options.onReturnToVillage() end)
                break
            elseif Config.EndAction == "next" and nextTier then
                cmd("RunLobby", { action = "replayNext", tier = nextTier })
            else
                cmd("RunLobby", { action = "replay" })
            end
            Run.endingAt = os.clock()
            task.wait(3.5)
        end
    end)
end

local function runStep()
    local view = Run.view
    local st = view and view.state
    if type(st) ~= "table" then
        Run.status = "-"
        return
    end
    local key = tostring(st.id) .. ":" .. tostring(st.round) .. ":" .. tostring(st.phase)
    if key ~= Run.phaseKey then
        Run.phaseKey, Run.phaseSince = key, os.clock()
    end
    local round = tonumber(st.round)
    if round then
        if Run.roundRun == st.id and Run.lastRound and round > Run.lastRound then
            Stats.floors += round - Run.lastRound
            saveStats()
        end
        Run.roundRun, Run.lastRound = st.id, round
    end
    local phase = st.phase
    Run.status = tostring(phase) .. " • Round " .. tostring(st.round or "?")

    if phase == "ended" then
        handleEnding(view, st)
    elseif phase == "choose" and Config.AutoVote then
        if not Run.voted[key] then
            local choices = type(st.choices) == "table" and st.choices or {}
            if #choices > 0 then
                local hp = memberPct(view)
                local bestI, bestS = 1, -math.huge
                for i, c in ipairs(choices) do
                    local s = scoreChoice(type(c) == "table" and c or { type = c }, hp)
                    if s > bestS then bestI, bestS = i, s end
                end
                if sendRun(view, { action = "vote", choice = bestI }, st) then
                    Run.voted[key] = true
                end
            end
        end
    elseif phase == "event" and Config.AutoEvents then
        local ed = type(st.eventData) == "table" and st.eventData or {}
        if not Run.evChoice[key] then
            Run.evChoice[key] = true
            local option
            if ed.kind == "camp" then
                local hp = memberPct(view)
                option = (hp and hp >= 80) and "sharpen" or "rest"
            elseif ed.kind == "altar" then
                option = "leave"
            end
            if option then sendRun(view, { action = "eventChoice", option = option }, st) end
            Run.evReady[key] = os.clock() + 1.2
        elseif Run.evReady[key] and os.clock() >= Run.evReady[key] then
            sendRun(view, { action = "eventReady" }, st)
            Run.evReady[key] = os.clock() + 5
        end
    elseif phase == "story" then
        if not Run.story[key] or os.clock() - Run.story[key] > 5 then
            Run.story[key] = os.clock()
            sendRun(view, { action = "storyChoice", choice = "continue" }, st)
        end
    end
end

-- ── 9. CLIENT MODULE HOOKS ────────────────────────────────────────────────────
task.spawn(function()
    local pbc = platformBattlesClient()
    if not pbc then return end
    local rmv = safeRequire(pbc:WaitForChild("RunMapView", 15))
    if not rmv then return end
    local function capture(self, st)
        Run.view = self
        if type(st) == "table" and st.phase == "ended" then
            task.defer(handleEnding, self, st)
        end
    end
    patch(rmv, "SetState", "RunMapView", function(orig)
        return function(self, newState, ...)
            local r = table.pack(orig(self, newState, ...))
            if alive() then pcall(capture, self, newState) end
            return table.unpack(r, 1, r.n)
        end
    end)
    patch(rmv, "Update", "RunMapView", function(orig)
        return function(self, ...)
            local r = table.pack(orig(self, ...))
            if alive() then pcall(capture, self, self.state) end
            return table.unpack(r, 1, r.n)
        end
    end)
end)

task.spawn(function()
    local pbc = platformBattlesClient()
    if not pbc then return end
    local bjc = safeRequire(pbc:WaitForChild("BattleJoinClient", 15))
    if not bjc then return end
    patch(bjc, "Show", "BattleJoinClient", function(orig)
        return function(self, ...)
            local r = table.pack(orig(self, ...))
            if alive() and Config.AutoJoin then
                task.delay(0.3, function()
                    if alive() and self.pending then pcall(function() self:_join() end) end
                end)
            end
            return table.unpack(r, 1, r.n)
        end
    end)
end)

-- The result sender in section 5 replaces the attack minigame UI after the
-- native completion interval. Defense input is sent separately in section 4.
-- Patch PixelQTE's shared Handle method to avoid a competing native result.
task.spawn(function()
    local ctrl, mt, dpMt
    for _ = 1, 20 do
        if not alive() then return end
        ctrl = rpgController()
        local qte = ctrl and ctrl.pixelQTE
        mt = qte and getmetatable(qte)
        local dp = ctrl and ctrl.defensePresentation
        dpMt = dp and getmetatable(dp)
        if mt and rawget(mt, "Handle") then break end
        mt = nil
        task.wait(1)
    end
    if not mt then return end
    patch(mt, "Handle", "PixelQTE.Handle", function(orig)
        return function(self, name, data)
            if Config.AutoMinigame and (name == "WarriorBladeTimingStarted"
                or name == "MageRhythmStarted" or name == "ThiefSlashStarted") then
                return true
            end
            if Config.AutoDodge and (name == "DefenseTimingStarted" or name == "DefenseTimingResolved") then
                return true
            end
            return orig(self, name, data)
        end
    end)
    -- "DefenseTimingPrepare" (the incoming-attack telegraph) goes straight to
    -- this method, bypassing Handle entirely
    if dpMt and rawget(dpMt, "Prepare") then
        patch(dpMt, "Prepare", "DefensePresentation.Prepare", function(orig)
            return function(self, ...)
                if Config.AutoDodge then return end
                return orig(self, ...)
            end
        end)
    end
end)

-- ── 10. BACKGROUND LOOPS ──────────────────────────────────────────────────────
local function difficultyId()
    if Config.Difficulty == "torment" then
        if RunConfig and type(RunConfig.TormentDifficulty) == "function" then
            local ok, option = pcall(RunConfig.TormentDifficulty, math.clamp(math.floor(tonumber(Config.TormentTier) or 1), 1, TORMENT_MAX))
            if ok and type(option) == "table" and option.id then return option.id end
        end
        return "torment" .. tostring(math.max(1, math.floor(Config.TormentTier)))
    end
    return Config.Difficulty
end

local startBusy = false
local function waitRunLobby(predicate, timeout)
    local deadline = os.clock() + (timeout or 6)
    while alive() and os.clock() < deadline do
        if type(RunLobbyState) == "table" and predicate(RunLobbyState) then return true end
        task.wait(0.1)
    end
    return type(RunLobbyState) == "table" and predicate(RunLobbyState)
end
local function startRun()
    if startBusy then return false end
    startBusy = true
    local startAct = Config.Difficulty == "torment" and 1
        or math.clamp(math.floor(tonumber(Config.StartAct) or 1), 1, actCount)
    local difficulty = difficultyId()
    local modifier = Config.Modifier or "none"
    local ok, result = pcall(function()
        local lobby = RunLobbyState
        if lobby and lobby.state == "lobby" and lobby.hostUserId ~= LocalPlayer.UserId then
            error("The current lobby belongs to another host")
        end
        local isHost = lobby and lobby.state == "lobby" and lobby.hostUserId == LocalPlayer.UserId
        if not isHost then
            cmd("RunLobby", { action = "host", difficulty = difficulty, startAct = startAct })
            if not waitRunLobby(function(s)
                return s.state == "lobby" and s.hostUserId == LocalPlayer.UserId
                    and s.difficulty == difficulty and tonumber(s.startAct) == startAct
            end, 6) then
                -- Older clients used the compact solo action; keep it as a
                -- compatibility path when no lobby state is broadcast.
                return cmd("RunLobby", { action = "solo", startAct = startAct, difficulty = difficulty, modifier = modifier })
            end
        elseif lobby.difficulty ~= difficulty or tonumber(lobby.startAct) ~= startAct then
            cmd("RunLobby", { action = "difficulty", difficulty = difficulty, startAct = startAct })
            if not waitRunLobby(function(s)
                return s.state == "lobby" and s.hostUserId == LocalPlayer.UserId
                    and s.difficulty == difficulty and tonumber(s.startAct) == startAct
            end, 6) then
                error("Difficulty or Act was rejected")
            end
        end
        lobby = RunLobbyState or {}
        if (lobby.modifier or "none") ~= modifier then
            cmd("RunLobby", { action = "modifier", modifier = modifier })
            if not waitRunLobby(function(s)
                return s.state == "lobby" and s.hostUserId == LocalPlayer.UserId and s.modifier == modifier
            end, 6) then
                error("Modifier was rejected")
            end
        end
        lobby = RunLobbyState or {}
        if lobby.revision == nil then
            return cmd("RunLobby", { action = "solo", startAct = startAct, difficulty = difficulty, modifier = modifier })
        end
        return cmd("RunLobby", { action = "start", revision = lobby.revision })
    end)
    startBusy = false
    if not ok then notify("2K Dungeon", tostring(result):match("[^:]+$") or "Run request failed", 4) end
    return ok and result ~= false
end

local startLives = lives()
local lastStart = -1e9

task.spawn(function()
    while alive() do
        task.wait(0.5)
        pcall(runStep)
        pcall(tryAct)
    end
end)

task.spawn(function()
    while alive() do
        task.wait(2)
        local inRun = LocalPlayer:GetAttribute("PBInRun") == true
        local inBattle = LocalPlayer:GetAttribute("InTurnBattle") == true

        -- a life lost means something went wrong: stop before it happens again
        local lv = lives()
        if Config.Farm and Config.StopOnLifeLoss and startLives and lv and lv < startLives then
            setFlag("Farm", false)
            startLives = lv
            notify("2K Farm Stopped", "Lives dropped to " .. tostring(lv) .. "; Auto Farm stopped", 10)
            if UI.syncFarm then pcall(UI.syncFarm, false) end
        end
        if lv and (not startLives or lv > startLives) then startLives = lv end

        if Config.Farm and RPGCommand and not inRun and not inBattle
            and LocalPlayer:GetAttribute("RPGGameplayReady") == true
            and LocalPlayer:GetAttribute("RPGClass") ~= nil
            and os.clock() - Run.endingAt > 12
            and os.clock() - lastStart > 8 then
            lastStart = os.clock()
            startRun()
        end

        if Config.Watchdog then
            -- turn battle silent too long: ask the server to resend state
            if inBattle and os.clock() - Battle.lastUpdate > 30 then
                Battle.lastUpdate = os.clock()
                cmd("SyncBattle")
            end
            -- run map parked on the same phase too long: re-request it
            local view = Run.view
            if inRun and not inBattle and view and view.state and view.state.phase ~= "battle"
                and view.state.phase ~= "starting" and os.clock() - Run.phaseSince > 90 then
                Run.phaseSince = os.clock()
                pcall(function() view:RequestState() end)
            end
        end
    end
end)

task.spawn(function()
    while alive() do
        task.wait(15)
        saveStats()
    end
end)

-- stat points: weights per build, the class's own damage stat is "main"
local BUILDS = {
    dps = { main = 1 },
    balanced = { main = 2, Vitality = 1 },
    tank = { main = 1, Vitality = 1, Defense = 1 },
}
local function nextStat(p)
    local GC = gameConfig()
    local SA = GC and GC.StatAllocation
    if not SA then return nil end
    local cls = p.selectedClass or p.baseClass or LocalPlayer:GetAttribute("RPGClass")
    local main = (SA.ClassStat and SA.ClassStat[cls]) or "Strength"
    local cap = SA.MaximumPerStat or 50
    local alloc = type(p.allocatedStats) == "table" and p.allocatedStats or {}
    local best, bestRatio
    for k, w in pairs(BUILDS[Config.StatBuild] or BUILDS.balanced) do
        local stat = k == "main" and main or k
        local have = tonumber(alloc[stat]) or 0
        if have < cap and (not best or have / w < bestRatio) then best, bestRatio = stat, have / w end
    end
    return best
end

local function spendStats()
    for _ = 1, 100 do
        local p = heroProfile()
        local pts = p and tonumber(p.statPoints) or 0
        if not (alive() and Config.AutoStats and pts > 0) then return end
        local stat = nextStat(p)
        if not stat then return end
        cmd("AllocateStatPoint", { statId = stat, statContext = p.statContext })
        -- wait for the server's profile push before choosing the next point
        local t0 = os.clock()
        local moved = false
        repeat
            task.wait(0.15)
            local q = heroProfile()
            moved = q ~= nil and (tonumber(q.statPoints) or 0) < pts
        until moved or os.clock() - t0 > 3
        if not moved then return end
    end
end

local potionBackoff = 0
local function topUpPotions()
    local p = heroProfile()
    if not (p and Config.AutoPotionBuy and ProfileRequest) or os.clock() < potionBackoff then return end
    local have = tonumber(p.potions) or 0
    local PS = potionStock()
    local cap = (PS and PS.ShopCap) or 99
    local need = math.min(Config.PotionKeep, cap) - have
    if need <= 0 then return end
    local ok, res = pcall(function()
        return ProfileRequest:InvokeServer("Village", { action = "buy", amount = tostring(need) })
    end)
    if ok and type(res) == "table" and res.ok ~= false then
        notify("2K Potions", "Bought " .. need .. " healing potions", 3)
        potionBackoff = os.clock() + 20
    else
        -- not enough gold or the shop refused: retry later instead of spamming
        potionBackoff = os.clock() + 120
    end
    Hero.lastPotionReply = res
end

task.spawn(function()
    while alive() do
        task.wait(4)
        if LocalPlayer:GetAttribute("InTurnBattle") ~= true then
            pcall(spendStats)
            pcall(topUpPotions)
        end
    end
end)

-- QTE token memory never needs to outlive a battle
task.spawn(function()
    while alive() do
        task.wait(120)
        table.clear(handledTokens)
    end
end)

-- ── 11. CODES ─────────────────────────────────────────────────────────────────
local CODES = { "ARENA", "OCTOBER", "SPEAR", "DRAGON", "RELEASE" }
local function redeemAllCodes()
    if not ProfileRequest then return 0 end
    local n = 0
    for _, code in ipairs(CODES) do
        local ok = pcall(function() return ProfileRequest:InvokeServer("RedeemCode", code) end)
        if ok then n += 1 end
        task.wait(0.5)
    end
    return n
end
if Config.AutoCodes then
    task.delay(6, function()
        if alive() then pcall(redeemAllCodes) end
    end)
end

-- ── 12. MOVEMENT ──────────────────────────────────────────────────────────────
track(RunService.Heartbeat:Connect(function()
    if not (Config.WalkSpeedOn or Config.JumpOn) then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.WalkSpeedOn and hum.WalkSpeed ~= Config.WalkSpeed then hum.WalkSpeed = Config.WalkSpeed end
    if Config.JumpOn then
        hum.UseJumpPower = true
        if hum.JumpPower ~= Config.JumpPower then hum.JumpPower = Config.JumpPower end
    end
end))

track(RunService.Stepped:Connect(function()
    if not Config.Noclip then return end
    local ch = LocalPlayer.Character
    if not ch then return end
    for _, p in ipairs(ch:GetChildren()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end))

local function setNoclip(v)
    setFlag("Noclip", v)
    if v then return end
    local ch = LocalPlayer.Character
    if not ch then return end
    for _, p in ipairs(ch:GetChildren()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanCollide = true end
    end
end

-- ── 12b. CURSOR ABOVE THE HUB ─────────────────────────────────────────────────
-- The game hides the OS mouse and draws a pixel cursor in PlayerGui, which always
-- renders under CoreGui (where the hub lives). Game scripts may not write into
-- CoreGui, so the real cursor stays where it is and a mirror copy is drawn on a
-- top-most CoreGui layer, synced every frame after the game moves the original.
local CURSOR_STEP = "TwoK_CursorMirror"
local mirror = { layer = nil, frame = nil, src = nil, pairs = {} }

local function sourceCursor()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    local home = pg and pg:FindFirstChild("PlatformBattlesCursor")
    return home, home and home:FindFirstChild("Cursor")
end

local function rebuildMirror(src)
    if mirror.frame then mirror.frame:Destroy() end
    if not (mirror.layer and mirror.layer.Parent) then
        local layer = Instance.new("ScreenGui")
        layer.Name = "TwoK_CursorLayer"
        layer.IgnoreGuiInset = true
        layer.ResetOnSpawn = false
        layer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        layer.DisplayOrder = 2147483647
        pcall(function() layer.ScreenInsets = Enum.ScreenInsets.None end)
        layer.Parent = CoreGui
        mirror.layer = layer
    end
    local copy = src:Clone()
    copy.Name = "CursorMirror"
    copy.Active = false
    pcall(function() copy.Interactable = false end)
    -- pair source/copy descendants by order so colour changes can be replayed
    local a, b = src:GetDescendants(), copy:GetDescendants()
    mirror.pairs = {}
    for i = 1, math.min(#a, #b) do
        if a[i]:IsA("GuiObject") then mirror.pairs[#mirror.pairs + 1] = { a[i], b[i] } end
    end
    copy.Parent = mirror.layer
    mirror.frame, mirror.src = copy, src
    mirror.count = #a
end

local function stepMirror()
    if not alive() then return end
    -- structure checks are cheap but not free; twice a second is plenty
    local now = os.clock()
    if not mirror.src or now - (mirror.checkedAt or 0) > 0.5 then
        mirror.checkedAt = now
        local home, src = sourceCursor()
        mirror.home = home
        if not src then
            mirror.src = nil
            if mirror.frame then mirror.frame.Visible = false end
            return
        end
        if mirror.src ~= src or not (mirror.frame and mirror.frame.Parent) or #src:GetDescendants() ~= mirror.count then
            rebuildMirror(src)
        end
    end
    local home, src = mirror.home, mirror.src
    if not (src and src.Parent and home) then return end
    local f = mirror.frame
    f.Position = src.Position
    f.Size = src.Size
    f.AnchorPoint = src.AnchorPoint
    f.Visible = src.Visible and home.Enabled
    for _, pr in ipairs(mirror.pairs) do
        local o, c = pr[1], pr[2]
        if c.BackgroundColor3 ~= o.BackgroundColor3 then c.BackgroundColor3 = o.BackgroundColor3 end
        if c.Visible ~= o.Visible then c.Visible = o.Visible end
    end
end

-- a plain RenderStepped connection: binding executor code into the render-step
-- priority list every frame wedged the executor's VM
pcall(function() RunService:UnbindFromRenderStep(CURSOR_STEP) end)
track(RunService.RenderStepped:Connect(function()
    pcall(stepMirror)
end))

do
    local baseCleanup = _G.TwoKPixelLineageCleanUp
    _G.TwoKPixelLineageCleanUp = function()
        baseCleanup()
        pcall(function() RunService:UnbindFromRenderStep(CURSOR_STEP) end)
        pcall(function() if mirror.layer then mirror.layer:Destroy() end end)
        -- a frame moved into CoreGui by an older build of this hub goes home
        pcall(function()
            local old = CoreGui:FindFirstChild("TwoK_CursorLayer")
            local stray = old and old:FindFirstChild("Cursor")
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local home = pg and pg:FindFirstChild("PlatformBattlesCursor")
            if stray and home then stray.Parent = home end
            if old then old:Destroy() end
        end)
    end
end

-- // 3. TWO-K CYBER-NEON UI FRAMEWORK INLINE
-- ─────────────────────────────────────────────────────────────

local TwoKUI = (function()
--[=[
    ██████╗ ██╗  ██╗    ███████╗ ██████╗██████╗ ██╗██████╗ ████████╗
    ╚════██╗██║ ██╔╝    ██╔════╝██╔════╝██╔══██╗██║██╔══██╗╚══██╔══╝
     █████╔╝█████╔╝     ███████╗██║     ██████╔╝██║██████╔╝   ██║   
    ██╔═══╝ ██╔═██╗     ╚════██║██║     ██╔══██╗██║██╔═══╝    ██║   
    ███████╗██║  ██╗    ███████║╚██████╗██║  ██║██║██║        ██║   
    ╚══════╝╚═╝  ╚═╝    ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝   
    
    TwoKUI Engine — Proprietary Cyber-Neon UI Framework
    Designed exclusively for 2K SCRIPT. Built from scratch.
    Zero third-party bloat • 100% Custom Architecture
]=]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local TwoKUI = {
    Version = "2.0.0-CYBER",
    Windows = {},
    ActiveWindow = nil
}

local setThreadIdentity = setthreadidentity or setidentity or (syn and syn.set_thread_identity)

-- Safe GUI Container Resolver
local function getGuiContainer()
    if setThreadIdentity then pcall(setThreadIdentity, 8) end
    local env = (getgenv and getgenv()) or _G
    if env.gethui then
        local ok, h = pcall(env.gethui)
        if ok and h and typeof(h) == "Instance" and h.Name ~= "RobloxGui" then return h end
    end
    if CoreGui then
        return CoreGui
    end
    return LocalPlayer:WaitForChild("PlayerGui", 10)
end

-- Built-in Verified Icon Map (Lucide & Cyber Asset IDs from TwoKIcons)
local ICON_MAP = {
    ["layout-dashboard"] = "rbxassetid://10723424646",
    ["mountain"]         = "rbxassetid://10734897956",
    ["dumbbell"]         = "rbxassetid://10747363809",
    ["zap"]              = "rbxassetid://10723376114",
    ["user"]             = "rbxassetid://10747373176",
    ["map-pin"]          = "rbxassetid://10734886004",
    ["settings"]         = "rbxassetid://10734950309",
    ["activity"]         = "rbxassetid://10709752035",
    ["chart-column"]     = "rbxassetid://10709773755",
    ["sliders-horizontal"] = "rbxassetid://10734963191",
    ["circle-plus"]      = "rbxassetid://10734923868",
    ["chevrons-up"]      = "rbxassetid://10709797622",
    ["maximize-2"]       = "rbxassetid://10734886496",
    ["clock"]            = "rbxassetid://10709805144",
    ["gift"]             = "rbxassetid://10723396402",
    ["ticket"]           = "rbxassetid://10734983868",
    ["gauge"]            = "rbxassetid://10723395708",
    ["wind"]             = "rbxassetid://10747382750",
    ["arrow-up"]         = "rbxassetid://10709768939",
    ["chevron-up"]       = "rbxassetid://10709791523",
    ["ghost"]            = "rbxassetid://10723396107",
    ["shield-check"]     = "rbxassetid://10734951367",
    ["shield-alert"]     = "rbxassetid://10734951173",
    ["navigation"]       = "rbxassetid://10734906744",
    ["hammer"]           = "rbxassetid://10723405360",
    ["layers"]           = "rbxassetid://10723424505",
    ["house"]            = "rbxassetid://10723407389",
    ["crown"]            = "rbxassetid://10709818626",
    ["circle-arrow-up"]  = "rbxassetid://10709768432",
    ["award"]            = "rbxassetid://10709769406",
    ["palette"]          = "rbxassetid://10734910430",
    ["paint-bucket"]     = "rbxassetid://10734909847",
    ["cpu"]              = "rbxassetid://10709813383",
    ["refresh-cw"]       = "rbxassetid://10734933222",
    ["power"]            = "rbxassetid://10734930466",
    ["swords"]           = "rbxassetid://10734975692",
    ["sword"]            = "rbxassetid://10734975486",
    ["coins"]            = "rbxassetid://10709811110",
    ["package"]          = "rbxassetid://10734909540",
    ["download"]         = "rbxassetid://10723344270",
    ["upload"]           = "rbxassetid://10747366434",
    ["fast-forward"]     = "rbxassetid://10723354521",
    ["sparkles"]         = "rbxassetid://10734966248",
    ["square"]           = "rbxassetid://10734965702",
    ["box"]              = "rbxassetid://10709782497",
    ["flag"]             = "rbxassetid://10723375890",
    ["footprints"]       = "rbxassetid://10723395708",
    ["map"]              = "rbxassetid://10734886202",
    ["octagon-x"]        = "rbxassetid://10747384037",
    ["pencil"]           = "rbxassetid://10734919691",
    ["repeat"]           = "rbxassetid://10734933966",
    ["trending-up"]      = "rbxassetid://10747363465",
    ["unlock"]           = "rbxassetid://10747366027",
    ["egg"]              = "rbxassetid://10709782497",
    ["drumstick"]        = "rbxassetid://10747363809",
    ["shopping-cart"]    = "rbxassetid://10734950309",
    ["compass"]          = "rbxassetid://10734906744",
    ["flame"]            = "rbxassetid://10723376114"
}

local TwoKIcons = nil
pcall(function()
    if isfile and isfile("TwoKIcons.luau") and readfile then
        local fn = (loadstring or load)(readfile("TwoKIcons.luau"))
        if fn then TwoKIcons = fn() end
    end
    if not TwoKIcons and game and game.HttpGet then
        local okH, raw = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/TwoKIcons.luau")
        if okH and raw and #raw > 100 then
            local fn = (loadstring or load)(raw)
            if fn then TwoKIcons = fn() end
        end
    end
end)

local function resolveIcon(name)
    if not name or name == "" then return "rbxassetid://10709752035" end
    if string.find(name, "rbxasset") then return name end
    if ICON_MAP[name] then return ICON_MAP[name] end
    if TwoKIcons and TwoKIcons.assets then
        local k1 = "lucide-" .. name
        if TwoKIcons.assets[k1] then return TwoKIcons.assets[k1] end
        if TwoKIcons.assets[name] then return TwoKIcons.assets[name] end
    end
    return "rbxassetid://10709752035"
end

-- Helper: Ensure local image asset
local function ensureAsset(filename, url)
    if not (isfile and writefile and getcustomasset) then return nil end
    pcall(function()
        if not isfile(filename) then
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req and url then
                local res = req({ Url = url, Method = "GET" })
                if res and res.Body and #res.Body > 500 then
                    writefile(filename, res.Body)
                end
            end
        end
    end)
    if isfile and isfile(filename) then
        local ok, asset = pcall(getcustomasset, filename)
        if ok and asset then return asset end
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────
-- WINDOW BUILDER
-- ─────────────────────────────────────────────────────────────
function TwoKUI:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "2K SCRIPT"
    local SubTitle = config.SubTitle or "ROBLOX SCRIPT EXECUTOR & TOOLS"
    local Keybind = config.Keybind or Enum.KeyCode.LeftControl
    local Size = config.Size or UDim2.fromOffset(880, 520)
    
    local container = getGuiContainer()
    
    -- Cleanup any existing instance across all possible containers
    local cleanupContainers = { container, CoreGui }
    pcall(function()
        if CoreGui and CoreGui:FindFirstChild("RobloxGui") then
            table.insert(cleanupContainers, CoreGui.RobloxGui)
        end
    end)
    pcall(function()
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then
            table.insert(cleanupContainers, LocalPlayer.PlayerGui)
        end
    end)
    for _, par in ipairs(cleanupContainers) do
        if par then
            for _, c in ipairs(par:GetChildren()) do
                if c.Name == "TwoK_UI_Screen" or c.Name == "TwoK_PixelLineage_Screen" or c.Name == "TwoK_Pyramid_Float" or c.Name == "TwoKPixel_Float" then
                    pcall(function() c:Destroy() end)
                end
            end
        end
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TwoK_UI_Screen"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = container

    -- Outer Window Frame (Draggable)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.Size = Size
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.BackgroundColor3 = Color3.fromHex("#030712")
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 20)
    mainCorner.Parent = mainFrame

    -- Cyber Neon Animated Outer Stroke
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromHex("#00E5FF")
    mainStroke.Thickness = 2.0
    mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    mainStroke.Parent = mainFrame

    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromHex("#00E5FF")),
        ColorSequenceKeypoint.new(0.30, Color3.fromHex("#0077FE")),
        ColorSequenceKeypoint.new(0.65, Color3.fromHex("#38BDF8")),
        ColorSequenceKeypoint.new(1.00, Color3.fromHex("#00E5FF"))
    })
    strokeGrad.Parent = mainStroke

    -- Aesthetic Anime Sky Background Art Overlay
    local bgImage = Instance.new("ImageLabel")
    bgImage.Name = "BackgroundArt"
    bgImage.Size = UDim2.fromScale(1, 1)
    bgImage.Position = UDim2.fromScale(0, 0)
    bgImage.BackgroundTransparency = 1
    bgImage.ScaleType = Enum.ScaleType.Crop
    bgImage.ImageTransparency = 0.12
    bgImage.ZIndex = 1
    bgImage.Parent = mainFrame

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 20)
    bgCorner.Parent = bgImage

    task.spawn(function()
        local artAsset = ensureAsset("2k_bg_art_v4.png", "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/assets/2k_bg_art_v4.png")
        if not artAsset then
            artAsset = ensureAsset("2k_bg_art_v3.png", "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/assets/2k_bg_art_v3.png")
        end
        if not artAsset then
            artAsset = ensureAsset("2k_bg_art.png", "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/assets/2k_bg_art.png")
        end
        if artAsset then
            bgImage.Image = artAsset
        end
    end)

    -- Soft Radial / Linear Dark Tint Overlay for Legibility
    local tintOverlay = Instance.new("Frame")
    tintOverlay.Name = "TintOverlay"
    tintOverlay.Size = UDim2.fromScale(1, 1)
    tintOverlay.BackgroundColor3 = Color3.fromHex("#020610")
    tintOverlay.BackgroundTransparency = 0.55
    tintOverlay.BorderSizePixel = 0
    tintOverlay.ZIndex = 2
    tintOverlay.Parent = mainFrame

    local tintCorner = Instance.new("UICorner")
    tintCorner.CornerRadius = UDim.new(0, 20)
    tintCorner.Parent = tintOverlay

    -- ─────────────────────────────────────────────────────────
    -- TOPBAR (2K Starburst Logo + Title + Controls)
    -- ─────────────────────────────────────────────────────────
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 54)
    topbar.BackgroundTransparency = 1
    topbar.BorderSizePixel = 0
    topbar.ZIndex = 5
    topbar.Parent = mainFrame

    local topbarLine = Instance.new("Frame")
    topbarLine.Name = "Divider"
    topbarLine.Size = UDim2.new(1, 0, 0, 1)
    topbarLine.Position = UDim2.new(0, 0, 1, -1)
    topbarLine.BackgroundColor3 = Color3.fromHex("#00E5FF")
    topbarLine.BackgroundTransparency = 0.75
    topbarLine.BorderSizePixel = 0
    topbarLine.Parent = topbar

    -- 2K Starburst Logo & Brand (Clean Top-Left)
    local brandContainer = Instance.new("Frame")
    brandContainer.Name = "BrandContainer"
    brandContainer.Size = UDim2.new(0, 280, 1, 0)
    brandContainer.Position = UDim2.new(0, 18, 0, 0)
    brandContainer.BackgroundTransparency = 1
    brandContainer.Parent = topbar

    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "Logo"
    logoImg.Size = UDim2.fromOffset(34, 34)
    logoImg.Position = UDim2.new(0, 0, 0.5, -17)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = "rbxassetid://10723346959"
    logoImg.ImageColor3 = Color3.fromHex("#00E5FF")
    logoImg.Parent = brandContainer

    task.spawn(function()
        local logoAsset = ensureAsset("2k_logo.png", "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/assets/2k_logo.png")
        if logoAsset then
            logoImg.Image = logoAsset
            logoImg.ImageColor3 = Color3.new(1, 1, 1)
        end
    end)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Name = "Title"
    titleLbl.Text = Title
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 18
    titleLbl.TextColor3 = Color3.fromHex("#FFFFFF")
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Size = UDim2.new(1, -44, 0, 20)
    titleLbl.Position = UDim2.new(0, 42, 0, 9)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Parent = brandContainer

    local subTitleLbl = Instance.new("TextLabel")
    subTitleLbl.Name = "SubTitle"
    subTitleLbl.Text = string.upper(SubTitle)
    subTitleLbl.Font = Enum.Font.GothamMedium
    subTitleLbl.TextSize = 9
    subTitleLbl.TextColor3 = Color3.fromHex("#38BDF8")
    subTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    subTitleLbl.Size = UDim2.new(1, -44, 0, 14)
    subTitleLbl.Position = UDim2.new(0, 42, 0, 30)
    subTitleLbl.BackgroundTransparency = 1
    subTitleLbl.Parent = brandContainer

    -- Real-time FPS & Ping Tracker (Replaced "Beyond Your Limits")
    local perfLbl = Instance.new("TextLabel")
    perfLbl.Name = "PerfTracker"
    perfLbl.Text = "FPS: 60  |  Ping: -- ms"
    perfLbl.Font = Enum.Font.GothamBold
    perfLbl.TextSize = 12
    perfLbl.TextColor3 = Color3.fromHex("#00E5FF")
    perfLbl.TextTransparency = 0.1
    perfLbl.Size = UDim2.new(0, 220, 1, 0)
    perfLbl.Position = UDim2.new(0.5, -110, 0, 0)
    perfLbl.BackgroundTransparency = 1
    perfLbl.Parent = topbar

    task.spawn(function()
        local frameCount = 0
        local lastTime = os.clock()
        local fps = 60
        local Stats = game:GetService("Stats")

        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            if not mainFrame.Parent then
                if renderConn then renderConn:Disconnect() end
                return
            end
            frameCount = frameCount + 1
            local now = os.clock()
            if now - lastTime >= 0.5 then
                fps = math.floor(frameCount / (now - lastTime))
                frameCount = 0
                lastTime = now

                local ping = 0
                pcall(function()
                    ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                end)
                if ping <= 0 then
                    pcall(function()
                        ping = math.floor(Stats.PerformanceStats.Ping:GetValue())
                    end)
                end

                perfLbl.Text = string.format("FPS: %d  |  Ping: %d ms", fps, ping)
            end
        end)
    end)

    -- Window Controls (Minimize / Maximize / Close)
    local controlsFrame = Instance.new("Frame")
    controlsFrame.Name = "Controls"
    controlsFrame.Size = UDim2.fromOffset(100, 32)
    controlsFrame.Position = UDim2.new(1, -114, 0.5, -16)
    controlsFrame.BackgroundTransparency = 1
    controlsFrame.Parent = topbar

    local function makeControlBtn(text, posX)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.fromOffset(28, 28)
        btn.Position = UDim2.new(0, posX, 0, 2)
        btn.BackgroundColor3 = Color3.fromHex("#081426")
        btn.BackgroundTransparency = 0.4
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = Color3.fromHex("#94A3B8")
        btn.AutoButtonColor = false
        btn.Parent = controlsFrame
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 6)
        c.Parent = btn
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromHex("#00E5FF")
        s.Thickness = 1
        s.Transparency = 0.8
        s.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromHex("#0F2847"), TextColor3 = Color3.fromHex("#FFFFFF") }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromHex("#081426"), TextColor3 = Color3.fromHex("#94A3B8") }):Play()
        end)
        return btn
    end

    local btnMin = makeControlBtn("—", 0)
    local btnMax = makeControlBtn("□", 34)
    local btnClose = makeControlBtn("✕", 68)

    -- Draggable Logic for Topbar
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ─────────────────────────────────────────────────────────
    -- LEFT SIDEBAR (Tabs + User Profile Badge)
    -- ─────────────────────────────────────────────────────────
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 215, 1, -54)
    sidebar.Position = UDim2.new(0, 0, 0, 54)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 5
    sidebar.Parent = mainFrame

    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "SidebarDivider"
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    sidebarDivider.BackgroundColor3 = Color3.fromHex("#00E5FF")
    sidebarDivider.BackgroundTransparency = 0.8
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.Parent = sidebar

    local tabButtonsScroll = Instance.new("ScrollingFrame")
    tabButtonsScroll.Name = "TabButtonsScroll"
    tabButtonsScroll.Size = UDim2.new(1, -16, 1, -82)
    tabButtonsScroll.Position = UDim2.new(0, 8, 0, 10)
    tabButtonsScroll.BackgroundTransparency = 1
    tabButtonsScroll.BorderSizePixel = 0
    tabButtonsScroll.ScrollBarThickness = 2
    tabButtonsScroll.ScrollBarImageColor3 = Color3.fromHex("#00E5FF")
    tabButtonsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabButtonsScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabButtonsScroll.Parent = sidebar

    local tabListLayout = Instance.new("UIListLayout")
    tabListLayout.FillDirection = Enum.FillDirection.Vertical
    tabListLayout.Padding = UDim.new(0, 7)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Parent = tabButtonsScroll

    -- Bottom User Profile Card
    local profileCard = Instance.new("Frame")
    profileCard.Name = "UserProfileCard"
    profileCard.Size = UDim2.new(1, -16, 0, 60)
    profileCard.Position = UDim2.new(0, 8, 1, -68)
    profileCard.BackgroundColor3 = Color3.fromHex("#061122")
    profileCard.BackgroundTransparency = 0.3
    profileCard.BorderSizePixel = 0
    profileCard.Parent = sidebar

    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 12)
    profileCorner.Parent = profileCard

    local profileStroke = Instance.new("UIStroke")
    profileStroke.Color = Color3.fromHex("#00E5FF")
    profileStroke.Thickness = 1.2
    profileStroke.Transparency = 0.65
    profileStroke.Parent = profileCard

    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(40, 40)
    avatarImg.Position = UDim2.new(0, 10, 0.5, -20)
    avatarImg.BackgroundColor3 = Color3.fromHex("#0B1B33")
    avatarImg.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    avatarImg.Parent = profileCard
    local avCorner = Instance.new("UICorner")
    avCorner.CornerRadius = UDim.new(0, 8)
    avCorner.Parent = avatarImg

    local dNameLbl = Instance.new("TextLabel")
    dNameLbl.Name = "DisplayName"
    dNameLbl.Text = LocalPlayer.DisplayName
    dNameLbl.Font = Enum.Font.GothamBold
    dNameLbl.TextSize = 12
    dNameLbl.TextColor3 = Color3.fromHex("#FFFFFF")
    dNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    dNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    dNameLbl.Size = UDim2.new(1, -60, 0, 16)
    dNameLbl.Position = UDim2.new(0, 56, 0, 8)
    dNameLbl.BackgroundTransparency = 1
    dNameLbl.Parent = profileCard

    local uNameLbl = Instance.new("TextLabel")
    uNameLbl.Name = "Username"
    uNameLbl.Text = "@" .. LocalPlayer.Name
    uNameLbl.Font = Enum.Font.Gotham
    uNameLbl.TextSize = 10
    uNameLbl.TextColor3 = Color3.fromHex("#94A3B8")
    uNameLbl.TextXAlignment = Enum.TextXAlignment.Left
    uNameLbl.Size = UDim2.new(1, -60, 0, 14)
    uNameLbl.Position = UDim2.new(0, 56, 0, 24)
    uNameLbl.BackgroundTransparency = 1
    uNameLbl.Parent = profileCard

    local badgeLbl = Instance.new("TextLabel")
    badgeLbl.Name = "Badge"
    badgeLbl.Text = "2K Script • Premium Hub"
    badgeLbl.Font = Enum.Font.GothamMedium
    badgeLbl.TextSize = 9
    badgeLbl.TextColor3 = Color3.fromHex("#38BDF8")
    badgeLbl.TextXAlignment = Enum.TextXAlignment.Left
    badgeLbl.Size = UDim2.new(1, -60, 0, 12)
    badgeLbl.Position = UDim2.new(0, 56, 0, 40)
    badgeLbl.BackgroundTransparency = 1
    badgeLbl.Parent = profileCard

    -- ─────────────────────────────────────────────────────────
    -- RIGHT CONTENT AREA (Containers)
    -- ─────────────────────────────────────────────────────────
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, -225, 1, -64)
    contentArea.Position = UDim2.new(0, 220, 0, 58)
    contentArea.BackgroundTransparency = 1
    contentArea.ZIndex = 4
    contentArea.Parent = mainFrame

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = 1.0
    uiScale.Parent = mainFrame

    -- Window Object and Collections
    local Window = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        UIScale = uiScale,
        Tabs = {},
        SelectedTab = nil,
        IsOpen = true
    }

    function Window:SetScale(scale)
        uiScale.Scale = math.clamp(scale, 0.5, 1.5)
    end

    function Window:Toggle()
        self.IsOpen = not self.IsOpen
        if self.IsOpen then
            mainFrame.Visible = true
            TweenService:Create(mainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else
            local tw = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 1.5, 0)
            })
            tw:Play()
            tw.Completed:Connect(function()
                if not self.IsOpen then mainFrame.Visible = false end
            end)
        end
    end

    function Window:Open()
        if not self.IsOpen then self:Toggle() end
    end

    function Window:Close()
        if self.IsOpen then self:Toggle() end
    end

    function Window:Destroy()
        pcall(function() screenGui:Destroy() end)
    end

    btnMin.MouseButton1Click:Connect(function() Window:Toggle() end)
    btnClose.MouseButton1Click:Connect(function() Window:Toggle() end)

    -- Fullscreen Toggle
    local isMax = false
    local originalSize = Size
    local function toggleMax()
        isMax = not isMax
        if isMax then
            TweenService:Create(mainFrame, TweenInfo.new(0.25), {
                Size = UDim2.new(0.96, 0, 0.94, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        else
            TweenService:Create(mainFrame, TweenInfo.new(0.25), {
                Size = originalSize,
                Position = UDim2.new(0.5, 0, 0.5, 0)
            }):Play()
        end
    end
    btnMax.MouseButton1Click:Connect(toggleMax)

    -- ─────────────────────────────────────────────────────────
    -- CORNER RESIZE HANDLE (Interactive Scaler / Resizer)
    -- ─────────────────────────────────────────────────────────
    local resizeGrip = Instance.new("TextButton")
    resizeGrip.Name = "ResizeGrip"
    resizeGrip.Size = UDim2.fromOffset(28, 28)
    resizeGrip.Position = UDim2.new(1, -28, 1, -28)
    resizeGrip.BackgroundTransparency = 1
    resizeGrip.Text = ""
    resizeGrip.AutoButtonColor = false
    resizeGrip.ZIndex = 25
    resizeGrip.Parent = mainFrame

    -- Aesthetic Cyber Resize Grip Visual Icon
    local gripVisual = Instance.new("ImageLabel")
    gripVisual.Name = "GripVisual"
    gripVisual.Size = UDim2.fromOffset(16, 16)
    gripVisual.Position = UDim2.new(1, -18, 1, -18)
    gripVisual.BackgroundTransparency = 1
    gripVisual.Image = "rbxassetid://10734920536" -- maximize-2 / resize diagonal arrow
    gripVisual.ImageColor3 = Color3.fromHex("#00E5FF")
    gripVisual.ImageTransparency = 0.4
    gripVisual.ZIndex = 26
    gripVisual.Parent = mainFrame

    local isResizing = false
    local resizeStartMouse = Vector2.zero
    local resizeStartSize = Vector2.zero

    resizeGrip.MouseEnter:Connect(function()
        TweenService:Create(gripVisual, TweenInfo.new(0.15), {
            ImageColor3 = Color3.fromHex("#00FFFF"),
            ImageTransparency = 0.0
        }):Play()
    end)

    resizeGrip.MouseLeave:Connect(function()
        if not isResizing then
            TweenService:Create(gripVisual, TweenInfo.new(0.15), {
                ImageColor3 = Color3.fromHex("#00E5FF"),
                ImageTransparency = 0.4
            }):Play()
        end
    end)

    resizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            resizeStartSize = Vector2.new(mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y)
            
            TweenService:Create(gripVisual, TweenInfo.new(0.1), {
                ImageColor3 = Color3.fromHex("#00FFFF"),
                ImageTransparency = 0.0
            }):Play()

            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isResizing = false
                    TweenService:Create(gripVisual, TweenInfo.new(0.2), {
                        ImageColor3 = Color3.fromHex("#00E5FF"),
                        ImageTransparency = 0.4
                    }):Play()
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isResizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local deltaX = input.Position.X - resizeStartMouse.X
            local deltaY = input.Position.Y - resizeStartMouse.Y

            local newW = math.clamp(resizeStartSize.X + deltaX, 620, 1400)
            local newH = math.clamp(resizeStartSize.Y + deltaY, 390, 900)

            mainFrame.Size = UDim2.fromOffset(newW, newH)
            originalSize = mainFrame.Size
        end
    end)

    -- ─────────────────────────────────────────────────────────
    -- TAB BUILDER
    -- ─────────────────────────────────────────────────────────
    function Window:Tab(tabCfg)
        tabCfg = tabCfg or {}
        local tabTitle = tabCfg.Title or "Tab"
        local tabIcon = resolveIcon(tabCfg.Icon)
        local tabIndex = #self.Tabs + 1

        -- Tab Button in Sidebar
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = "TabBtn_" .. tabIndex
        tabBtn.Size = UDim2.new(1, 0, 0, 42)
        tabBtn.BackgroundColor3 = Color3.fromHex("#081426")
        tabBtn.BackgroundTransparency = 0.35
        tabBtn.Text = ""
        tabBtn.AutoButtonColor = false
        tabBtn.Parent = tabButtonsScroll

        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 10)
        tabBtnCorner.Parent = tabBtn

        local tabBtnStroke = Instance.new("UIStroke")
        tabBtnStroke.Color = Color3.fromHex("#00E5FF")
        tabBtnStroke.Thickness = 1.2
        tabBtnStroke.Transparency = 0.8
        tabBtnStroke.Parent = tabBtn

        local tIcon = Instance.new("ImageLabel")
        tIcon.Name = "Icon"
        tIcon.Size = UDim2.fromOffset(20, 20)
        tIcon.Position = UDim2.new(0, 12, 0.5, -10)
        tIcon.BackgroundTransparency = 1
        tIcon.Image = tabIcon
        tIcon.ImageColor3 = Color3.fromHex("#CBD5E1")
        tIcon.Parent = tabBtn

        local tTitle = Instance.new("TextLabel")
        tTitle.Name = "Title"
        tTitle.Text = tabTitle
        tTitle.Font = Enum.Font.GothamBold
        tTitle.TextSize = 13
        tTitle.TextColor3 = Color3.fromHex("#CBD5E1")
        tTitle.TextXAlignment = Enum.TextXAlignment.Left
        tTitle.TextYAlignment = Enum.TextYAlignment.Center
        tTitle.Size = UDim2.new(1, -44, 1, 0)
        tTitle.Position = UDim2.new(0, 40, 0, 0)
        tTitle.BackgroundTransparency = 1
        tTitle.Parent = tabBtn

        -- Tab Content ScrollingFrame
        local tabScroll = Instance.new("ScrollingFrame")
        tabScroll.Name = "TabContent_" .. tabIndex
        tabScroll.Size = UDim2.fromScale(1, 1)
        tabScroll.Position = UDim2.fromScale(0, 0)
        tabScroll.BackgroundTransparency = 1
        tabScroll.BorderSizePixel = 0
        tabScroll.ScrollBarThickness = 3
        tabScroll.ScrollBarImageColor3 = Color3.fromHex("#00E5FF")
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        tabScroll.Visible = false
        tabScroll.Parent = contentArea

        local tabScrollLayout = Instance.new("UIListLayout")
        tabScrollLayout.FillDirection = Enum.FillDirection.Vertical
        tabScrollLayout.Padding = UDim.new(0, 12)
        tabScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabScrollLayout.Parent = tabScroll

        local tabScrollPadding = Instance.new("UIPadding")
        tabScrollPadding.PaddingTop = UDim.new(0, 2)
        tabScrollPadding.PaddingBottom = UDim.new(0, 20)
        tabScrollPadding.PaddingRight = UDim.new(0, 8)
        tabScrollPadding.Parent = tabScroll

        local Tab = {
            Index = tabIndex,
            TabBtn = tabBtn,
            Container = tabScroll,
            Title = tabTitle
        }

        function Tab:Select()
            for _, t in ipairs(Window.Tabs) do
                t.Container.Visible = false
                pcall(function()
                    TweenService:Create(t.TabBtn, TweenInfo.new(0.2), {
                        BackgroundColor3 = Color3.fromHex("#081426"),
                        BackgroundTransparency = 0.35
                    }):Play()
                    local s = t.TabBtn:FindFirstChildWhichIsA("UIStroke")
                    if s then s.Transparency = 0.8 end
                    local ttl = t.TabBtn:FindFirstChild("Title")
                    if ttl then ttl.TextColor3 = Color3.fromHex("#CBD5E1") end
                    local ic = t.TabBtn:FindFirstChild("Icon")
                    if ic then ic.ImageColor3 = Color3.fromHex("#94A3B8") end
                end)
            end
            
            tabScroll.Visible = true
            pcall(function()
                TweenService:Create(tabBtn, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromHex("#0284C7"),
                    BackgroundTransparency = 0.15
                }):Play()
                local s = tabBtn:FindFirstChildWhichIsA("UIStroke")
                if s then
                    s.Transparency = 0.1
                    s.Color = Color3.fromHex("#00E5FF")
                end
                tTitle.TextColor3 = Color3.fromHex("#FFFFFF")
                tIcon.ImageColor3 = Color3.fromHex("#00FFFF")
            end)
            Window.SelectedTab = Tab
        end

        tabBtn.MouseButton1Click:Connect(function()
            Tab:Select()
        end)

        tabBtn.MouseEnter:Connect(function()
            if Window.SelectedTab ~= Tab then
                TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromHex("#0E2342"),
                    BackgroundTransparency = 0.2
                }):Play()
                tTitle.TextColor3 = Color3.fromHex("#FFFFFF")
            end
        end)

        tabBtn.MouseLeave:Connect(function()
            if Window.SelectedTab ~= Tab then
                TweenService:Create(tabBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromHex("#081426"),
                    BackgroundTransparency = 0.35
                }):Play()
                tTitle.TextColor3 = Color3.fromHex("#CBD5E1")
            end
        end)

        local currentSec = nil
        local function getSec()
            if not currentSec then
                currentSec = Tab:Section({ Title = tabTitle, Desc = "", Icon = tabCfg.Icon })
            end
            return currentSec
        end

        Tab.Toggle = function(_, c) return getSec():Toggle(c) end
        Tab.Slider = function(_, c) return getSec():Slider(c) end
        Tab.Dropdown = function(_, c) return getSec():Dropdown(c) end
        Tab.Button = function(_, c) return getSec():Button(c) end
        Tab.Paragraph = function(_, c) return getSec():Paragraph(c) end
        Tab.Input = function(_, c) return getSec():Input(c) end

        -- ─────────────────────────────────────────────────────
        -- SECTION CARD BUILDER (Like in IMG_5499.png)
        -- ─────────────────────────────────────────────────────
        function Tab:Section(secCfg)
            secCfg = secCfg or {}
            local secTitle = secCfg.Title or "Section"
            local secDesc = secCfg.Desc or ""
            local secIcon = resolveIcon(secCfg.Icon)

            local card = Instance.new("Frame")
            card.Name = "Card_" .. secTitle
            card.Size = UDim2.new(1, 0, 0, 0)
            card.AutomaticSize = Enum.AutomaticSize.Y
            card.BackgroundColor3 = Color3.fromHex("#040C1A")
            card.BackgroundTransparency = 0.20
            card.BorderSizePixel = 0
            card.Parent = tabScroll

            local cardCorner = Instance.new("UICorner")
            cardCorner.CornerRadius = UDim.new(0, 14)
            cardCorner.Parent = card

            local cardStroke = Instance.new("UIStroke")
            cardStroke.Color = Color3.fromHex("#00D4FF")
            cardStroke.Thickness = 1.3
            cardStroke.Transparency = 0.5
            cardStroke.Parent = card

            local cardLayout = Instance.new("UIListLayout")
            cardLayout.FillDirection = Enum.FillDirection.Vertical
            cardLayout.Padding = UDim.new(0, 8)
            cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
            cardLayout.Parent = card

            local cardPadding = Instance.new("UIPadding")
            cardPadding.PaddingTop = UDim.new(0, 12)
            cardPadding.PaddingBottom = UDim.new(0, 12)
            cardPadding.PaddingLeft = UDim.new(0, 14)
            cardPadding.PaddingRight = UDim.new(0, 14)
            cardPadding.Parent = card

            -- Section Header
            local headerFrame = Instance.new("Frame")
            headerFrame.Name = "Header"
            headerFrame.Size = UDim2.new(1, 0, 0, 36)
            headerFrame.BackgroundTransparency = 1
            headerFrame.LayoutOrder = 0
            headerFrame.Parent = card

            local headerIconBadge = Instance.new("Frame")
            headerIconBadge.Name = "Badge"
            headerIconBadge.Size = UDim2.fromOffset(34, 34)
            headerIconBadge.Position = UDim2.new(0, 0, 0.5, -17)
            headerIconBadge.BackgroundColor3 = Color3.fromHex("#082042")
            headerIconBadge.BackgroundTransparency = 0.2
            headerIconBadge.Parent = headerFrame
            local bibCorner = Instance.new("UICorner")
            bibCorner.CornerRadius = UDim.new(0, 8)
            bibCorner.Parent = headerIconBadge
            local bibStroke = Instance.new("UIStroke")
            bibStroke.Color = Color3.fromHex("#00E5FF")
            bibStroke.Thickness = 1.2
            bibStroke.Transparency = 0.5
            bibStroke.Parent = headerIconBadge

            local hIcon = Instance.new("ImageLabel")
            hIcon.Size = UDim2.fromOffset(20, 20)
            hIcon.Position = UDim2.new(0.5, -10, 0.5, -10)
            hIcon.BackgroundTransparency = 1
            hIcon.Image = secIcon
            hIcon.ImageColor3 = Color3.fromHex("#00FFFF")
            hIcon.Parent = headerIconBadge

            local hTitle = Instance.new("TextLabel")
            hTitle.Name = "Title"
            hTitle.Text = secTitle
            hTitle.Font = Enum.Font.GothamBold
            hTitle.TextSize = 14
            hTitle.TextColor3 = Color3.fromHex("#00E5FF")
            hTitle.TextXAlignment = Enum.TextXAlignment.Left
            hTitle.TextYAlignment = Enum.TextYAlignment.Center
            hTitle.Size = UDim2.new(1, -44, 1, 0)
            hTitle.Position = UDim2.new(0, 42, 0, 0)
            hTitle.BackgroundTransparency = 1
            hTitle.Parent = headerFrame

            local Section = {
                Card = card,
                Tab = Tab
            }
            currentSec = Section

            -- Helper: make row frame
            local function makeRow(height)
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, 0, 0, height or 46)
                row.BackgroundColor3 = Color3.fromHex("#08182E")
                row.BackgroundTransparency = 0.2
                row.BorderSizePixel = 0
                row.Parent = card
                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 10)
                rc.Parent = row
                local rs = Instance.new("UIStroke")
                rs.Color = Color3.fromHex("#00E5FF")
                rs.Thickness = 1
                rs.Transparency = 0.8
                rs.Parent = row
                return row
            end

            -- Helper: make icon badge
            local function makeRowIcon(row, iconName)
                local b = Instance.new("Frame")
                b.Size = UDim2.fromOffset(30, 30)
                b.Position = UDim2.new(0, 10, 0.5, -15)
                b.BackgroundColor3 = Color3.fromHex("#081A33")
                b.BackgroundTransparency = 0.2
                b.Parent = row
                local c = Instance.new("UICorner")
                c.CornerRadius = UDim.new(0, 8)
                c.Parent = b
                local s = Instance.new("UIStroke")
                s.Color = Color3.fromHex("#00E5FF")
                s.Thickness = 1
                s.Transparency = 0.7
                s.Parent = b
                local img = Instance.new("ImageLabel")
                img.Size = UDim2.fromOffset(16, 16)
                img.Position = UDim2.new(0.5, -8, 0.5, -8)
                img.BackgroundTransparency = 1
                local resolved = resolveIcon(iconName)
                img.Image = (resolved and resolved ~= "") and resolved or "rbxassetid://10709810948"
                img.ImageColor3 = Color3.fromHex("#00E5FF")
                img.Parent = b
                return b
            end

            -- Helper: make title/desc
            local function makeRowTexts(row, title, desc, rightOffset)
                rightOffset = rightOffset or 60
                local t = Instance.new("TextLabel")
                t.Text = title
                t.Font = Enum.Font.GothamBold
                t.TextSize = 13
                t.TextColor3 = Color3.fromHex("#FFFFFF")
                t.TextXAlignment = Enum.TextXAlignment.Left
                t.TextYAlignment = Enum.TextYAlignment.Center
                t.Size = UDim2.new(1, -(52 + rightOffset), 1, 0)
                t.Position = UDim2.new(0, 48, 0, 0)
                t.BackgroundTransparency = 1
                t.Parent = row
                return t
            end

            -- 1. TOGGLE (Cyber Pill Animated)
            function Section:Toggle(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Toggle"
                local desc = cfg.Desc or ""
                local icon = cfg.Icon or "zap"
                local val = cfg.Value or false
                local callback = cfg.Callback or function() end

                local row = makeRow(48)
                makeRowIcon(row, icon)
                makeRowTexts(row, title, desc, 60)

                local rowClick = Instance.new("TextButton")
                rowClick.Name = "RowClickArea"
                rowClick.Size = UDim2.fromScale(1, 1)
                rowClick.BackgroundTransparency = 1
                rowClick.Text = ""
                rowClick.AutoButtonColor = false
                rowClick.ZIndex = 4
                rowClick.Parent = row

                local pill = Instance.new("TextButton")
                pill.Size = UDim2.fromOffset(46, 24)
                pill.Position = UDim2.new(1, -56, 0.5, -12)
                pill.BackgroundColor3 = val and Color3.fromHex("#00E5FF") or Color3.fromHex("#1E293B")
                pill.Text = ""
                pill.AutoButtonColor = false
                pill.ZIndex = 5
                pill.Parent = row

                local pillCorner = Instance.new("UICorner")
                pillCorner.CornerRadius = UDim.new(1, 0)
                pillCorner.Parent = pill

                local knob = Instance.new("Frame")
                knob.Size = UDim2.fromOffset(18, 18)
                knob.Position = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                knob.BackgroundColor3 = Color3.fromHex("#FFFFFF")
                knob.BorderSizePixel = 0
                knob.ZIndex = 6
                knob.Parent = pill

                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = knob

                local function updateToggle(selfOrVal, maybeVal)
                    local newVal = selfOrVal
                    if (type(selfOrVal) == "table" and (selfOrVal.Row ~= nil or selfOrVal.SetValue ~= nil)) or maybeVal ~= nil then
                        newVal = maybeVal
                    end
                    val = (newVal == true)
                    local targetColor = val and Color3.fromHex("#00E5FF") or Color3.fromHex("#1E293B")
                    local targetPos = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                    TweenService:Create(pill, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { BackgroundColor3 = targetColor }):Play()
                    TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart), { Position = targetPos }):Play()
                    task.spawn(callback, val)
                end

                rowClick.MouseButton1Click:Connect(function()
                    updateToggle(not val)
                end)
                pill.MouseButton1Click:Connect(function()
                    updateToggle(not val)
                end)

                rowClick.MouseEnter:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromHex("#0E2342"),
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                rowClick.MouseLeave:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromHex("#08182E"),
                        BackgroundTransparency = 0.2
                    }):Play()
                end)

                local toggleObj = {
                    SetValue = updateToggle,
                    GetValue = function() return val end,
                    Row = row
                }
                toggleObj.Set = toggleObj.SetValue
                return toggleObj
            end

            -- 2. SLIDER (Draggable Track + Number Badge)
            function Section:Slider(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Slider"
                local desc = cfg.Desc or ""
                local icon = cfg.Icon or "sliders-horizontal"
                local minVal = cfg.Min or 0
                local maxVal = cfg.Max or 100
                local curVal = cfg.Default or minVal
                if type(cfg.Value) == "table" then
                    minVal = cfg.Value.Min or minVal
                    maxVal = cfg.Value.Max or maxVal
                    curVal = cfg.Value.Default or cfg.Value.Value or curVal
                elseif type(cfg.Value) == "number" then
                    curVal = cfg.Value
                end
                local step = cfg.Step or 1
                local callback = cfg.Callback or function() end

                local row = makeRow(52)
                makeRowIcon(row, icon)
                makeRowTexts(row, title, desc, 190)

                -- Numeric Readout
                local numBadge = Instance.new("TextLabel")
                numBadge.Size = UDim2.fromOffset(45, 20)
                numBadge.Position = UDim2.new(1, -190, 0.5, -10)
                numBadge.BackgroundColor3 = Color3.fromHex("#0B1C33")
                numBadge.Text = tostring(curVal)
                numBadge.Font = Enum.Font.GothamBold
                numBadge.TextSize = 11
                numBadge.TextColor3 = Color3.fromHex("#00E5FF")
                numBadge.ZIndex = 5
                numBadge.Parent = row
                local nbc = Instance.new("UICorner")
                nbc.CornerRadius = UDim.new(0, 6)
                nbc.Parent = numBadge

                -- Slider Hit Area (Generous touch/click box)
                local hitArea = Instance.new("TextButton")
                hitArea.Name = "SliderHitArea"
                hitArea.Size = UDim2.fromOffset(140, 36)
                hitArea.Position = UDim2.new(1, -145, 0.5, -18)
                hitArea.BackgroundTransparency = 1
                hitArea.Text = ""
                hitArea.AutoButtonColor = false
                hitArea.ZIndex = 6
                hitArea.Parent = row

                -- Visual Slider Track
                local track = Instance.new("Frame")
                track.Size = UDim2.new(1, -10, 0, 6)
                track.Position = UDim2.new(0, 5, 0.5, -3)
                track.BackgroundColor3 = Color3.fromHex("#0F1E36")
                track.BorderSizePixel = 0
                track.ZIndex = 6
                track.Parent = hitArea

                local tc = Instance.new("UICorner")
                tc.CornerRadius = UDim.new(1, 0)
                tc.Parent = track

                local fill = Instance.new("Frame")
                local pct = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
                fill.Size = UDim2.new(pct, 0, 1, 0)
                fill.BackgroundColor3 = Color3.fromHex("#00E5FF")
                fill.BorderSizePixel = 0
                fill.ZIndex = 7
                fill.Parent = track
                local fc = Instance.new("UICorner")
                fc.CornerRadius = UDim.new(1, 0)
                fc.Parent = fill

                local thumb = Instance.new("Frame")
                thumb.Size = UDim2.fromOffset(16, 16)
                thumb.AnchorPoint = Vector2.new(0.5, 0.5)
                thumb.Position = UDim2.new(pct, 0, 0.5, 0)
                thumb.BackgroundColor3 = Color3.fromHex("#FFFFFF")
                thumb.BorderSizePixel = 0
                thumb.ZIndex = 8
                thumb.Parent = track
                local thCorner = Instance.new("UICorner")
                thCorner.CornerRadius = UDim.new(1, 0)
                thCorner.Parent = thumb

                local sliding = false
                local function updateFromPos(x)
                    local trackX = track.AbsolutePosition.X
                    local trackW = track.AbsoluteSize.X
                    if trackW <= 0 then return end
                    local alpha = math.clamp((x - trackX) / trackW, 0, 1)
                    local rawVal = minVal + (alpha * (maxVal - minVal))
                    local val
                    if step and step > 0 then
                        val = math.round((rawVal - minVal) / step) * step + minVal
                        val = math.clamp(val, minVal, maxVal)
                        if step < 1 then val = math.round(val * 100) / 100 else val = math.round(val) end
                    else
                        val = (maxVal - minVal > 20) and math.round(rawVal) or (math.round(rawVal * 100) / 100)
                    end
                    curVal = val
                    numBadge.Text = tostring(val)
                    fill.Size = UDim2.new(alpha, 0, 1, 0)
                    thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
                    task.spawn(callback, val)
                end

                hitArea.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = true
                        updateFromPos(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        sliding = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateFromPos(input.Position.X)
                    end
                end)

                local sliderObj = {
                    SetValue = function(selfOrVal, maybeVal)
                        local v = selfOrVal
                        if (type(selfOrVal) == "table" and (selfOrVal.Row ~= nil or selfOrVal.SetValue ~= nil)) or maybeVal ~= nil then
                            v = maybeVal
                        end
                        if type(v) ~= "number" then return end
                        curVal = math.clamp(v, minVal, maxVal)
                        local alpha = (maxVal > minVal) and ((curVal - minVal) / (maxVal - minVal)) or 0
                        numBadge.Text = tostring(curVal)
                        fill.Size = UDim2.new(alpha, 0, 1, 0)
                        thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
                        task.spawn(callback, curVal)
                    end,
                    GetValue = function() return curVal end,
                    Row = row
                }
                sliderObj.Set = sliderObj.SetValue
                return sliderObj
            end

            -- 3. DROPDOWN (Sleek Accordion Tray - Supports Single & Multi Selection)
            function Section:Dropdown(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Dropdown"
                local desc = cfg.Desc or ""
                local icon = cfg.Icon or "chevron-up"
                local values = cfg.Values or cfg.Options or {}
                local isMulti = cfg.Multi or cfg.MultiSelect or false
                local curVal = cfg.Value or cfg.Default
                if isMulti then
                    local map = {}
                    if type(curVal) == "table" then
                        for k, v in pairs(curVal) do
                            if type(k) == "number" and type(v) == "string" then
                                map[v] = true
                            elseif type(k) == "string" and (v == true or v == 1) then
                                map[k] = true
                            end
                        end
                    elseif type(curVal) == "string" and curVal ~= "" then
                        map[curVal] = true
                    end
                    curVal = map
                else
                    curVal = curVal or values[1] or ""
                end
                local callback = cfg.Callback or function() end

                local closedHeight = 52
                local maxVisibleItems = 6
                local itemHeight = 30
                local trayHeight = math.clamp(#values * (itemHeight + 4), 34, maxVisibleItems * (itemHeight + 4))
                local openHeight = closedHeight + trayHeight + 16

                local row = makeRow(closedHeight)
                row.ClipsDescendants = true

                -- Header Button (Fixed 52px top bar)
                local header = Instance.new("TextButton")
                header.Name = "Header"
                header.Size = UDim2.new(1, 0, 0, closedHeight)
                header.Position = UDim2.new(0, 0, 0, 0)
                header.BackgroundTransparency = 1
                header.Text = ""
                header.AutoButtonColor = false
                header.Parent = row

                makeRowIcon(header, icon)
                makeRowTexts(header, title, desc, 195)

                local dropBtn = Instance.new("TextButton")
                dropBtn.Name = "SelectorBadge"
                dropBtn.Size = UDim2.fromOffset(185, 30)
                dropBtn.Position = UDim2.new(1, -195, 0.5, -15)
                dropBtn.BackgroundColor3 = Color3.fromHex("#081A33")
                dropBtn.BackgroundTransparency = 0.2
                dropBtn.Text = ""
                dropBtn.AutoButtonColor = false
                dropBtn.Parent = header

                local dc = Instance.new("UICorner")
                dc.CornerRadius = UDim.new(0, 8)
                dc.Parent = dropBtn

                local ds = Instance.new("UIStroke")
                ds.Color = Color3.fromHex("#00E5FF")
                ds.Thickness = 1.2
                ds.Transparency = 0.6
                ds.Parent = dropBtn

                local function getDisplayText()
                    if not isMulti then return tostring(curVal) end
                    local count = 0
                    local selList = {}
                    for _, opt in ipairs(values) do
                        if curVal[opt] == true then
                            count = count + 1
                            table.insert(selList, opt)
                        end
                    end
                    for k, v in pairs(curVal) do
                        if v == true and not table.find(values, k) then
                            count = count + 1
                            table.insert(selList, k)
                        end
                    end
                    if count == 0 then
                        return "None Selected"
                    elseif count == 1 then
                        return selList[1]
                    elseif count == 2 then
                        return selList[1] .. ", " .. selList[2]
                    else
                        return tostring(count) .. " Selected"
                    end
                end

                local lbl = Instance.new("TextLabel")
                lbl.Text = getDisplayText()
                lbl.Font = Enum.Font.GothamMedium
                lbl.TextSize = 11
                lbl.TextColor3 = Color3.fromHex("#F1F5F9")
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.Size = UDim2.new(1, -26, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Parent = dropBtn

                local arrow = Instance.new("TextLabel")
                arrow.Text = "▾"
                arrow.Font = Enum.Font.GothamBold
                arrow.TextSize = 14
                arrow.TextColor3 = Color3.fromHex("#00E5FF")
                arrow.Size = UDim2.fromOffset(20, 30)
                arrow.Position = UDim2.new(1, -22, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.Parent = dropBtn

                -- Subtle Divider Line when opened
                local divider = Instance.new("Frame")
                divider.Name = "Divider"
                divider.Size = UDim2.new(1, -20, 0, 1)
                divider.Position = UDim2.new(0, 10, 0, 51)
                divider.BackgroundColor3 = Color3.fromHex("#00E5FF")
                divider.BackgroundTransparency = 0.8
                divider.BorderSizePixel = 0
                divider.Visible = false
                divider.Parent = row

                -- In-flow Options Tray (ScrollingFrame)
                local tray = Instance.new("ScrollingFrame")
                tray.Name = "OptionsTray"
                tray.Size = UDim2.new(1, -20, 0, trayHeight)
                tray.Position = UDim2.new(0, 10, 0, 58)
                tray.BackgroundTransparency = 1
                tray.BorderSizePixel = 0
                tray.ScrollBarThickness = 2
                tray.ScrollBarImageColor3 = Color3.fromHex("#00E5FF")
                tray.CanvasSize = UDim2.new(0, 0, 0, 0)
                tray.AutomaticCanvasSize = Enum.AutomaticSize.Y
                tray.Visible = false
                tray.Parent = row

                local trayLayout = Instance.new("UIListLayout")
                trayLayout.FillDirection = Enum.FillDirection.Vertical
                trayLayout.Padding = UDim.new(0, 4)
                trayLayout.SortOrder = Enum.SortOrder.LayoutOrder
                trayLayout.Parent = tray

                local optionButtons = {}
                local function updateSelectionHighlight()
                    for _, item in ipairs(optionButtons) do
                        local isSel = false
                        if isMulti then
                            isSel = (curVal[item.Value] == true)
                        else
                            isSel = (item.Value == curVal)
                        end

                        item.Btn.BackgroundColor3 = isSel and Color3.fromHex("#0284C7") or Color3.fromHex("#061528")
                        item.Btn.BackgroundTransparency = isSel and 0.15 or 0.4
                        item.Btn.TextColor3 = isSel and Color3.fromHex("#00FFFF") or Color3.fromHex("#CBD5E1")
                        item.Btn.Text = (isSel and " ✓  " or "    ") .. tostring(item.Value)
                        local s = item.Btn:FindFirstChildWhichIsA("UIStroke")
                        if s then
                            s.Color = isSel and Color3.fromHex("#00FFFF") or Color3.fromHex("#00E5FF")
                            s.Transparency = isSel and 0.3 or 0.85
                        end
                    end
                end

                local isOpen = false
                local lastToggle = 0
                local function toggleMenu()
                    local now = os.clock()
                    if now - lastToggle < 0.15 then return end
                    lastToggle = now
                    isOpen = not isOpen
                    arrow.Text = isOpen and "▴" or "▾"
                    divider.Visible = isOpen
                    tray.Visible = isOpen

                    local targetH = isOpen and openHeight or closedHeight
                    TweenService:Create(row, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Size = UDim2.new(1, 0, 0, targetH)
                    }):Play()

                    if isOpen then
                        updateSelectionHighlight()
                    end
                end

                header.MouseButton1Click:Connect(toggleMenu)
                dropBtn.MouseButton1Click:Connect(toggleMenu)

                local function renderOptions(newValues)
                    values = newValues or {}
                    for _, item in ipairs(optionButtons) do
                        pcall(function() item.Btn:Destroy() end)
                    end
                    table.clear(optionButtons)

                    trayHeight = math.clamp(#values * (itemHeight + 4), 34, maxVisibleItems * (itemHeight + 4))
                    openHeight = closedHeight + trayHeight + 16
                    tray.Size = UDim2.new(1, -20, 0, trayHeight)
                    if isOpen then
                        row.Size = UDim2.new(1, 0, 0, openHeight)
                    end

                    for _, opt in ipairs(values) do
                        local isSel = false
                        if isMulti then
                            isSel = (curVal[opt] == true)
                        else
                            isSel = (opt == curVal)
                        end

                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, -4, 0, itemHeight)
                        optBtn.BackgroundColor3 = isSel and Color3.fromHex("#0284C7") or Color3.fromHex("#061528")
                        optBtn.BackgroundTransparency = isSel and 0.15 or 0.4
                        optBtn.Text = (isSel and " ✓  " or "    ") .. tostring(opt)
                        optBtn.Font = Enum.Font.GothamMedium
                        optBtn.TextSize = 12
                        optBtn.TextColor3 = isSel and Color3.fromHex("#00FFFF") or Color3.fromHex("#CBD5E1")
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.AutoButtonColor = false
                        optBtn.Parent = tray

                        local oc = Instance.new("UICorner")
                        oc.CornerRadius = UDim.new(0, 6)
                        oc.Parent = optBtn

                        local os = Instance.new("UIStroke")
                        os.Color = isSel and Color3.fromHex("#00FFFF") or Color3.fromHex("#00E5FF")
                        os.Thickness = 1
                        os.Transparency = isSel and 0.3 or 0.85
                        os.Parent = optBtn

                        table.insert(optionButtons, { Btn = optBtn, Value = opt })

                        optBtn.MouseEnter:Connect(function()
                            local currentlySel = isMulti and (curVal[opt] == true) or (opt == curVal)
                            if not currentlySel then
                                TweenService:Create(optBtn, TweenInfo.new(0.15), {
                                    BackgroundColor3 = Color3.fromHex("#0D2545"),
                                    TextColor3 = Color3.fromHex("#FFFFFF")
                                }):Play()
                            end
                        end)

                        optBtn.MouseLeave:Connect(function()
                            local currentlySel = isMulti and (curVal[opt] == true) or (opt == curVal)
                            if not currentlySel then
                                TweenService:Create(optBtn, TweenInfo.new(0.15), {
                                    BackgroundColor3 = Color3.fromHex("#061528"),
                                    TextColor3 = Color3.fromHex("#CBD5E1")
                                }):Play()
                            end
                        end)

                        optBtn.MouseButton1Click:Connect(function()
                            if isMulti then
                                curVal[opt] = not curVal[opt]
                                if not curVal[opt] then curVal[opt] = nil end
                                lbl.Text = getDisplayText()
                                updateSelectionHighlight()
                                task.spawn(callback, curVal)
                            else
                                curVal = opt
                                lbl.Text = tostring(curVal)
                                updateSelectionHighlight()
                                toggleMenu()
                                task.spawn(callback, curVal)
                            end
                        end)
                    end
                end

                renderOptions(values)

                local dropObj = {
                    SetValue = function(selfOrVal, maybeVal)
                        local v = selfOrVal
                        if (type(selfOrVal) == "table" and (selfOrVal.Row ~= nil or selfOrVal.SetValues ~= nil)) or maybeVal ~= nil then
                            v = maybeVal
                        end
                        if isMulti then
                            curVal = {}
                            if type(v) == "table" then
                                for k, val in pairs(v) do
                                    if type(k) == "number" and type(val) == "string" then
                                        curVal[val] = true
                                    elseif type(k) == "string" and (val == true or val == 1) then
                                        curVal[k] = true
                                    end
                                end
                            elseif type(v) == "string" and v ~= "" then
                                curVal[v] = true
                            end
                            lbl.Text = getDisplayText()
                        else
                            if v ~= nil then
                                curVal = tostring(v)
                                lbl.Text = tostring(v)
                            end
                        end
                        updateSelectionHighlight()
                        task.spawn(callback, curVal)
                    end,
                    SetValues = renderOptions,
                    GetValue = function() return curVal end,
                    Row = row
                }
                dropObj.Set = dropObj.SetValue
                dropObj.Select = dropObj.SetValue
                dropObj.Refresh = dropObj.SetValues
                return dropObj
            end

            -- 4. BUTTON (Interactive Action Card)
            function Section:Button(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Button"
                local desc = cfg.Desc or ""
                local icon = cfg.Icon or "zap"
                local callback = cfg.Callback or function() end

                local row = makeRow(48)
                makeRowIcon(row, icon)
                makeRowTexts(row, title, desc, 80)

                local rowClick = Instance.new("TextButton")
                rowClick.Name = "RowClickArea"
                rowClick.Size = UDim2.fromScale(1, 1)
                rowClick.BackgroundTransparency = 1
                rowClick.Text = ""
                rowClick.AutoButtonColor = false
                rowClick.ZIndex = 4
                rowClick.Parent = row

                local actBtn = Instance.new("TextButton")
                actBtn.Size = UDim2.fromOffset(72, 28)
                actBtn.Position = UDim2.new(1, -82, 0.5, -14)
                actBtn.BackgroundColor3 = Color3.fromHex("#0284C7")
                actBtn.BackgroundTransparency = 0.2
                actBtn.Text = "RUN"
                actBtn.Font = Enum.Font.GothamBold
                actBtn.TextSize = 11
                actBtn.TextColor3 = Color3.fromHex("#FFFFFF")
                actBtn.AutoButtonColor = false
                actBtn.ZIndex = 5
                actBtn.Parent = row

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 8)
                ac.Parent = actBtn

                local as = Instance.new("UIStroke")
                as.Color = Color3.fromHex("#00E5FF")
                as.Thickness = 1.2
                as.Parent = actBtn

                local function fireAction()
                    TweenService:Create(actBtn, TweenInfo.new(0.08), { Size = UDim2.fromOffset(66, 25), BackgroundColor3 = Color3.fromHex("#00E5FF"), TextColor3 = Color3.fromHex("#020617") }):Play()
                    task.wait(0.08)
                    TweenService:Create(actBtn, TweenInfo.new(0.12), { Size = UDim2.fromOffset(72, 28), BackgroundColor3 = Color3.fromHex("#0284C7"), TextColor3 = Color3.fromHex("#FFFFFF") }):Play()
                    task.spawn(callback)
                end

                actBtn.MouseEnter:Connect(function()
                    TweenService:Create(actBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromHex("#00E5FF") }):Play()
                    TweenService:Create(actBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromHex("#020617") }):Play()
                end)
                actBtn.MouseLeave:Connect(function()
                    TweenService:Create(actBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromHex("#0284C7") }):Play()
                    TweenService:Create(actBtn, TweenInfo.new(0.15), { TextColor3 = Color3.fromHex("#FFFFFF") }):Play()
                end)

                rowClick.MouseEnter:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromHex("#0E2342"),
                        BackgroundTransparency = 0.1
                    }):Play()
                end)
                rowClick.MouseLeave:Connect(function()
                    TweenService:Create(row, TweenInfo.new(0.15), {
                        BackgroundColor3 = Color3.fromHex("#08182E"),
                        BackgroundTransparency = 0.2
                    }):Play()
                end)

                rowClick.MouseButton1Click:Connect(fireAction)
                actBtn.MouseButton1Click:Connect(fireAction)

                return { Button = actBtn, Row = row }
            end

            -- 5. PARAGRAPH (Live Stat Readout)
            function Section:Paragraph(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Info"
                local icon = cfg.Icon or "activity"

                local row = makeRow(42)
                makeRowIcon(row, icon)

                local tLbl = Instance.new("TextLabel")
                tLbl.Text = title
                tLbl.Font = Enum.Font.GothamBold
                tLbl.TextSize = 13
                tLbl.TextColor3 = Color3.fromHex("#00E5FF")
                tLbl.TextXAlignment = Enum.TextXAlignment.Left
                tLbl.TextYAlignment = Enum.TextYAlignment.Center
                tLbl.Size = UDim2.new(1, -56, 1, 0)
                tLbl.Position = UDim2.new(0, 48, 0, 0)
                tLbl.BackgroundTransparency = 1
                tLbl.Parent = row

                local function setTitle(selfOrText, maybeText)
                    local text = (type(selfOrText) == "table" and maybeText) or selfOrText
                    tLbl.Text = tostring(text or "")
                end

                return {
                    Set = function(_, newCfg)
                        if type(newCfg) == "table" then
                            if newCfg.Title then setTitle(newCfg.Title) end
                        else
                            setTitle(newCfg)
                        end
                    end,
                    SetTitle = setTitle,
                    SetDesc = function(_, d) if d and d ~= "" then setTitle(d) end end,
                    SetContent = function(_, d) if d and d ~= "" then setTitle(d) end end,
                    TitleLabel = tLbl,
                    Row = row
                }
            end

            -- 6. INPUT (Text Box / Config Input)
            function Section:Input(cfg)
                cfg = cfg or {}
                local title = cfg.Title or "Input"
                local desc = cfg.Desc or ""
                local icon = cfg.Icon or "pencil"
                local placeholder = cfg.Placeholder or "Enter text..."
                local default = cfg.Default or ""
                local callback = cfg.Callback or function() end

                local row = makeRow(52)
                makeRowIcon(row, icon)
                makeRowTexts(row, title, desc, 160)

                local boxContainer = Instance.new("Frame")
                boxContainer.Size = UDim2.fromOffset(145, 30)
                boxContainer.Position = UDim2.new(1, -155, 0.5, -15)
                boxContainer.BackgroundColor3 = Color3.fromHex("#081A33")
                boxContainer.BackgroundTransparency = 0.2
                boxContainer.Parent = row

                local bc = Instance.new("UICorner")
                bc.CornerRadius = UDim.new(0, 8)
                bc.Parent = boxContainer

                local bs = Instance.new("UIStroke")
                bs.Color = Color3.fromHex("#00E5FF")
                bs.Thickness = 1.2
                bs.Transparency = 0.6
                bs.Parent = boxContainer

                local tBox = Instance.new("TextBox")
                tBox.Size = UDim2.new(1, -16, 1, 0)
                tBox.Position = UDim2.new(0, 8, 0, 0)
                tBox.BackgroundTransparency = 1
                tBox.Text = default
                tBox.PlaceholderText = placeholder
                tBox.PlaceholderColor3 = Color3.fromHex("#64748B")
                tBox.Font = Enum.Font.GothamBold
                tBox.TextSize = 11
                tBox.TextColor3 = Color3.fromHex("#FFFFFF")
                tBox.ClearTextOnFocus = false
                tBox.TextXAlignment = Enum.TextXAlignment.Left
                tBox.Parent = boxContainer

                tBox.FocusLost:Connect(function(enterPressed)
                    task.spawn(callback, tBox.Text, enterPressed)
                end)

                return {
                    GetValue = function() return tBox.Text end,
                    SetValue = function(selfOrVal, maybeVal)
                        local v = selfOrVal
                        if (type(selfOrVal) == "table" and (selfOrVal.Row ~= nil or selfOrVal.TextBox ~= nil)) or maybeVal ~= nil then
                            v = maybeVal
                        end
                        tBox.Text = tostring(v or "")
                    end,
                    TextBox = tBox,
                    Row = row
                }
            end

            -- Pass-through aliases directly onto Tab if preferred
            Tab.Toggle = function(_, c) return Section:Toggle(c) end
            Tab.Slider = function(_, c) return Section:Slider(c) end
            Tab.Dropdown = function(_, c) return Section:Dropdown(c) end
            Tab.Button = function(_, c) return Section:Button(c) end
            Tab.Paragraph = function(_, c) return Section:Paragraph(c) end
            Tab.Input = function(_, c) return Section:Input(c) end

            return Section
        end

        table.insert(self.Tabs, Tab)
        if #self.Tabs == 1 then
            Tab:Select()
        end
        return Tab
    end

    function Window:SelectTab(idx)
        if typeof(idx) == "number" and self.Tabs[idx] then
            self.Tabs[idx]:Select()
        elseif typeof(idx) == "string" then
            for _, t in ipairs(self.Tabs) do
                if t.Title == idx then t:Select() break end
            end
        end
    end

    -- ─────────────────────────────────────────────────────────
    -- FLOATING LOGO TOGGLE BADGE (CYBER AURA + NEON GRADIENT)
    -- ─────────────────────────────────────────────────────────
    local floatGui = Instance.new("ScreenGui")
    floatGui.Name = "TwoK_Pyramid_Float"
    floatGui.ResetOnSpawn = false
    floatGui.Parent = container

    local auraFrame = Instance.new("Frame")
    auraFrame.Name = "AuraRing"
    auraFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    auraFrame.Size = UDim2.fromOffset(62, 62)
    auraFrame.Position = UDim2.new(0, 46, 0.45, 0)
    auraFrame.BackgroundColor3 = Color3.fromHex("#00E5FF")
    auraFrame.BackgroundTransparency = 0.82
    auraFrame.BorderSizePixel = 0
    auraFrame.Parent = floatGui

    local auraCorner = Instance.new("UICorner")
    auraCorner.CornerRadius = UDim.new(0, 20)
    auraCorner.Parent = auraFrame

    local auraStroke = Instance.new("UIStroke")
    auraStroke.Color = Color3.fromHex("#00D4FF")
    auraStroke.Thickness = 1.2
    auraStroke.Transparency = 0.65
    auraStroke.Parent = auraFrame

    local panelFrame = Instance.new("Frame")
    panelFrame.Name = "LogoPanel"
    panelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    panelFrame.Size = UDim2.fromOffset(52, 52)
    panelFrame.Position = UDim2.new(0, 46, 0.45, 0)
    panelFrame.BackgroundColor3 = Color3.fromHex("#060E18")
    panelFrame.BackgroundTransparency = 0.15
    panelFrame.BorderSizePixel = 0
    panelFrame.Parent = floatGui

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, 16)
    panelCorner.Parent = panelFrame

    local panelStroke = Instance.new("UIStroke")
    panelStroke.Color = Color3.fromHex("#00E5FF")
    panelStroke.Thickness = 2.2
    panelStroke.Parent = panelFrame

    local panelGrad = Instance.new("UIGradient")
    panelGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromHex("#00E5FF")),
        ColorSequenceKeypoint.new(0.35, Color3.fromHex("#0077FE")),
        ColorSequenceKeypoint.new(0.70, Color3.fromHex("#38BDF8")),
        ColorSequenceKeypoint.new(1.00, Color3.fromHex("#00E5FF"))
    })
    panelGrad.Parent = panelStroke

    local floatBtn = Instance.new("ImageButton")
    floatBtn.Name = "OpenButton"
    floatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    floatBtn.Size = UDim2.fromOffset(40, 40)
    floatBtn.Position = UDim2.fromScale(0.5, 0.5)
    floatBtn.BackgroundTransparency = 1
    floatBtn.Image = "rbxassetid://10723346959"
    floatBtn.ImageColor3 = Color3.fromHex("#00E5FF")
    floatBtn.Parent = panelFrame

    task.spawn(function()
        local logoAsset = ensureAsset("2k_logo.png", "https://raw.githubusercontent.com/hxrendontcry/2kscripts/main/assets/2k_logo.png")
        if logoAsset then
            floatBtn.Image = logoAsset
            floatBtn.ImageColor3 = Color3.new(1, 1, 1)
        end
    end)

    -- Draggable Floating Badge
    local fDragging, fDragStart, fStartPos
    local function onFloatDragStart(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            fDragging = true
            fDragStart = input.Position
            fStartPos = panelFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then fDragging = false end
            end)
        end
    end
    panelFrame.InputBegan:Connect(onFloatDragStart)
    floatBtn.InputBegan:Connect(onFloatDragStart)

    UserInputService.InputChanged:Connect(function(input)
        if fDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - fDragStart
            local newPos = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
            panelFrame.Position = newPos
            auraFrame.Position = newPos
        end
    end)

    floatBtn.MouseButton1Click:Connect(function()
        Window:Toggle()
    end)

    -- Keybind Toggle
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Keybind then
            Window:Toggle()
        end
    end)

    -- Continuous Cyber Render Loop
    local animConn = RunService.RenderStepped:Connect(function()
        local t = tick()
        -- Main window border sweep
        strokeGrad.Rotation = (t * 50) % 360
        -- Floating logo border sweep
        panelGrad.Rotation = (t * 110) % 360
        -- Floating aura breathing pulse
        local breath = (math.sin(t * 3.2) + 1) * 0.5
        local auraSize = 60 + (breath * 10)
        auraFrame.Size = UDim2.fromOffset(auraSize, auraSize)
        auraFrame.BackgroundTransparency = 0.80 + (breath * 0.12)
        -- Subtle logo bobbing inside badge
        floatBtn.Position = UDim2.new(0.5, 0, 0.5, math.sin(t * 2.8) * 1.5)
    end)

    Window.AnimationConnection = animConn
    Window.FloatGui = floatGui

    function Window:Notify(notifCfg)
        notifCfg = notifCfg or {}
        local nTitle = notifCfg.Title or "2K SCRIPT"
        local nContent = notifCfg.Content or ""
        local nDuration = notifCfg.Duration or 4

        local notifFrame = Instance.new("Frame")
        notifFrame.Size = UDim2.fromOffset(280, 56)
        notifFrame.AnchorPoint = Vector2.new(1, 1)
        notifFrame.Position = UDim2.new(1, -20, 1, 80)
        notifFrame.BackgroundColor3 = Color3.fromHex("#061226")
        notifFrame.BackgroundTransparency = 0.15
        notifFrame.Parent = screenGui

        local nc = Instance.new("UICorner")
        nc.CornerRadius = UDim.new(0, 10)
        nc.Parent = notifFrame
        local ns = Instance.new("UIStroke")
        ns.Color = Color3.fromHex("#00E5FF")
        ns.Thickness = 1.4
        ns.Parent = notifFrame

        local nt = Instance.new("TextLabel")
        nt.Text = nTitle
        nt.Font = Enum.Font.GothamBold
        nt.TextSize = 13
        nt.TextColor3 = Color3.fromHex("#00E5FF")
        nt.TextXAlignment = Enum.TextXAlignment.Left
        nt.Size = UDim2.new(1, -20, 0, 18)
        nt.Position = UDim2.new(0, 12, 0, 8)
        nt.BackgroundTransparency = 1
        nt.Parent = notifFrame

        local nd = Instance.new("TextLabel")
        nd.Text = nContent
        nd.Font = Enum.Font.Gotham
        nd.TextSize = 11
        nd.TextColor3 = Color3.fromHex("#E2E8F0")
        nd.TextXAlignment = Enum.TextXAlignment.Left
        nd.TextTruncate = Enum.TextTruncate.AtEnd
        nd.Size = UDim2.new(1, -20, 0, 18)
        nd.Position = UDim2.new(0, 12, 0, 28)
        nd.BackgroundTransparency = 1
        nd.Parent = notifFrame

        TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -20, 1, -20)
        }):Play()

        task.delay(nDuration, function()
            local tw = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -20, 1, 80)
            })
            tw:Play()
            tw.Completed:Connect(function()
                notifFrame:Destroy()
            end)
        end)
    end

    table.insert(self.Windows, Window)
    self.ActiveWindow = Window
    return Window
end

function TwoKUI:Notify(cfg)
    if self.ActiveWindow and self.ActiveWindow.Notify then
        return self.ActiveWindow:Notify(cfg)
    end
end

function TwoKUI:SetTheme(_)
    -- Custom Theme Switcher
end

return TwoKUI

end)()

-- ─────────────────────────────────────────────────────────────
-- // 4. WINDOW & TABS
-- ─────────────────────────────────────────────────────────────

local Window = TwoKUI:CreateWindow({
    Title = "2K SCRIPT",
    SubTitle = "PIXEL LINEAGE • AUTO FARM",
    Keybind = Enum.KeyCode.RightControl,
    Size = UDim2.fromOffset(880, 520),
})
UI.notify = function(title, content, dur)
    Window:Notify({ Title = title, Content = content, Duration = dur or 4 })
end

-- label <-> id tables keep the persisted config language-independent
local function choiceMap(pairsList)
    local labels, toId, toLabel = {}, {}, {}
    for _, p in ipairs(pairsList) do
        labels[#labels + 1] = p[2]
        toId[p[2]] = p[1]
        toLabel[p[1]] = p[2]
    end
    return labels, toId, toLabel
end

local DIFF_L, DIFF_ID, DIFF_LB = choiceMap({
    { "normal", "Normal" },
    { "hard", "Hard" },
    { "nightmare", "Nightmare" },
    { "torment", "Torment" },
})
local END_L, END_ID, END_LB = choiceMap({
    { "replay", "Play Again" },
    { "next", "Next Torment Tier (if available)" },
    { "home", "Return to Village" },
    { "off", "Do Nothing" },
})
local PATH_L, PATH_ID, PATH_LB = choiceMap({
    { "balanced", "Balanced (loot and safety)" },
    { "loot", "Loot (treasure and elites)" },
    { "safe", "Safe (rest and shops)" },
})
local TGT_L, TGT_ID, TGT_LB = choiceMap({
    { "lowest", "Lowest HP First" },
    { "boss", "Boss First" },
    { "first", "First in Line" },
})

-- Dungeon choices are read from the live game modules when available. The
-- fallbacks keep the controls usable while those modules are still loading.
local ACT_L = {}
if RunConfig and type(RunConfig.Acts) == "table" then
    for i, _ in ipairs(RunConfig.Acts) do
        ACT_L[i] = string.format("Act-%02d", i)
    end
end
if #ACT_L == 0 then ACT_L[1] = "Act-01" end
local MOD_L, MOD_ID, MOD_LB = {}, {}, {}
if RunModifiers and type(RunModifiers.List) == "table" then
    for _, modifier in ipairs(RunModifiers.List) do
        if type(modifier) == "table" and modifier.id ~= nil then
            local id = tostring(modifier.id)
            local label = tostring(modifier.name or id)
            if id == "none" then label = "None" end
            if MOD_ID[label] then label = label .. " (" .. id .. ")" end
            MOD_L[#MOD_L + 1] = label
            MOD_ID[label] = id
            MOD_LB[id] = label
        end
    end
end
if #MOD_L == 0 then
    MOD_L, MOD_ID, MOD_LB = { "None" }, { None = "none" }, { none = "None" }
end

-- Character Select is a native game screen. Slot options are populated only
-- from visible, active slot buttons, so locked/purchase/create cards never
-- become selectable by the hub.
local slotDrop
local slotBusy = false
local slotScan = { total = 0, available = {}, locked = {}, pending = {} }
local function slotGate()
    local pg = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local ui = pg and pg:FindFirstChild("PlatformBattlesUI")
    local root = ui and ui:FindFirstChild("Root")
    return root and root:FindFirstChild("ProfileGate")
end
local function activateNative(button)
    if not (button and button:IsA("GuiButton") and button.Visible and button.Active) then return false end
    if firesignal then
        local ok = pcall(firesignal, button.Activated)
        if ok then return true end
    end
    if getconnections then
        local ok, connections = pcall(getconnections, button.Activated)
        if ok then
            for _, connection in ipairs(connections or {}) do
                if connection.Enabled and connection.Fire and pcall(function() connection:Fire() end) then
                    return true
                end
            end
        end
    end
    return false
end
local function scanCharacterSlots(slotsPage)
    local result = { total = 0, available = {}, locked = {}, pending = {} }
    local window = slotsPage and slotsPage:FindFirstChild("SlotsWindow")
    local inner = window and window:FindFirstChild("Inner")
    local cards = inner and inner:FindFirstChild("SlotCards")
    if not cards then slotScan = result; return result end
    for _, card in ipairs(cards:GetChildren()) do
        local number = tonumber(tostring(card.Name):match("^Slot(%d+)$"))
        if number then
            result.total += 1
            local cardInner = card:FindFirstChild("Inner")
            local action = cardInner and cardInner:FindFirstChild("Action")
            local text = action and tostring(action.Text or ""):upper() or ""
            if text:find("UNLOCK", 1, true) or text:find("LOCKED", 1, true) or text:find("R$", 1, true) then
                result.locked[number] = text
            elseif text == "" or text:find("CREATE", 1, true) or text:find("CREATION", 1, true) then
                result.pending[number] = text
            elseif action and action.Visible and action.Active then
                result.available[number] = text
            else
                result.pending[number] = text
            end
        end
    end
    slotScan = result
    return result
end
local function availableSlotLabels(result)
    local out = {}
    result = result or slotScan
    for number in pairs(result.available or {}) do out[#out + 1] = number end
    table.sort(out)
    for i, number in ipairs(out) do out[i] = "Slot " .. tostring(number) end
    return out
end
local function refreshSlotDropdown(result)
    if not slotDrop then return end
    local values = availableSlotLabels(result)
    if #values == 0 then values = { "No available slots" } end
    pcall(function()
        slotDrop.SetValues(values)
        local wanted = "Slot " .. tostring(math.floor(tonumber(Config.Slot) or 1))
        if table.find(values, wanted) then
            slotDrop:SetValue(wanted)
        elseif values[1] ~= "No available slots" then
            Config.Slot = tonumber(values[1]:match("%d+")) or 1
            slotDrop:SetValue(values[1])
        end
    end)
end
local function enterCharacterSlot(number)
    if slotBusy then return false end
    slotBusy = true
    local gate = slotGate()
    if not (gate and gate.Visible) then
        notify("Auto Slot", "Character Select is not open", 3)
        slotBusy = false
        return false
    end
    local slotsPage = gate:FindFirstChild("CharacterSlotsPage")
    if not (slotsPage and slotsPage.Visible) then
        local main = gate:FindFirstChild("MainMenuPage")
        local menu = main and main:FindFirstChild("MainMenu")
        local inner = menu and menu:FindFirstChild("Inner")
        local selectButton = inner and inner:FindFirstChild("CharacterSelect")
        if not activateNative(selectButton) then
            notify("Auto Slot", "Character Select button is unavailable", 3)
            slotBusy = false
            return false
        end
        local deadline = os.clock() + 5
        while alive() and os.clock() < deadline and not (slotsPage and slotsPage.Visible) do task.wait(0.05) end
    end
    local result = scanCharacterSlots(slotsPage)
    refreshSlotDropdown(result)
    if not result.available[number] then
        notify("Auto Slot", "Slot " .. tostring(number) .. " is not available", 3)
        slotBusy = false
        return false
    end
    local window = slotsPage:FindFirstChild("SlotsWindow")
    local inner = window and window:FindFirstChild("Inner")
    local cards = inner and inner:FindFirstChild("SlotCards")
    local card = cards and cards:FindFirstChild("Slot" .. tostring(number))
    local action = card and card:FindFirstChild("Inner") and card.Inner:FindFirstChild("Action")
    local fired = activateNative(action)
    if fired then
        local leaveDeadline = os.clock() + 10
        while alive() and os.clock() < leaveDeadline and gate.Visible do task.wait(0.1) end
    end
    notify("Auto Slot", fired and ("Selected Slot " .. tostring(number)) or "Slot action was unavailable", 3)
    slotBusy = false
    return fired and not gate.Visible
end

-- TAB 1: HOME ----------------------------------------------------------------
local TabMain = Window:Tab({ Title = "Home", Icon = "layout-dashboard" })
local secStatus = TabMain:Section({ Title = "Status", Icon = "activity" })
local pHero = secStatus:Paragraph({ Title = "Loading...", Icon = "user" })
local pBattle = secStatus:Paragraph({ Title = "-", Icon = "swords" })
local pRun = secStatus:Paragraph({ Title = "-", Icon = "map" })
local pStats = secStatus:Paragraph({ Title = "-", Icon = "trophy" })

local secQuick = TabMain:Section({ Title = "Continuous Farming", Icon = "zap" })
local farmUiSyncing = false
local function syncFarmControls(value)
    if farmUiSyncing then return end
    farmUiSyncing = true
    pcall(function() if UI.syncFarm then UI.syncFarm(value) end end)
    pcall(function() if UI.syncStartRun then UI.syncStartRun(value) end end)
    farmUiSyncing = false
end
local farmToggle = secQuick:Toggle({
    Title = "Auto Farm Dungeon (start, fight, finish, repeat)",
    Desc = "Battle, dodge, and minigame automation are already enabled",
    Icon = "repeat",
    Value = Config.Farm,
    Callback = function(v)
        setFlag("Farm", v)
        if v then startLives = lives() end
        syncFarmControls(v)
    end,
})
UI.syncFarm = function(v)
    pcall(function() farmToggle:SetValue(v) end)
end
secQuick:Toggle({
    Title = "Stop Farming on Life Loss",
    Desc = "A dungeon death costs one life; losing the last life sends you to The Light",
    Icon = "heart",
    Value = Config.StopOnLifeLoss,
    Callback = function(v) setFlag("StopOnLifeLoss", v) end,
})

local secSlot = TabMain:Section({ Title = "Character", Icon = "user-round" })
secSlot:Toggle({
    Title = "Auto Slot",
    Desc = "Automatically enter the selected available character slot",
    Icon = "log-in",
    Value = Config.AutoSlot,
    Callback = function(v) setFlag("AutoSlot", v) end,
})
slotDrop = secSlot:Dropdown({
    Title = "Auto Slot",
    Desc = "Only unlocked slots with an active Enter button are listed",
    Icon = "list",
    Values = availableSlotLabels(slotScan),
    Value = availableSlotLabels(slotScan)[1],
    Callback = function(v)
        local number = tonumber(tostring(v):match("%d+"))
        if number and slotScan.available[number] then setFlag("Slot", number) end
    end,
})
if #availableSlotLabels(slotScan) == 0 then refreshSlotDropdown(slotScan) end
secSlot:Button({
    Title = "Select Slot Now",
    Desc = "Enter the selected slot from Character Select",
    Icon = "play",
    Callback = function()
        task.spawn(function() enterCharacterSlot(math.floor(tonumber(Config.Slot) or 1)) end)
    end,
})

task.spawn(function()
    while alive() do
        task.wait(0.5)
        local gate = slotGate()
        if gate and gate.Visible then
            local slotsPage = gate:FindFirstChild("CharacterSlotsPage")
            if slotsPage and slotsPage.Visible then
                local result = scanCharacterSlots(slotsPage)
                refreshSlotDropdown(result)
                if Config.AutoSlot and result.available[math.floor(tonumber(Config.Slot) or 1)] then
                    task.spawn(enterCharacterSlot, math.floor(tonumber(Config.Slot) or 1))
                end
            elseif Config.AutoSlot and not slotBusy then
                task.spawn(enterCharacterSlot, math.floor(tonumber(Config.Slot) or 1))
            end
        end
    end
end)

-- TAB 2: COMBAT --------------------------------------------------------------
local TabCombat = Window:Tab({ Title = "Combat", Icon = "swords" })
local secDef = TabCombat:Section({ Title = "Combat", Icon = "shield-check" })
secDef:Toggle({
    Title = "Auto Battle Turns",
    Icon = "cpu",
    Value = Config.AutoBattle,
    Callback = function(v) setFlag("AutoBattle", v) end,
})
secDef:Toggle({
    Title = "Perfect Dodge",
    Desc = "Times inputs to the dodge window, including Barrage attacks",
    Icon = "shield",
    Value = Config.AutoDodge,
    Callback = function(v) setFlag("AutoDodge", v) end,
})
secDef:Toggle({
    Title = "Perfect Attack",
    Desc = "Warrior, Mage, Thief, Spear, Fist, Bow, and Bard",
    Icon = "sparkles",
    Value = Config.AutoMinigame,
    Callback = function(v) setFlag("AutoMinigame", v) end,
})
secDef:Toggle({
    Title = "Guard During Boss Brace",
    Icon = "shield-alert",
    Value = Config.BraceGuard,
    Callback = function(v) setFlag("BraceGuard", v) end,
})

local secAI = TabCombat:Section({ Title = "Skill Set-up", Icon = "cpu" })
secAI:Toggle({
    Title = "Auto Use Skill",
    Desc = "Off: use basic attacks only",
    Icon = "sparkles",
    Value = Config.AutoSkill,
    Callback = function(v) setFlag("AutoSkill", v) end,
})

-- labels are skill names; the config keeps ids so renames don't break picks
local function skillChoices()
    local labels, idOf, labelOf = {}, {}, {}
    local classSkillIds = currentClassSkillIds()
    for id, name in pairs(Config.KnownSkills) do
        if not classSkillIds or classSkillIds[tostring(id)] then
            local label = name
            if idOf[label] then label = name .. " (" .. id .. ")" end
            labels[#labels + 1] = label
            idOf[label], labelOf[id] = id, label
        end
    end
    table.sort(labels)
    return labels, idOf, labelOf
end
local skillLabels, skillIdOf, skillLabelOf = skillChoices()
local function pickedLabels(ids)
    local out = {}
    for _, id in ipairs(type(ids) == "table" and ids or {}) do
        if skillLabelOf[id] then out[#out + 1] = skillLabelOf[id] end
    end
    return out
end
local skillDrop = secAI:Dropdown({
    Title = "Enemy Action Sequence",
    Desc = "Choose the priority order for normal enemies",
    Icon = "list-checks",
    Multi = true,
    Values = skillLabels,
    Value = pickedLabels(Config.EnemySkillSequence),
    Callback = function(map)
        local list = {}
        for label, on in pairs(type(map) == "table" and map or {}) do
            if on == true and skillIdOf[label] then list[#list + 1] = skillIdOf[label] end
        end
        table.sort(list)
        setFlag("EnemySkillSequence", list)
        setFlag("SkillList", list)
    end,
})
secAI:Toggle({
    Title = "Auto Enemy Skill",
    Value = Config.AutoEnemySkill,
    Callback = function(v) setFlag("AutoEnemySkill", v) end,
})
local bossSkillDrop = secAI:Dropdown({
    Title = "Boss Action Sequence",
    Desc = "Choose the priority order for bosses",
    Icon = "crown",
    Multi = true,
    Values = skillLabels,
    Value = pickedLabels(Config.BossSkillSequence),
    Callback = function(map)
        local list = {}
        for label, on in pairs(type(map) == "table" and map or {}) do
            if on == true and skillIdOf[label] then list[#list + 1] = skillIdOf[label] end
        end
        table.sort(list)
        setFlag("BossSkillSequence", list)
    end,
})
secAI:Toggle({
    Title = "Auto Boss Skill",
    Value = Config.AutoBossSkill,
    Callback = function(v) setFlag("AutoBossSkill", v) end,
})

UI.refreshSkills = function()
    pruneClassSkillState()
    skillLabels, skillIdOf, skillLabelOf = skillChoices()
    -- dot call: SetValues is the raw render function and takes the list itself
    skillDrop.SetValues(skillLabels)
    skillDrop:SetValue(pickedLabels(Config.EnemySkillSequence))
    bossSkillDrop.SetValues(skillLabels)
    bossSkillDrop:SetValue(pickedLabels(Config.BossSkillSequence))
end

secAI:Dropdown({
    Title = "Target Priority",
    Icon = "crosshair",
    Values = TGT_L,
    Value = TGT_LB[Config.TargetMode] or TGT_L[1],
    Callback = function(v) setFlag("TargetMode", TGT_ID[v] or "lowest") end,
})
secAI:Slider({
    Title = "Action Delay (seconds)",
    Icon = "timer",
    Min = 0.1,
    Max = 1,
    Step = 0.05,
    Default = Config.ActDelay,
    Callback = function(v) setFlag("ActDelay", v) end,
})

local secHeal = TabCombat:Section({ Title = "Healing and Survival", Icon = "heart" })
secHeal:Toggle({
    Title = "Use Healing Potion at Low HP",
    Icon = "flask-conical",
    Value = Config.AutoHeal,
    Callback = function(v) setFlag("AutoHeal", v) end,
})
secHeal:Slider({
    Title = "Heal Below HP (%)",
    Icon = "heart",
    Min = 15,
    Max = 90,
    Step = 5,
    Default = Config.HealPct,
    Callback = function(v) setFlag("HealPct", v) end,
})
secHeal:Toggle({
    Title = "Last Life: Flee at Critical HP",
    Icon = "log-out",
    Value = Config.LifeGuard,
    Callback = function(v) setFlag("LifeGuard", v) end,
})
secHeal:Slider({
    Title = "Flee Below HP (%)",
    Icon = "heart-crack",
    Min = 10,
    Max = 60,
    Step = 5,
    Default = Config.LifeGuardPct,
    Callback = function(v) setFlag("LifeGuardPct", v) end,
})

-- TAB 3: DUNGEON -------------------------------------------------------------
local TabRun = Window:Tab({ Title = "Dungeon", Icon = "map" })
local secStart = TabRun:Section({ Title = "Start Run", Icon = "door-open" })
local diffDrop = secStart:Dropdown({
    Title = "Difficulty",
    Icon = "skull",
    Values = DIFF_L,
    Value = DIFF_LB[Config.Difficulty] or DIFF_L[1],
    Callback = function(v) setFlag("Difficulty", DIFF_ID[v] or "normal") end,
})
UI.syncDifficulty = function()
    pcall(function() diffDrop:SetValue(DIFF_LB[Config.Difficulty] or DIFF_L[1]) end)
end
local actDrop = secStart:Dropdown({
    Title = "Start Act",
    Desc = "Choose the first Act for this dungeon run",
    Icon = "layers",
    Values = ACT_L,
    Value = ACT_L[math.clamp(math.floor(tonumber(Config.StartAct) or 1), 1, actCount)] or ACT_L[1],
    Callback = function(v)
        local number = tonumber(tostring(v):match("%d+"))
        if number then setFlag("StartAct", math.clamp(number, 1, actCount)) end
    end,
})
local tormentSlider = secStart:Slider({
    Title = "Torment Tier",
    Desc = "Used for Torment difficulty; the tier must be unlocked",
    Icon = "flame",
    Min = 1,
    Max = TORMENT_MAX,
    Step = 1,
    Default = math.clamp(tonumber(Config.TormentTier) or 1, 1, TORMENT_MAX),
    Callback = function(v) setFlag("TormentTier", math.clamp(math.floor(tonumber(v) or 1), 1, TORMENT_MAX)) end,
})
local modifierDrop = secStart:Dropdown({
    Title = "Modifier",
    Desc = "Apply a live Run Modifier when the dungeon starts",
    Icon = "sliders-horizontal",
    Values = MOD_L,
    Value = MOD_LB[Config.Modifier] or MOD_L[1],
    Callback = function(v) setFlag("Modifier", MOD_ID[v] or "none") end,
})
UI.syncDungeon = function()
    local act = math.clamp(math.floor(tonumber(Config.StartAct) or 1), 1, actCount)
    pcall(function() actDrop:SetValue(ACT_L[act] or ACT_L[1]) end)
    pcall(function() tormentSlider:SetValue(math.clamp(tonumber(Config.TormentTier) or 1, 1, TORMENT_MAX)) end)
    pcall(function() modifierDrop:SetValue(MOD_LB[Config.Modifier] or MOD_L[1]) end)
end
local startRunToggle = secStart:Toggle({
    Title = "Start Run Now",
    Desc = "On starts the selected dungeon and keeps Auto Farm enabled; Off stops future runs",
    Icon = "play",
    Value = Config.Farm,
    Callback = function(v)
        setFlag("Farm", v)
        if v and not farmUiSyncing then
            startLives = lives()
            task.spawn(function()
                local ok = startRun()
                if ok then
                    local act = Config.Difficulty == "torment" and 1 or math.clamp(math.floor(tonumber(Config.StartAct) or 1), 1, actCount)
                    notify("2K Dungeon", "Requested start: " .. difficultyId() .. " • Act-" .. string.format("%02d", act), 3)
                else
                    setFlag("Farm", false)
                    syncFarmControls(false)
                end
            end)
        end
        syncFarmControls(v)
    end,
})
UI.syncStartRun = function(v)
    pcall(function() startRunToggle:SetValue(v) end)
end
UI.applyConfig = function()
    syncFarmControls(Config.Farm)
    if UI.syncDifficulty then pcall(UI.syncDifficulty) end
    if UI.syncDungeon then pcall(UI.syncDungeon) end
end

local secPath = TabRun:Section({ Title = "During Run", Icon = "navigation" })
secPath:Toggle({
    Title = "Auto Vote Path",
    Icon = "navigation",
    Value = Config.AutoVote,
    Callback = function(v) setFlag("AutoVote", v) end,
})
secPath:Dropdown({
    Title = "Path Priority",
    Icon = "route",
    Values = PATH_L,
    Value = PATH_LB[Config.PathMode] or PATH_L[1],
    Callback = function(v) setFlag("PathMode", PATH_ID[v] or "balanced") end,
})
secPath:Toggle({
    Title = "Auto Handle Events",
    Desc = "Campfire: rest at low HP, sharpen at full HP; avoid Blood Altar sacrifice",
    Icon = "tent",
    Value = Config.AutoEvents,
    Callback = function(v) setFlag("AutoEvents", v) end,
})
secPath:Toggle({
    Title = "Watchdog (refresh stalled state)",
    Icon = "life-buoy",
    Value = Config.Watchdog,
    Callback = function(v) setFlag("Watchdog", v) end,
})

local secGrow = TabRun:Section({ Title = "Automatic Progression", Icon = "trending-up" })
local BUILD_L, BUILD_ID, BUILD_LB = choiceMap({
    { "balanced", "Balanced (main stat 2 : HP 1)" },
    { "dps", "Damage (main stat only)" },
    { "tank", "Tank (main stat 1 : HP 1 : armor 1)" },
})
secGrow:Toggle({
    Title = "Auto Allocate Stats",
    Desc = "Spent points require a reset item to undo; choose a build first",
    Icon = "bar-chart-3",
    Value = Config.AutoStats,
    Callback = function(v) setFlag("AutoStats", v) end,
})
secGrow:Dropdown({
    Title = "Stat Build",
    Desc = "Main stat scales class damage (Archer: Dexterity)",
    Icon = "sliders-horizontal",
    Values = BUILD_L,
    Value = BUILD_LB[Config.StatBuild] or BUILD_L[1],
    Callback = function(v) setFlag("StatBuild", BUILD_ID[v] or "balanced") end,
})
secGrow:Toggle({
    Title = "Auto Restock Healing Potions",
    Desc = "The game lets you carry three potions per run from storage",
    Icon = "flask-conical",
    Value = Config.AutoPotionBuy,
    Callback = function(v) setFlag("AutoPotionBuy", v) end,
})
secGrow:Slider({
    Title = "Minimum Potions in Storage",
    Icon = "package",
    Min = 3,
    Max = 60,
    Step = 3,
    Default = Config.PotionKeep,
    Callback = function(v) setFlag("PotionKeep", v) end,
})
secGrow:Toggle({
    Title = "Auto Climb Difficulty",
    Desc = "Win above 50% HP: increase one tier; loss: decrease one tier; Normal to Nightmare",
    Icon = "mountain",
    Value = Config.AutoClimb,
    Callback = function(v) setFlag("AutoClimb", v) end,
})

local secEnd = TabRun:Section({ Title = "End of Run", Icon = "flag" })
secEnd:Dropdown({
    Title = "After Run",
    Icon = "refresh-cw",
    Values = END_L,
    Value = END_LB[Config.EndAction] or END_L[1],
    Callback = function(v) setFlag("EndAction", END_ID[v] or "replay") end,
})
secEnd:Slider({
    Title = "Delay Before Next Run (seconds)",
    Icon = "timer",
    Min = 0.5,
    Max = 10,
    Step = 0.5,
    Default = Config.EndDelay,
    Callback = function(v) setFlag("EndDelay", v) end,
})
secEnd:Button({
    Title = "Replay Now",
    Icon = "rotate-ccw",
    Callback = function()
        local st = Run.view and Run.view.state
        if st and st.id then cmd("RunLobby", { action = "endingDone", runId = tostring(st.id) }) end
        cmd("RunLobby", { action = "replay" })
    end,
})
secEnd:Button({
    Title = "Return to Village Now",
    Icon = "home",
    Callback = function()
        setFlag("Farm", false)
        UI.syncFarm(false)
        cmd("RunLobby", { action = "replayDecline" })
        cmd("RunGoHome")
        pcall(function() Run.view.options.onReturnToVillage() end)
    end,
})

-- TAB 4: MISC ----------------------------------------------------------------
local TabMisc = Window:Tab({ Title = "Misc", Icon = "settings" })
local secMisc = TabMisc:Section({ Title = "General", Icon = "gift" })
secMisc:Toggle({
    Title = "Auto Accept Battle Invites",
    Desc = "Can pull you into battles outside the selected farm route",
    Icon = "user-plus",
    Value = Config.AutoJoin,
    Callback = function(v) setFlag("AutoJoin", v) end,
})
secMisc:Toggle({
    Title = "Redeem Codes on Startup",
    Icon = "ticket",
    Value = Config.AutoCodes,
    Callback = function(v) setFlag("AutoCodes", v) end,
})
secMisc:Button({
    Title = "Redeem All Codes Now",
    Icon = "ticket",
    Callback = function()
        task.spawn(function()
            redeemAllCodes()
            notify("2K Codes", "Submitted codes: " .. table.concat(CODES, ", "), 4)
        end)
    end,
})

local secConfig = TabMisc:Section({ Title = "Config", Icon = "save" })
local configNameBox = secConfig:Input({Title = "Config Name", Placeholder = "config name", Default = "default"})
local savedAutoLoadName = readAutoLoadName()
local selectedConfigName = savedAutoLoadName
local initialConfigNames = configNames()
if selectedConfigName and not table.find(initialConfigNames, selectedConfigName) then selectedConfigName = nil end
local configListDrop = secConfig:Dropdown({Title = "Saved Configs", Values = initialConfigNames, Value = savedAutoLoadName or initialConfigNames[1], Callback = function(v)
    selectedConfigName = v
    if configNameBox and configNameBox.SetValue then configNameBox:SetValue(v) end
end})
if savedAutoLoadName and configNameBox and configNameBox.SetValue then configNameBox:SetValue(savedAutoLoadName) end
local function refreshConfigList()
    task.defer(function()
        pcall(function() configListDrop.SetValues(configNames()) end)
    end)
end
local function currentConfigName()
    local name = configNameBox and configNameBox.GetValue and configNameBox:GetValue() or ""
    name = cleanConfigName(name)
    if name then selectedConfigName = name end
    return name
end
secConfig:Button({Title = "Create Config", Callback = function()
    local name = currentConfigName() or "default"
    pcall(saveConfig, name); selectedConfigName = name; refreshConfigList()
end})
secConfig:Button({Title = "Save Config", Callback = function()
    local name = currentConfigName() or "default"
    pcall(saveConfig, name); selectedConfigName = name; refreshConfigList()
end})
secConfig:Button({Title = "Load Config", Callback = function()
    local name = currentConfigName()
    if name then pcall(loadConfig, name) else notify("2K Config", "Enter a config name first", 3) end
end})
secConfig:Button({Title = "Delete Config", Callback = function()
    local name = cleanConfigName(selectedConfigName or (configNameBox and configNameBox.GetValue and configNameBox:GetValue() or ""))
    if not name or not delfile or not isfile then return end
    local removed = false
    local path = configSavePath(name)
    if path and isfile(path) then pcall(delfile, path); removed = true end
    if removed then
        if savedAutoLoadName == name then
            savedAutoLoadName = nil
            if isfile(autoLoadMarkerPath()) then pcall(delfile, autoLoadMarkerPath()) end
        end
        selectedConfigName = nil
        refreshConfigList()
        print("[TwoK Config] Deleted")
    end
end})
local autoLoadToggle = secConfig:Toggle({Title = "Auto Load Config on This Account", Value = savedAutoLoadName ~= nil, Callback = function(v)
    if v and writefile then
        local name = currentConfigName() or selectedConfigName
        local path = name and configPath(name)
        if not (name and path and isfile and isfile(path)) then
            notify("2K Config", "Save the selected config before enabling Auto Load", 4)
            return
        end
        ensureConfigFolders()
        local ok = pcall(writefile, autoLoadMarkerPath(), name)
        if ok then savedAutoLoadName = name; selectedConfigName = name end
    elseif not v and delfile and isfile then
        if isfile(autoLoadMarkerPath()) then pcall(delfile, autoLoadMarkerPath()) end
        savedAutoLoadName = nil
    end
end})
pcall(function()
    local name = readAutoLoadName()
    if name then
        selectedConfigName = name
        if configNameBox and configNameBox.SetValue then configNameBox:SetValue(name) end
        if loadConfig(name) then
            notify("2K Config", "Auto loaded: " .. name, 4)
        elseif autoLoadToggle then
            autoLoadToggle:SetValue(false)
        end
    end
end)

local secSys = TabMisc:Section({ Title = "System", Icon = "cpu" })
secSys:Button({
    Title = "Reset Statistics",
    Icon = "rotate-ccw",
    Callback = function()
        resetStats()
        notify("2K Statistics", "Statistics reset to zero", 3)
    end,
})
secSys:Button({
    Title = "Rejoin Current Server",
    Icon = "refresh-cw",
    Callback = function()
        pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
    end,
})
secSys:Button({
    Title = "Unload Script",
    Icon = "power",
    Callback = function()
        saveStats()
        _G.TwoKPixelLineageCleanUp()
        cleanPrevGui()
        pcall(function() Window:Destroy() end)
    end,
})

-- ── 13. LIVE STATUS ───────────────────────────────────────────────────────────
local function fmtTime(sec)
    sec = math.floor(sec)
    return string.format("%d:%02d:%02d", sec // 3600, (sec % 3600) // 60, sec % 60)
end

task.spawn(function()
    while alive() do
        pcall(function()
            local lv = lives()
            pHero:Set({ Title = string.format("%s • %s Lv.%s • Lives %s%s",
                LocalPlayer.DisplayName,
                tostring(LocalPlayer:GetAttribute("RPGClass") or "?"),
                tostring(LocalPlayer:GetAttribute("RPGLevel") or "?"),
                tostring(lv or "?"),
                (lv and lv <= 1) and " ⚠️ Last life" or "") })
            local s = Battle.snap
            if s and LocalPlayer:GetAttribute("InTurnBattle") == true then
                local hp = myBattlePct(s)
                pBattle:Set({ Title = string.format("⚔️ Battle • HP %s • %s",
                    hp and string.format("%.0f%%", hp) or "?",
                    s.canAct == true and "Your turn" or "Waiting") .. " • " .. Battle.status })
            else
                pBattle:Set({ Title = "Idle • Last action: " .. Battle.status })
            end
            local inRun = LocalPlayer:GetAttribute("PBInRun") == true
            pRun:Set({ Title = string.format("Run: %s • Farm %s • %s",
                inRun and Run.status or "In Village",
                Config.Farm and "On" or "Off", difficultyId()) })
            pStats:Set({ Title = string.format("Wins %d / Losses %d • Floors %d • Runs %d • Dodges %d • Minigames %d • %s",
                Stats.fightsWon, Stats.fightsLost, Stats.floors, Stats.runs, Stats.dodges, Stats.minigames,
                fmtTime(secondsBase + os.clock() - Stats.startedAt)) })
        end)
        task.wait(1)
    end
end)

_G.TwoKPixelLineage = {
    Config = Config, Stats = Stats, Battle = Battle, Run = Run,
    StartRun = startRun, Controller = rpgController, SetFlag = setFlag,
    Hero = Hero, HeroProfile = heroProfile, NextStat = nextStat, SkillScore = skillScore,
    RecoverBattleSnap = recoverBattleSnap,
}

Window:Notify({
    Title = "2K PIXEL LINEAGE",
    Content = "Loaded • Right Ctrl toggles the UI • Enable Auto Farm on Home to start continuous runs",
    Duration = 6,
})
print("[TwoK] Pixel Lineage hub loaded")
